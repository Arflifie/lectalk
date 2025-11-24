import 'package:flutter/material.dart';
import 'package:lectalk/pages/profil_edit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ukuran layar untuk kalkulasi responsif
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F), // Background Biru Tua Utama
      body: SafeArea(
        child: Stack(
          children: [
            // --- 1. Background Decoration (Opsional: Bentuk abstrak di kanan atas) ---
            Positioned(
              top: -50,
              right: -50,
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(
                    color: Colors.lightBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            // --- 2. Header (Back Button & Title) ---
            Positioned(
              top: 10,
              left: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const Positioned(
              top: 25,
              right: 20,
              child: Text(
                'Profil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.0,
                ),
              ),
            ),

            // --- 3. Body Content (Grey Container & Cards) ---
            // Kita mulai container abu-abu dari sekitar 30% layar ke bawah
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: size.height * 0.72, // Tinggi area abu-abu
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E5E5), // Warna Abu-abu muda
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
              ),
            ),

            // --- 4. Floating Cards & Profile Picture ---
            // Menggunakan SingleChildScrollView agar aman di layar kecil
            Positioned.fill(
              top:
                  size.height *
                  0.18, // Mulai konten sedikit di atas area abu-abu
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none, // Agar foto bisa keluar dari batas
                  children: [
                    // A. Container untuk Layout Kartu (Biar ada jarak buat foto)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 50.0,
                      ), // Jarak agar tidak ketabrak foto
                      child: Column(
                        children: [
                          // --- KARTU 1: DATA MAHASISWA (Biru Gelap) ---
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(
                              20,
                              60,
                              20,
                              30,
                            ), // Top padding besar utk nama
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF3F566D,
                              ), // Warna Biru keabu-abuan (sesuai gambar)
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: const [
                                Text(
                                  'Saya Budi',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'F1E130500',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                SizedBox(height: 25),
                                Text(
                                  'Student',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // --- KARTU 2: UNIVERSITAS (Putih) ---
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 25,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                // Logo & Nama Kampus
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Placeholder Logo (Ganti dengan Image.asset jika ada)
                                    const Icon(
                                      Icons.security,
                                      color: Colors.orange,
                                      size: 40,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Jambi University',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF444444),
                                          ),
                                        ),
                                        Text(
                                          'Sains and technology Faculty',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                // Garis Pembatas
                                Divider(
                                  color: Colors.grey[400],
                                  thickness: 1.5,
                                ),
                                const SizedBox(height: 15),
                                // Prodi & Tahun
                                const Text(
                                  'Information System',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF555555),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  '2030',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),

                          // --- TOMBOL BAWAH (QR & Edit) ---
                          Row(
                            children: [
                              // Tombol QR Code
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.qr_code_2,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Show QR code',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFF5F8D9E,
                                    ), // Warna Teal/Biru sesuai gambar
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 25,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              // Tombol Edit
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EditProfilePage(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF5F7C8E,
                                    ), // Warna senada tapi lebih gelap
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 50,
                          ), // Spasi bawah agar bisa scroll enak
                        ],
                      ),
                    ),

                    // --- B. FOTO PROFIL (Overlay) ---
                    // Diposisikan di paling atas Stack ini
                    Positioned(
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(
                          4,
                        ), // Border putih tipis kalau mau, atau transparan
                        decoration: const BoxDecoration(
                          color: Colors
                              .transparent, // Ubah ke Colors.white jika ingin border putih
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Colors.red, // Background merah sesuai gambar
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/profile_pic.png',
                              ), // Ganti gambar Anda
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Jika gambar gagal load:
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
