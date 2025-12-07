import 'package:flutter/material.dart';

class LecturerDataPage extends StatefulWidget {
  const LecturerDataPage({super.key});

  @override
  State<LecturerDataPage> createState() => _LecturerDataPageState();
}

class _LecturerDataPageState extends State<LecturerDataPage> {
  int _selectedIndex = 1; // Tab aktif: Lecturer

  // --- 1. Logic untuk Filter ---
  int _selectedFilterIndex = 0; // Default terpilih index 0
  final List<String> _filters = [
    'All',
    'Dosen S3',
    'Fakultas Teknik',
    'Sistem Informasi',
    'Manajemen',
  ];

  // Data Dummy
  final List<Map<String, String>> _lecturers = [
    {
      'name': 'Bambang Listiyanto, S.Kom., MSI',
      'dept': 'Sistem Informasi',
      'image': 'assets/dosen1.jpg',
    },
    {
      'name': 'Dr. Rina Maharani, M.Pd.',
      'dept': 'Manajemen Pendidikan',
      'image': 'assets/dosen2.jpg',
    },
    {
      'name': 'Yusuf Al-Fattah, S.Kom., M.Cs.',
      'dept': 'Teknik Jaringan',
      'image': 'assets/dosen3.jpg',
    },
    {
      'name': 'Drs. Andi Permana, M.Si.',
      'dept': 'Statistika dan Data Science',
      'image': 'assets/dosen4.jpg',
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
        ],
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
                          hintText: 'Search name/NIP',
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

                  // --- 2. Filter Chips (Updated) ---
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        return _buildFilterChip(
                          label: _filters[index],
                          isSelected: _selectedFilterIndex == index,
                          onTap: () {
                            setState(() {
                              _selectedFilterIndex = index;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Grid View
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 150,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio:
                                0.75, // Sedikit lebih tinggi agar layout lega
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

      // Navbar (Tetap Sama)
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
                label: 'Lecturer',
                index: 1,
                isSelected: _selectedIndex == 1,
              ),
              _buildNavItem(
                icon: Icons.dashboard_customize_rounded,
                label: 'Template',
                index: 2,
                isSelected: _selectedIndex == 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Filter Chip yang Bisa Diklik ---
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // Jika selected: Warna Biru Gelap, Jika tidak: Putih
          color: isSelected
              ? const Color(0xFF1E3A5F).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            // Jika selected: Border Biru, Jika tidak: Abu-abu
            color: isSelected ? const Color(0xFF1E3A5F) : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            // Jika selected: Text Biru Tebal, Jika tidak: Text Abu
            color: isSelected ? const Color(0xFF1E3A5F) : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // --- Widget Kartu Dosen yang Diimprovisasi ---
  Widget _buildLecturerCard(Map<String, String> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15), // Rounded lebih halus
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // HEADER BIRU (Berisi Foto + Icon)
          Expanded(
            flex: 3, // Proporsi lebih besar untuk area foto
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                // Gradient halus agar terlihat modern (opsional, bisa solid color)
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF5B84B1), Color(0xFF4A73A0)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Foto Dosen
                  Container(
                    width: 70,
                    height: 85,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/placeholder_man.png',
                        ), // Ganti dengan data['image']
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.grey,
                    ), // Fallback
                  ),

                  const Spacer(),

                  // 2. Icon Actions (Column di sebelah kanan)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Tombol Info
                      _buildCardIconBtn(Icons.info_outline),
                      const SizedBox(height: 10),
                      // Tombol Chat
                      _buildCardIconBtn(Icons.chat_bubble_outline),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // BODY PUTIH (Nama & Prodi)
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data['name']!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Roboto', // Contoh font
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Color(
                        0xFF1E3A5F,
                      ), // Warna teks biru tua agar kontras
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 1,
                    width: 30,
                    color: Colors.grey.shade300,
                  ), // Garis pemanis
                  const SizedBox(height: 4),
                  Text(
                    data['dept']!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Icon Bulat di dalam Kartu
  Widget _buildCardIconBtn(IconData icon) {
    return InkWell(
      onTap: () {}, // Action kosong
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 1.5,
          ), // Border putih tegas
          color: Colors.white.withOpacity(0.1), // Transparan dikit
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  // Widget Navbar Item (Sama)
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
