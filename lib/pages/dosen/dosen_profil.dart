import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // [1] Tambahkan Supabase
import 'package:lectalk/pages/dosen/dosen_chat_page.dart';
import 'package:lectalk/pages/dosen/dosen_contact_mahasiswa.dart';
// Asumsikan impor untuk halaman edit dosen sudah diperbaiki:
import 'package:lectalk/pages/dosen/dosen_profil_edit.dart';

// Akses Supabase Client
final supabase = Supabase.instance.client;

// Diubah menjadi StatefulWidget
class ProfileDosenPage extends StatefulWidget {
  const ProfileDosenPage({super.key});

  @override
  State<ProfileDosenPage> createState() => _ProfileDosenPageState();
}

class _ProfileDosenPageState extends State<ProfileDosenPage> {
  // [2] State untuk Data Profil
  Map<String, dynamic>? _dosenProfile;
  bool _isLoading = true;
  String _error = '';

  int _selectedIndex = 2; // Tab aktif: Profil (index 2)

  final double _headerHeight = 0.35;
  final double _borderRadius = 35.0;

  @override
  void initState() {
    super.initState();
    // [3] Muat data saat halaman pertama kali dibuka
    _loadProfileData();
  }

  // [4] Fungsi untuk Mengambil Data Profil
  Future<void> _loadProfileData() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _error = 'User belum login.';
      });
      return;
    }

    try {
      final data = await supabase
          .from('dosen_profile')
          .select(
            'nama_dosen, nip_dosen, fakultas_dosen, prodi_dosen, foto_dosen',
          )
          .eq('id', userId)
          .maybeSingle();

      setState(() {
        _dosenProfile = data;
        _isLoading = false;
        _error = (data == null)
            ? 'Profil belum diisi. Silakan edit profil.'
            : '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Gagal memuat data: ${e.toString()}';
      });
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

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
        break;
    }
  }

  // Widget Navbar Item (tidak berubah)
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    // ... (kode _buildNavItem sama) ...
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
                fontSize: 12,
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
    final double profilePicTop = size.height * _headerHeight - (100 / 2);
    const double profilePicSize = 100;

    // [5] Tampilkan Loading atau Error
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error.isNotEmpty && _dosenProfile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error),
              TextButton(
                onPressed: _loadProfileData,
                child: const Text('Coba Lagi'),
              ),
              const SizedBox(height: 100), // Spacer untuk navbar
            ],
          ),
        ),
        // [6] Memastikan Navbar tetap tampil
        bottomNavigationBar: _buildNavbar(context),
      );
    }

    // Default values jika _dosenProfile null (meski sudah dicek)
    final namaDosen = _dosenProfile?['nama_dosen'] ?? 'Nama Belum Diisi';
    final nipDosen = _dosenProfile?['nip_dosen'] ?? 'NIP Belum Diisi';
    final prodiDosen = _dosenProfile?['prodi_dosen'] ?? 'Prodi Belum Diisi';
    final fakultasDosen =
        _dosenProfile?['fakultas_dosen'] ?? 'Fakultas Belum Diisi';
    final fotoDosenUrl = _dosenProfile?['foto_dosen'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- 1. Background Biru Tua di Atas --- (Tidak Berubah)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * _headerHeight,
              color: const Color(0xFF1E3A5F),
            ),
          ),

          // --- 2. Konten Utama --- (Tidak Berubah strukturnya)
          Positioned(
            top: size.height * _headerHeight - _borderRadius,
            left: 0,
            right: 0,
            child: Container(
              // ... (styling container)
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_borderRadius),
                  topRight: Radius.circular(_borderRadius),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                child: Column(
                  children: [
                    SizedBox(height: _borderRadius + profilePicSize / 2),

                    // --- KARTU 1: DATA DOSEN (Biru Gelap) ---
                    Container(
                      // ... (styling container)
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      margin: const EdgeInsets.only(
                        top: profilePicSize / 2 - 30,
                      ),
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
                        children: [
                          // [7] Tampilkan NAMA DOSEN
                          Text(
                            namaDosen,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 5),
                          // [8] Tampilkan NIP DOSEN
                          Text(
                            nipDosen,
                            style: const TextStyle(
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
                          // Universitas Jambi (tetap)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: Image.network(
                                  'https://www.unja.ac.id/wp-content/uploads/2025/06/cropped-logoUNJA-2.png',
                                  fit: BoxFit.cover,
                                ),
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
                                  // [9] Ganti Science and Technology Faculty
                                  Text(
                                    'A World Class Enterpreunership University',
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
                          // [10] Tampilkan PROGRAM STUDI
                          Text(
                            prodiDosen,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF555555),
                            ),
                          ),
                          const SizedBox(height: 5),
                          // [11] Ganti Angka 2030 menjadi FAKULTAS
                          Text(
                            fakultasDosen,
                            style: const TextStyle(
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
                        // ... (Tombol Logout) ...
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
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Tombol Edit
                        ElevatedButton(
                          onPressed: () {
                            // Panggil _loadProfileData lagi saat kembali
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EditProfileDosenPage(),
                              ),
                            ).then((_) => _loadProfileData());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5F7C8E),
                            padding: const EdgeInsets.all(20),
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
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),

          // --- 3. FOTO PROFIL ---
          Positioned(
            top: profilePicTop,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
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
                    color: Color(0xFF6C7E90), // Warna abu-abu default
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: fotoDosenUrl != null
                        ? Image.network(
                            fotoDosenUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ),
          ),

          // --- 4. Navbar ---
          _buildNavbar(context),
        ],
      ),
    );
  }

  // [6] Helper method untuk Navbar (Dipindahkan)
  Align _buildNavbar(BuildContext context) {
    return Align(
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
    );
  }
}
