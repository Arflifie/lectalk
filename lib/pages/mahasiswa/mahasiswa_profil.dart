import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lectalk/pages/mahasiswa/mahasiswa_profil_edit.dart';
import 'package:lectalk/pages/auth/login_page.dart';

final supabase = Supabase.instance.client;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // State untuk Data Profil
  Map<String, dynamic>? _mahasiswaProfile;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Fungsi untuk Mengambil Data Profil
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
          .from('mahasiswa')
          .select('nama_mahasiswa, nim, prodi, fakultas, foto_mahasiswa')
          .eq('id', userId)
          .maybeSingle();

      setState(() {
        _mahasiswaProfile = data;
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

  // Fungsi untuk menampilkan dialog konfirmasi logout
  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User harus pilih salah satu opsi
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Konfirmasi Logout',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari akun?',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            // Tombol Cancel
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Tombol Logout
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                _handleLogout(); // Proses logout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31009),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menangani Logout
  Future<void> _handleLogout() async {
    try {
      // Logout dari Supabase
      await supabase.auth.signOut();

      // Pastikan widget masih ada sebelum menggunakan context
      if (!mounted) return;

      // Arahkan pengguna ke halaman LoginScreen, hapus semua route sebelumnya
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen(null)),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Tangani error jika gagal logout
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal logout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Tampilkan Loading
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E3A5F),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // Tampilkan Error jika ada
    if (_error.isNotEmpty && _mahasiswaProfile == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E3A5F),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadProfileData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // Default values
    final namaMahasiswa =
        _mahasiswaProfile?['nama_mahasiswa'] ?? 'Nama Belum Diisi';
    final nimMahasiswa = _mahasiswaProfile?['nim'] ?? 'NIM Belum Diisi';
    final prodiMahasiswa = _mahasiswaProfile?['prodi'] ?? 'Prodi Belum Diisi';
    final fakultasMahasiswa =
        _mahasiswaProfile?['fakultas'] ?? 'Fakultas Belum Diisi';
    final fotoMahasiswaUrl = _mahasiswaProfile?['foto_mahasiswa'];

    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Decoration
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

            // Header (Back Button & Title)
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

            // Body Content
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: size.height * 0.72,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
              ),
            ),

            // Cards & Profile Picture
            Positioned.fill(
              top: size.height * 0.18,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Column(
                        children: [
                          // KARTU 1: DATA MAHASISWA (Biru Gelap)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
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
                                Text(
                                  namaMahasiswa,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  nimMahasiswa,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const SizedBox(height: 25),
                                const Text(
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

                          // KARTU 2: UNIVERSITAS (Putih)
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                Divider(
                                  color: Colors.grey[400],
                                  thickness: 1.5,
                                ),
                                const SizedBox(height: 15),
                                // Prodi
                                Text(
                                  prodiMahasiswa,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF555555),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                // Fakultas
                                Text(
                                  fakultasMahasiswa,
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

                          // TOMBOL BAWAH (Logout & Edit)
                          Row(
                            children: [
                              // Tombol Logout
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _showLogoutDialog,
                                  icon: const Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Logout',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE31009),
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
                                  ).then((_) => _loadProfileData());
                                },
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5F7C8E),
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
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),

                    // FOTO PROFIL (Overlay)
                    Positioned(
                      top: 0,
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
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6C7E90),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: fotoMahasiswaUrl != null
                                ? Image.network(
                                    fotoMahasiswaUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          );
                                        },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
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
