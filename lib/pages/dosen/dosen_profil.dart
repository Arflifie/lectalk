import 'package:flutter/material.dart';
import 'package:lectalk/pages/dosen/dosen_chat_page.dart';
import 'package:lectalk/pages/dosen/dosen_contact_mahasiswa.dart';
import 'package:lectalk/pages/dosen/dosen_profil_edit.dart';

// Diubah menjadi StatefulWidget
class ProfileDosenPage extends StatefulWidget {
  const ProfileDosenPage({super.key});

  @override
  State<ProfileDosenPage> createState() => _ProfileDosenPageState();
}

class _ProfileDosenPageState extends State<ProfileDosenPage> {
  int _selectedIndex = 2; // Tab aktif: Profil (index 2)

  // Tinggi area header biru
  final double _headerHeight = 0.35;
  // Radius tikungan container putih dan navbar
  final double _borderRadius = 35.0;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Tidak perlu navigasi jika index sama

    setState(() {
      _selectedIndex = index;
    });

    // Navigasi ke halaman lain berdasarkan index
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LecturerChatPage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MahasiswaDataContact()),
        );
        break;
      case 2:
        // Sudah di halaman Profil, tidak perlu navigasi
        break;
    }
  }

  // Widget Navbar Item
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    // REVISI: Menggunakan InkWell untuk feedback visual yang lebih baik
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : const Color.fromARGB(255, 77, 136, 212),
              size: 30,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : const Color.fromARGB(255, 77, 136, 212),
                fontSize: 12, // Dibuat sedikit lebih kecil agar lebih rapi
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Jarak foto profil dari atas (di tengah area biru)
    final double profilePicTop = size.height * _headerHeight - (100 / 2);
    // Tinggi area card content yang putih
    final double whiteContentHeight = size.height * (1.0 - _headerHeight) + 50;

    // Ukuran Foto Profil
    const double profilePicSize = 100;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- 1. Background Biru Tua di Atas ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * _headerHeight,
              color: const Color(0xFF1E3A5F), // Background Biru Tua Utama
            ),
          ),

          // --- 2. Konten Utama (SingleChildScrollView) ---
          // Menggunakan Positioned untuk area konten putih agar tata letak lebih terstruktur
          Positioned(
            top:
                size.height * _headerHeight -
                _borderRadius, // Dimulai sedikit di atas area transisi
            left: 0,
            right: 0,
            child: Container(
              height:
                  whiteContentHeight, // Tinggi yang cukup untuk semua konten
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_borderRadius),
                  topRight: Radius.circular(_borderRadius),
                ),
              ),
              child: SingleChildScrollView(
                // Tambahkan padding vertikal di sini
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                child: Column(
                  children: [
                    // Padding atas yang menutupi bagian lengkungan putih + space untuk foto yang menjorok
                    SizedBox(height: _borderRadius + profilePicSize / 2),

                    // --- KARTU 1: DATA DOSEN (Biru Gelap) ---
                    // REVISI: Padding atas dikurangi karena foto sudah di atasnya
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      margin: const EdgeInsets.only(
                        top: profilePicSize / 2 - 30,
                      ), // Menggeser kartu ke atas sedikit
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F566D),
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
                            'Erick Matahir',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '139099401',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w300,
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.security,
                                color: Colors.orange,
                                size: 40,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Universitas Jambi',
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
                          Divider(color: Colors.grey[400], thickness: 1.5),
                          const SizedBox(height: 15),
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

                    // --- TOMBOL BAWAH (Logout & Edit) ---
                    Row(
                      children: [
                        // Tombol Logout
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: const Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                227,
                                16,
                                9,
                              ), // Warna merah
                              padding: const EdgeInsets.symmetric(
                                vertical:
                                    20, // REVISI: Dibuat sedikit lebih kecil
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
                        // REVISI: Menggunakan ElevatedButton untuk konsistensi
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EditProfileDosenPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5F7C8E),
                            padding: const EdgeInsets.all(
                              20,
                            ), // REVISI: Disesuaikan agar sama dengan tinggi tombol Logout
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height:
                          80, // Spasi bawah agar tidak tertutup navbar (lebih ringkas)
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- 3. FOTO PROFIL (Overlay di tengah transisi) ---
          Positioned(
            top: profilePicTop, // Posisi mutlak di tengah transisi
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:
                      Colors.white, // REVISI: Border putih agar lebih menonjol
                  shape: BoxShape.circle,
                  boxShadow: [
                    // Tambahkan sedikit shadow
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Container(
                  width: profilePicSize,
                  height: profilePicSize,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    // Hilangkan 'image: AssetImage()' jika Anda belum menambahkan aset gambar
                    // Anda bisa tambahkan kembali jika aset 'assets/profile_pic.png' sudah ada.
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // --- 4. Navbar (Diposisikan di atas semua konten) ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2F4A),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.chat_bubble_rounded,
                      label: 'Chat',
                      index: 0,
                      isSelected: _selectedIndex == 0,
                    ),
                    _buildNavItem(
                      icon: Icons.school_rounded,
                      label: 'Mahasiswa',
                      index: 1,
                      isSelected: _selectedIndex == 1,
                    ),
                    _buildNavItem(
                      icon: Icons.person_rounded,
                      label: 'Profil',
                      index: 2,
                      isSelected: _selectedIndex == 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
