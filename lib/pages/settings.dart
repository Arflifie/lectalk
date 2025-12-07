import 'package:flutter/material.dart';
import 'package:lectalk/pages/mahasiswa/mahasiswa_profil.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false; // State untuk toggle Dark Mode

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF1E3A5F,
      ), // Warna background utama (Biru Tua)
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: Center(
              child: Text(
                'Setting',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w300, // Font tipis sesuai gambar
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(
                  0xFFF8F9FA,
                ), // Putih sedikit abu (off-white) biar lembut
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
                child: Column(
                  children: [
                    // 1. Profile Section
                    _buildProfileSection(context),

                    const SizedBox(height: 25),

                    // 2. Menu Group (Grey Box)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300], // Warna box abu-abu
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            Icons.person_outline_rounded,
                            'Personal information',
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            Icons.security_outlined,
                            'Login & security',
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            Icons.notifications_outlined,
                            'Notifications',
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            Icons.chat_bubble_outline_rounded,
                            'Chats',
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            Icons.language,
                            'App language',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 3. Dark Mode Toggle
                    _buildDarkModeToggle(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildProfileSection(BuildContext context) {
    return Column(
      children: [
        // Gunakan Material & InkWell agar ada efek klik (ripple)
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(
              15,
            ), // Sudut tumpul saat ditekan
            onTap: () {
              // Navigasi ke Halaman Profil
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 5.0,
              ),
              child: Row(
                children: [
                  // Foto Profil
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                      image: DecorationImage(
                        image: AssetImage('assets/profile_pic.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Nama & Link Profil
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Saya Budi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Show profil',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Icon Panah Kanan
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        // Garis Pembatas
        Divider(color: Colors.grey[400], thickness: 1),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {bool isLast = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              )
            : const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
        // Radius logic ini simpel, bisa disesuaikan jika item tengah diklik
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(
                icon,
                size: 28,
                color: const Color(0xFF1E3A5F),
              ), // Icon warna biru tua
              const SizedBox(width: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[400],
      indent: 20, // Memberi jarak dari kiri
      endIndent: 20, // Memberi jarak dari kanan
    );
  }

  Widget _buildDarkModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Icon Matahari/Bulan dalam lingkaran hitam (sesuai gambar)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.contrast, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 20),
            Text(
              'Darkmode',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        // Toggle Switch
        Switch(
          value: _isDarkMode,
          activeColor: const Color(0xFF1E3A5F),
          onChanged: (value) {
            setState(() {
              _isDarkMode = value;
            });
          },
        ),
      ],
    );
  }
}
