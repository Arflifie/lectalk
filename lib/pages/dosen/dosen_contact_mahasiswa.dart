import 'package:flutter/material.dart';
import 'package:lectalk/pages/dosen/dosen_chat_page.dart';
import 'package:lectalk/pages/dosen/dosen_profil.dart';

class MahasiswaDataContact extends StatefulWidget {
  const MahasiswaDataContact({super.key});

  @override
  State<MahasiswaDataContact> createState() => _MahasiswaDataContactState();
}

class _MahasiswaDataContactState extends State<MahasiswaDataContact> {
  int _selectedIndex = 1; // Tab aktif: Lecturer

  // Data Dummy Dosen
  final List<Map<String, String>> _lecturers = [
    {'name': 'Aziz Alhadiid', 'image': 'assets/dosen1.jpg'},
    {'name': 'Arfun Ali Yafie', 'image': 'assets/dosen2.jpg'},
    {'name': 'Irfan Aziz', 'image': 'assets/dosen3.jpg'},
    {'name': 'Daffa Dzulfaqor', 'image': 'assets/dosen4.jpg'},
    {'name': 'Echi Lesianda', 'image': 'assets/dosen5.jpg'},
    {'name': 'Ahmad Fauzan', 'image': 'assets/dosen6.jpg'},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigasi ke halaman lain berdasarkan index
    // Ganti YourChatPage(), YourTemplatePage() dengan class halaman Anda
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LecturerChatPage()),
        );
        break;
      case 1:
        // Sudah di halaman Lecturer, tidak perlu navigasi
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileDosenPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        elevation: 0,
        title: const Text(
          'Kontak Dosen',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
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
                  const SizedBox(height: 20),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari nama mahasiswa...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          suffixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // List View Dosen
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 100,
                        top: 10,
                      ),
                      itemCount: _lecturers.length,
                      itemBuilder: (context, index) {
                        return _buildLecturerCard(_lecturers[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Navbar
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

  // Widget Kartu Dosen - Tampilan List Sederhana
  Widget _buildLecturerCard(Map<String, String> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            // Foto Dosen
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF1E3A5F).withOpacity(0.2),
                  width: 2,
                ),
                image: const DecorationImage(
                  image: AssetImage(
                    'assets/placeholder_man.png',
                  ), // Ganti dengan data['image']
                  fit: BoxFit.cover,
                ),
              ),
              child: data['image']!.isEmpty
                  ? const Icon(Icons.person, color: Colors.grey, size: 30)
                  : null,
            ),

            const SizedBox(width: 15),

            // Nama Dosen
            Expanded(
              child: Text(
                data['name']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF1E3A5F),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 10),

            // Tombol Chat
            InkWell(
              onTap: () {
                // Tambahkan navigasi ke halaman chat dengan dosen ini
                print('Chat dengan ${data['name']}');
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ChatDetailPage(
                //       lecturerName: data['name']!,
                //     ),
                //   ),
                // );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A5F).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Navbar Item
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
