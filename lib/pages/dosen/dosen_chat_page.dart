import 'package:flutter/material.dart';
// Import halaman tujuan yang diperlukan untuk navigasi
import 'package:lectalk/pages/dosen/dosen_contact_mahasiswa.dart';
import 'package:lectalk/pages/dosen/dosen_profil.dart';

class LecturerChatPage extends StatefulWidget {
  const LecturerChatPage({super.key});

  @override
  State<LecturerChatPage> createState() => _LecturerChatPageState();
}

class _LecturerChatPageState extends State<LecturerChatPage> {
  // Index 0 untuk Chat
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    // Navigasi ke halaman lain berdasarkan index
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MahasiswaDataContact()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileDosenPage()),
        );
        break;
    }
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
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

  Widget _buildChatItem({
    required String name,
    required String nim,
    required String message,
    required String time,
    required String avatar,
  }) {
    // ... (Tidak ada perubahan pada widget chat item)
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, size: 35, color: Colors.grey[600]),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'NIM: $nim',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F),
      appBar: AppBar(
        // REVISI: Mengatur leading menjadi null untuk menghapus tombol back (jika ada)
        leading: null,
        automaticallyImplyLeading:
            false, // Memastikan tombol back bawaan tidak muncul
        backgroundColor: const Color(0xFF1E3A5F),
        elevation: 0,

        // REVISI: Mengubah judul, memperbesar, dan menjadikannya bold
        title: const Text(
          'Lectalk', // Judul diubah menjadi 'Lectalk'
          style: TextStyle(
            color: Colors.white, // Warna dibuat lebih solid
            fontSize: 28, // Ukuran diperbesar
            fontWeight: FontWeight.bold, // Dibuat bold
          ),
        ),

        // REVISI: Mengatur rata kiri
        titleSpacing: 20.0, // Memberi sedikit padding dari kiri
        // REVISI: Menghapus seluruh bagian actions (hamburger menu)
        actions: const [],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _buildChatItem(
                          name: 'Taufiqurahman',
                          nim: 'F1E130500',
                          message: 'Okey sir',
                          time: '14:54',
                          avatar: 'assets/avatar.jpg',
                        ),
                        _buildChatItem(
                          name: 'Ahmad Rizki',
                          nim: 'F1E130501',
                          message: 'Terima kasih pak atas bimbingannya',
                          time: '10:23',
                          avatar: 'assets/avatar.jpg',
                        ),
                        _buildChatItem(
                          name: 'Siti Nurhaliza',
                          nim: 'F1E130502',
                          message: 'Baik pak, saya akan revisi',
                          time: 'Yesterday',
                          avatar: 'assets/avatar.jpg',
                        ),
                        _buildChatItem(
                          name: 'Budi Santoso',
                          nim: 'F1E130503',
                          message: 'Pak, boleh konsultasi hari Rabu?',
                          time: 'Yesterday',
                          avatar: 'assets/avatar.jpg',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: Container(
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
