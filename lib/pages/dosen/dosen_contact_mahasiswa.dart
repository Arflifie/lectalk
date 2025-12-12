// File: dosen_contact_mahasiswa.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lectalk/pages/dosen/dosen_chat_page.dart';
import 'package:lectalk/pages/dosen/dosen_profil.dart';
import 'package:lectalk/pages/dosen/dosen_chat_mahasiwa.dart'; // Sesuaikan path jika berbeda

final supabase = Supabase.instance.client; // Akses Supabase Client

class MahasiswaDataContact extends StatefulWidget {
  const MahasiswaDataContact({super.key});

  @override
  State<MahasiswaDataContact> createState() => _MahasiswaDataContactState();
}

class _MahasiswaDataContactState extends State<MahasiswaDataContact> {
  int _selectedIndex = 1;

  List<Map<String, dynamic>> _mahasiswaList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadMahasiswaData();
  }

  // [MODIFIKASI] Fungsi untuk mengambil data mahasiswa dari Supabase
  Future<void> _loadMahasiswaData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Mengambil data sesuai skema terbaru: fakultas & foto_mahasiswa
      final List<dynamic> data = await supabase
          .from('mahasiswa')
          .select('id, nama_mahasiswa, nim, prodi, fakultas, foto_mahasiswa');

      if (!mounted) return;

      setState(() {
        _mahasiswaList = data.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        // [PERBAIKAN] Pesan error yang lebih spesifik jika RLS belum diset
        final String policyHint =
            e.toString().contains('no row-level security policy')
            ? '\nPastikan RLS Policy "SELECT" sudah dibuat untuk tabel mahasiswa.'
            : '';

        _errorMessage =
            'Gagal memuat data mahasiswa: ${e.toString()}$policyHint';
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    // ... (kode navigasi tidak berubah) ...
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
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileDosenPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // [BARU] Logika filter data
    final filteredList = _mahasiswaList.where((mahasiswa) {
      final name = (mahasiswa['nama_mahasiswa'] as String).toLowerCase();
      final nim = (mahasiswa['nim'] as String).toLowerCase();
      final query = _searchText.toLowerCase();
      return name.contains(query) || nim.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kontak Mahasiswa',
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
                        // Menambahkan shadow untuk kesan kedalaman
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchText = value;
                          });
                        },
                        // Styling untuk teks input
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Cari nama mahasiswa...',
                          hintStyle: TextStyle(
                            color: Color(0xFF999999), // Warna hint lebih lembut
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          // Mengubah prefixIcon menjadi Icon lupa
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFF4A6FA5), // Warna ikon disesuaikan
                            size: 24,
                          ),
                          // Menghapus suffixIcon
                          // suffixIcon: Icon(
                          //   Icons.search,
                          //   color: Colors.grey,
                          //   size: 28,
                          // ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Loading/Error/Data
                  _isLoading
                      ? const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _errorMessage.isNotEmpty
                      ? Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _errorMessage,
                                  textAlign: TextAlign.center,
                                ),
                                TextButton(
                                  onPressed: _loadMahasiswaData,
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : filteredList.isEmpty && _mahasiswaList.isNotEmpty
                      ? const Expanded(
                          child: Center(
                            child: Text('Mahasiswa tidak ditemukan.'),
                          ),
                        )
                      : filteredList.isEmpty && _mahasiswaList.isEmpty
                      ? const Expanded(
                          child: Center(
                            child: Text('Belum ada data mahasiswa.'),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: 100,
                              top: 10,
                            ),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              return _buildMahasiswaCard(filteredList[index]);
                            },
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),

      extendBody: true,
      bottomNavigationBar: _buildNavbar(context),
    );
  }

  // [MODIFIKASI] Widget Kartu Mahasiswa
  Widget _buildMahasiswaCard(Map<String, dynamic> data) {
    final String namaMahasiswa =
        data['nama_mahasiswa'] ?? 'Nama Tidak Diketahui';
    final String nim = data['nim'] ?? 'NIM Tidak Diketahui';
    final String userId = data['id'];

    // [PERUBAHAN UTAMA DI SINI] Ambil URL langsung dari kolom foto_mahasiswa
    final String? imageUrl = data['foto_mahasiswa'];

    return Container(
      // ... (styling container) ...
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            // [MODIFIKASI] Foto Profil Mahasiswa
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
              ),
              // Cek apakah imageUrl ada
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl, // Menggunakan URL langsung
                        fit: BoxFit.cover,
                        // Penanganan error jika URL valid tapi gambar tidak ditemukan
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 30,
                            ),
                        // Penanganan loading
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF1E3A5F),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: 30,
                    ), // Placeholder default
            ),

            const SizedBox(width: 15),

            // ... (Nama & NIM Mahasiswa dan Tombol Chat tidak berubah) ...
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    namaMahasiswa,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF1E3A5F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nim,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: Color(0xFF5F5F5F),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Tombol Chat
            InkWell(
              onTap: () {
                // Navigasi ke LecturerChatScreen
                print('Chat dengan $namaMahasiswa (ID: $userId)');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Mengirim data mahasiswa ke halaman chat
                    builder: (context) => LecturerChatScreen(
                      mahasiswaName: namaMahasiswa,
                      mahasiswaNIM: nim,
                      mahasiswaId: userId,
                      mahasiswaFoto: imageUrl, // <<< Tambahkan URL foto
                    ),
                  ),
                );
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

  // Helper method untuk Navbar (Tidak Berubah)
  Align _buildNavbar(BuildContext context) {
    return Align(
      // ... (kode Navbar) ...
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

  // Widget Navbar Item (tidak berubah)
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
