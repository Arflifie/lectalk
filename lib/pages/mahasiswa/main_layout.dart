import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import halaman-halaman
import 'package:lectalk/pages/mahasiswa/mahasiswa_chat_page.dart';
import 'package:lectalk/pages/mahasiswa/mahasiswa_contact_dosen.dart';
import 'package:lectalk/pages/mahasiswa/mahasiswa_template_page.dart';
import 'package:lectalk/pages/mahasiswa/mahasiswa_profil.dart';

final supabase = Supabase.instance.client;

// ============================================
// PROVIDER: Foto Profil Mahasiswa (DIPERBAIKI)
// ============================================
final mahasiswaPhotoProvider = FutureProvider.autoDispose<String?>((ref) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return null;

  try {
    final data = await supabase
        .from('mahasiswa')  // FIXED: Ganti dari mahasiswa_profile ke mahasiswa
        .select('foto_mahasiswa')
        .eq('id', userId)
        .maybeSingle();

    return data?['foto_mahasiswa'] as String?;
  } catch (e) {
    return null;
  }
});

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ChatPage(),
    const LecturerDataPage(),
    const TemplatePage(),
  ];

  // Judul untuk setiap tab
  final List<String> _pageTitles = [
    'Messages',
    'Lecturer Data',
    'Template',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch foto profil mahasiswa
    final photoAsync = ref.watch(mahasiswaPhotoProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          _pageTitles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // FOTO PROFIL BUTTON (DIPERBAIKI)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                // Navigasi ke halaman profil
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                ).then((_) {
                  // Refresh foto setelah kembali dari profil
                  ref.invalidate(mahasiswaPhotoProvider);
                });
              },
              child: photoAsync.when(
                // Data berhasil dimuat
                data: (photoUrl) => _buildProfileAvatar(photoUrl),
                // Loading
                loading: () => _buildLoadingAvatar(),
                // Error
                error: (_, __) => _buildDefaultAvatar(),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
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
              ),
              _buildNavItem(
                icon: Icons.school_rounded,
                label: 'Lecturer',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.dashboard_customize_rounded,
                label: 'Template',
                index: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // WIDGET: Profile Avatar dengan Foto (DIPERBAIKI)
  // ============================================
  Widget _buildProfileAvatar(String? photoUrl) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: const Color(0xFF6C7E90),
        backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) 
            ? NetworkImage(photoUrl) 
            : null,
        child: (photoUrl == null || photoUrl.isEmpty)
            ? const Icon(
                Icons.person,
                color: Colors.white,
                size: 22,
              )
            : null,
        onBackgroundImageError: (photoUrl != null && photoUrl.isNotEmpty)
            ? (exception, stackTrace) {
                // Handle error loading image
              }
            : null,
      ),
    );
  }

  // ============================================
  // WIDGET: Loading Avatar
  // ============================================
  Widget _buildLoadingAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: const CircleAvatar(
        radius: 18,
        backgroundColor: Color(0xFF6C7E90),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  // ============================================
  // WIDGET: Default Avatar (Error/No Photo)
  // ============================================
  Widget _buildDefaultAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: const CircleAvatar(
        radius: 18,
        backgroundColor: Color(0xFF6C7E90),
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  // ============================================
  // WIDGET: Bottom Nav Item
  // ============================================
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
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