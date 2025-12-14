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

-- Pastikan Anda berada di skema 'public'

-- (A) CREATE TABLE messages
--------------------------------------------------------------------------------
CREATE TABLE public.messages (
    id bigint primary key generated by default as identity,
    
    -- ID Pengirim (Dosen atau Mahasiswa)
    sender_id uuid references public.user_profiles(id) on delete restrict not null,
    
    -- ID Penerima (Dosen atau Mahasiswa)
    recipient_id uuid references public.user_profiles(id) on delete restrict not null,
    
    content text not null,
    
    created_at timestamp with time zone default now(),
    
    is_read boolean default false,

    -- Constraint: memastikan pengirim dan penerima adalah user yang berbeda
    constraint sender_is_not_recipient check (sender_id <> recipient_id)
);

-- (B) INDEXING (Untuk performa query riwayat chat yang cepat)
--------------------------------------------------------------------------------
CREATE INDEX idx_messages_sender_recipient ON public.messages (sender_id, recipient_id);


-- (C) AKTIVASI RLS
--------------------------------------------------------------------------------
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;


-- (D) RLS POLICIES untuk messages
--------------------------------------------------------------------------------

-- 1. POLICY INSERT (Mengirim Pesan)
-- Mengizinkan user terautentikasi untuk INSERT, asalkan mereka adalah sender_id
CREATE POLICY "Users can send messages"
ON public.messages FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = sender_id);


-- 2. POLICY SELECT (Melihat Riwayat Chat)
-- Mengizinkan user terautentikasi untuk SELECT, asalkan mereka adalah pengirim ATAU penerima
CREATE POLICY "Users can view their own messages"
ON public.messages FOR SELECT
TO authenticated
USING (
    auth.uid() = sender_id OR auth.uid() = recipient_id
);

-- 3. POLICY UPDATE (Mengubah Status Dibaca)
-- Mengizinkan user terautentikasi untuk UPDATE (misalnya, mengubah is_read = true), 
-- asalkan user yang sedang login adalah penerima pesan.
CREATE POLICY "Recipient can mark message as read"
ON public.messages FOR UPDATE
TO authenticated
USING (auth.uid() = recipient_id)
WITH CHECK (auth.uid() = recipient_id);

-- Selesai: Tabel messages siap digunakan.

-- (E) CREATE FUNCTION get_dosen_chat_list
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_dosen_chat_list()
RETURNS TABLE (
    user_id uuid,                     -- ID Mahasiswa
    mahasiswa_name text,
    mahasiswa_nim text,               -- NIM (Kolom tambahan)
    mahasiswa_foto text,
    latest_message_content text,
    latest_message_time timestamp with time zone,
    is_read boolean,
    is_sender_me boolean              -- True jika pesan terakhir dikirim oleh Dosen
)
LANGUAGE sql
SECURITY DEFINER -- Gunakan SECURITY DEFINER agar fungsi ini dapat mengakses tabel meskipun RLS diaktifkan
AS $$
WITH ranked_messages AS (
    SELECT
        m.sender_id,
        m.recipient_id,
        m.content,
        m.created_at,
        m.is_read,
        -- Menentukan lawan bicara (Mahasiswa)
        CASE
            WHEN m.sender_id = auth.uid() THEN m.recipient_id
            ELSE m.sender_id
        END AS chatter_id,
        -- Window function: Menentukan rank pesan, 1 adalah yang terbaru dalam setiap konversasi
        ROW_NUMBER() OVER (
            PARTITION BY 
                CASE 
                    WHEN m.sender_id = auth.uid() THEN m.recipient_id 
                    ELSE m.sender_id 
                END 
            ORDER BY m.created_at DESC
        ) AS rn
    FROM
        public.messages m
    WHERE
        -- Filter hanya pesan yang melibatkan Dosen yang sedang login
        m.sender_id = auth.uid() OR m.recipient_id = auth.uid()
)
SELECT
    rm.chatter_id AS user_id,
    m.nama_mahasiswa,
    m.nim AS mahasiswa_nim, -- Memasukkan NIM
    m.foto_mahasiswa,
    rm.content AS latest_message_content,
    rm.created_at AS latest_message_time,
    rm.is_read,
    rm.sender_id = auth.uid() AS is_sender_me
FROM
    ranked_messages rm
JOIN
    public.mahasiswa m ON rm.chatter_id = m.id -- Join ke tabel mahasiswa
WHERE
    rm.rn = 1 -- Hanya ambil pesan yang paling baru (rank 1)
ORDER BY
    rm.created_at DESC; -- Urutkan daftar chat berdasarkan waktu pesan terbaru
$$;

-- (F) GRANT EXECUTE
--------------------------------------------------------------------------------
-- Memberikan hak eksekusi ke semua user yang sudah login
GRANT EXECUTE ON FUNCTION public.get_dosen_chat_list() TO authenticated;

-- Selesai: Fungsi RPC siap dipanggil dari Flutter.

-- Selesai: Fungsi RPC siap dipanggil dari Flutter.
DROP FUNCTION IF EXISTS get_latest_dosen_chats_for_mahasiswa();

-- -- RPC untuk Mahasiswa: Mendapatkan daftar Dosen yang pernah chatting dengan Mahasiswa
-- -- Fungsi ini akan mengambil pesan terakhir dari setiap chat antara Mahasiswa (auth.uid()) dan Dosen
-- CREATE OR REPLACE FUNCTION get_latest_dosen_chats_for_mahasiswa()
-- RETURNS TABLE (
--     user_id uuid,
--     nama_dosen text,
--     nip_dosen text,
--     foto_dosen text,
--     latest_message_content text,
--     latest_message_time timestamp with time zone,
--     is_read boolean,
--     is_sender_me boolean
-- )
-- LANGUAGE sql
-- SECURITY DEFINER
-- AS $$
-- WITH ranked_messages AS (
--     SELECT
--         m.content,
--         m.created_at,
--         m.is_read,
--         m.sender_id,
--         -- Menentukan ID Dosen sebagai partner chat (chatter_id)
--         CASE
--             WHEN m.sender_id = auth.uid() THEN m.recipient_id -- Jika saya (Mahasiswa) pengirim, partner adalah penerima
--             ELSE m.sender_id -- Jika saya (Mahasiswa) penerima, partner adalah pengirim (Dosen)
--         END AS chatter_id,
--         -- Window function: Menentukan rank pesan, 1 adalah yang terbaru dalam setiap konversasi
--         ROW_NUMBER() OVER (
--             PARTITION BY 
--                 CASE 
--                     WHEN m.sender_id = auth.uid() THEN m.recipient_id 
--                     ELSE m.sender_id 
--                 END 
--             ORDER BY m.created_at DESC
--         ) AS rn
--     FROM
--         public.messages m
--     WHERE
--         -- Filter hanya pesan yang melibatkan Mahasiswa yang sedang login
--         m.sender_id = auth.uid() OR m.recipient_id = auth.uid()
-- )
-- SELECT
--     rm.chatter_id AS user_id,
--     dp.nama_dosen,
--     dp.nip_dosen,
--     dp.foto_dosen,
--     rm.content AS latest_message_content,
--     rm.created_at AS latest_message_time,
--     rm.is_read,
--     rm.sender_id = auth.uid() AS is_sender_me
-- FROM
--     ranked_messages rm
-- JOIN
--     public.dosen_profile dp ON rm.chatter_id = dp.id -- Join ke tabel dosen_profile
-- JOIN
--     public.user_profiles up ON dp.id = up.id
-- WHERE
--     rm.rn = 1 -- Hanya ambil pesan yang paling baru (rank 1)
--     AND up.role = 'dosen' -- PASTIKAN partner chat adalah dosen
-- ORDER BY
--     rm.created_at DESC;
-- $$;