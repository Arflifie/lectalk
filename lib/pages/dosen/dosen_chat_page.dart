// File: dosen_chat_page.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
// Import halaman tujuan
import 'package:lectalk/pages/dosen/dosen_contact_mahasiswa.dart';
import 'package:lectalk/pages/dosen/dosen_profil.dart';
import 'package:lectalk/pages/dosen/dosen_chat_mahasiwa.dart'; // Halaman chat detail

final supabase = Supabase.instance.client; // Akses Supabase Client

class LecturerChatPage extends StatefulWidget {
  const LecturerChatPage({super.key});

  @override
  State<LecturerChatPage> createState() => _LecturerChatPageState();
}

class _LecturerChatPageState extends State<LecturerChatPage> {
  int _selectedIndex = 0; // Index 0 untuk Chat

  List<Map<String, dynamic>> _chatList = [];
  bool _isLoading = true;
  String _searchText = ''; // State baru untuk menyimpan input pencarian

  @override
  void initState() {
    super.initState();
    _loadChatList();
  }

  // Fungsi untuk memuat daftar chat menggunakan RPC
  Future<void> _loadChatList() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await supabase.rpc('get_dosen_chat_list');

      if (!mounted) return;

      if (data is List) {
        setState(() {
          _chatList = List<Map<String, dynamic>>.from(data);
        });
      } else {
        setState(() {
          _chatList = [];
        });
      }
    } on PostgrestException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error memuat daftar chat: ${error.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan tak terduga: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // [NAVBAR] Implementasi Navigasi _onItemTapped
  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

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

  @override
  Widget build(BuildContext context) {
    // Logika Filtering
    final filteredChatList = _chatList.where((chat) {
      final name = (chat['mahasiswa_name'] as String).toLowerCase();
      final content = (chat['latest_message_content'] as String).toLowerCase();
      final query = _searchText.toLowerCase();

      // Filter berdasarkan nama mahasiswa atau isi pesan terakhir
      return name.contains(query) || content.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F), // Warna header
      body: Column(
        children: [
          // Header dan Search Bar (di dalam container biru)
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 15,
              left: 20,
              right: 20,
            ),
            color: const Color(0xFF1E3A5F),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Title/Brand Name (Diubah menjadi 'Lectalk')
                const Text(
                  'Lectalk',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 15),

                // 2. Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchText = value; // Update state untuk filtering
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari Mahasiswa atau Pesan...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF4A6FA5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body List Chat
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              // Menggunakan list yang sudah difilter
              child: _buildChatListBody(filteredChatList),
            ),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: _buildNavbar(context),
    );
  }

  // Widget untuk menampilkan list chat (menerima list yang sudah difilter)
  Widget _buildChatListBody(List<Map<String, dynamic>> listToShow) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Kasus 1: Tidak ada chat sama sekali
    if (_chatList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.forum_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 10),
            const Text(
              'Belum ada pesan. Mulai chat di tab Mahasiswa.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadChatList,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A5F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Kasus 2: Ada chat, tapi tidak ada yang cocok dengan pencarian
    if (listToShow.isEmpty && _searchText.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sentiment_dissatisfied,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            Text(
              'Tidak ditemukan chat untuk "$_searchText".',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Kasus 3: Menampilkan list yang difilter/lengkap
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: listToShow.length,
      itemBuilder: (context, index) {
        final chat = listToShow[index];
        return _buildChatCard(chat);
      },
    );
  }

  // Widget untuk satu item (kartu) chat
  Widget _buildChatCard(Map<String, dynamic> chat) {
    // ... (Kode _buildChatCard tidak berubah) ...
    final String name = chat['mahasiswa_name'] ?? 'Mahasiswa';
    final String nim =
        chat['mahasiswa_nim'] ?? 'NIM Tidak Tersedia'; // Ambil NIM dari RPC
    final String lastMessage =
        chat['latest_message_content'] ?? 'Belum ada pesan';
    final String? photoUrl = chat['mahasiswa_foto'];
    final bool isUnread =
        chat['is_read'] == false && chat['is_sender_me'] == false;

    // Format waktu
    final DateTime messageTime = DateTime.parse(
      chat['latest_message_time'],
    ).toLocal();
    final String formattedTime = DateFormat('jm').format(messageTime);

    return InkWell(
      onTap: () {
        // Navigasi ke halaman chat detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LecturerChatScreen(
              mahasiswaName: name,
              mahasiswaNIM: nim, // Kirim NIM yang sudah diambil dari RPC
              mahasiswaId: chat['user_id'],
              mahasiswaFoto: photoUrl,
            ),
          ),
        ).then((_) {
          _loadChatList();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: photoUrl != null && photoUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, color: Colors.grey),
                      ),
                    )
                  : const Icon(Icons.person, color: Colors.grey, size: 30),
            ),

            const SizedBox(width: 15),

            // Nama & Pesan Terakhir
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                      fontSize: 16,
                      color: const Color(0xFF1E3A5F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Indikator 'You:' jika pengirimnya adalah Dosen
                      if (chat['is_sender_me'] == true)
                        Text(
                          "Anda: ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                      // Isi Pesan Terakhir
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: TextStyle(
                            color: isUnread ? Colors.black87 : Colors.grey[600],
                            fontSize: 14,
                            fontWeight: isUnread
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Waktu dan Status Dibaca
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnread ? const Color(0xFF1E3A5F) : Colors.grey,
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 5),
                // Indikator Pesan Belum Dibaca
                if (isUnread)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E3A5F),
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // [NAVBAR] Helper method untuk Navbar
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

  // [NAVBAR] Widget Navbar Item
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
