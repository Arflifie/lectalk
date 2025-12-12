-- Tabel untuk Login berdasarkan role
create table public.user_profiles (
  id uuid references auth.users on delete cascade primary key,
  role text check (role in ('mahasiswa', 'dosen')) default 'mahasiswa',
  created_at timestamp with time zone default now()
);

-- Trigger untuk login
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into public.user_profiles (id)
  values (new.id);
  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();
-- End Trigger

-- Tabel untuk menyimpan detail profil dosen (berelasi 1-ke-1 dengan user_profiles)

CREATE TABLE public.dosen_profile (
    -- ID Dosen: Merupakan Primary Key dan Foreign Key ke tabel user_profiles
    -- Ini memastikan bahwa setiap dosen harus memiliki entri di tabel login.
    id uuid references public.user_profiles on delete cascade primary key,
    
    -- Informasi Pribadi Dosen
    nama_dosen text NOT NULL,
    nip_dosen text UNIQUE NOT NULL, -- NIP biasanya unik
    
    -- Informasi Akademik
    fakultas_dosen text NOT NULL,
    prodi_dosen text NOT NULL,
    
    -- Data Tambahan
    -- URL atau path ke foto profil. Dapat berupa NULL jika belum diunggah.
    foto_dosen text NULL, 
    
    created_at timestamp with time zone DEFAULT now()
);

-- Opsional: Membuat index pada kolom NIP agar pencarian NIP lebih cepat
CREATE INDEX idx_dosen_nip ON public.dosen_profile (nip_dosen);

-- Opsional: Mengamankan tabel dengan Row Level Security (RLS)
ALTER TABLE public.dosen_profile ENABLE ROW LEVEL SECURITY;

-- Pastikan RLS diaktifkan (sudah ada di kode Anda)
-- ALTER TABLE public.dosen_profile ENABLE ROW LEVEL SECURITY;

-- 1. KEBIJAKAN UNTUK DOSEN (UPSERT/CRUD)
-- Kebijakan ini mengizinkan Dosen (user yang sedang login) untuk 
-- MENGINSERT, MEMBACA, dan MENGUPDATE data HANYA pada baris yang memiliki ID yang sama dengan ID mereka.
CREATE POLICY "Dosen can manage their own profile"
ON public.dosen_profile 
FOR ALL -- Menggantikan INSERT, UPDATE, dan SELECT untuk pemilik
TO authenticated 
USING (auth.uid() = id) -- Kriteria READ & DELETE
WITH CHECK (auth.uid() = id); -- Kriteria INSERT & UPDATE (memastikan mereka hanya bisa memasukkan data untuk ID mereka sendiri)

-- Hapus kebijakan lama yang terpecah (jika Anda ingin menggunakan kebijakan ALL di atas):
DROP POLICY IF EXISTS "Dosen can view their own profile" ON public.dosen_profile;
DROP POLICY IF EXISTS "Dosen can update their own profile" ON public.dosen_profile;


-- 2. KEBIJAKAN VIEW PUBLIK (Jika diperlukan)
-- Izinkan semua user yang sudah login (Authenticated) untuk melihat profil dosen lain
CREATE POLICY "Authenticated users can view Dosen profiles" 
ON public.dosen_profile
FOR SELECT 
USING (true); -- Menggunakan true karena ID dosen (PK) adalah data publik yang mungkin dilihat mahasiswa


-- RLS Untuk Bucket
-- Ganti 'image_dosen' jika nama bucket Anda berbeda.

-- Hapus kebijakan lama yang error terlebih dahulu
DROP POLICY IF EXISTS "Dosen can upload their own profile photo" ON storage.objects;
DROP POLICY IF EXISTS "Dosen can update their own profile photo" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can view dosen profile photos" ON storage.objects;


-- 1. POLICY UPLOAD (INSERT)
-- Mengizinkan Dosen (user terautentikasi) untuk MENGUPLOAD file 
-- HANYA ke bucket 'image_dosen' dan ke folder yang diawali dengan 'dosen_photos/'.
CREATE POLICY "Dosen can upload their own profile photo"
ON storage.objects FOR INSERT 
TO authenticated 
WITH CHECK (
    bucket_id = 'image_dosen' AND
    -- REVISI SINTAKS: Memastikan path diawali dengan 'dosen_photos/'
    name::text LIKE 'dosen_photos/%' AND 
    -- Memastikan nama file mengandung ID Dosen
    storage.filename(name) = (auth.uid()::text || '.' || split_part(name::text, '.', array_length(string_to_array(name::text, '.'), 1)))
);

-- 2. POLICY UPDATE/UPSERT (UPDATE)
-- Mengizinkan penimpaan file yang sudah ada
CREATE POLICY "Dosen can update their own profile photo"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'image_dosen' AND
    name::text LIKE 'dosen_photos/%' AND
    -- Memastikan hanya file dengan nama ID mereka sendiri yang bisa di-update
    storage.filename(name) = (auth.uid()::text || '.' || split_part(name::text, '.', array_length(string_to_array(name::text, '.'), 1)))
);


-- 3. POLICY BACA (SELECT)
-- Mengizinkan SEMUA user yang sudah login untuk melihat file di folder dosen_photos
CREATE POLICY "Authenticated users can view dosen profile photos"
ON storage.objects FOR SELECT
TO authenticated 
USING (
    bucket_id = 'image_dosen' AND 
    name::text LIKE 'dosen_photos/%'
);

create table public.mahasiswa (
  -- id ini berfungsi sebagai Primary Key sekaligus Foreign Key
  -- Ini memastikan 1 user profile hanya punya 1 data mahasiswa (1:1)
  id uuid references public.user_profiles(id) on delete cascade primary key,
  
  nama_mahasiswa text not null,
  nim text unique not null, -- NIM sebaiknya unik
  prodi text,
  fakultas text,
  
  -- Kolom tambahan agar data tercatat waktunya
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  foto_mahasiswa text
);

-- (Opsional) Aktifkan RLS agar data aman
alter table public.mahasiswa enable row level security;


-- POLICY UNTUK BUCKET: image_mahasiswa
-- Mengizinkan SEMUA user yang sudah login (Authenticated) untuk melihat
-- file di dalam folder 'mahasiswa_photos/' pada bucket 'image_mahasiswa'.

CREATE POLICY "Dosen can view all Mahasiswa photos"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'image_mahasiswa' AND 
    name::text LIKE 'mahasiswa_photos/%'
);

-- POLICY UNTUK TABEL: public.mahasiswa
-- Mengizinkan user yang sudah login (Authenticated) untuk melihat semua data mahasiswa
CREATE POLICY "Authenticated users can view all Mahasiswa data" 
ON public.mahasiswa
FOR SELECT 
TO authenticated 
USING (true);