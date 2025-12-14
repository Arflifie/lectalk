import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lectalk/pages/dosen/dosen_chat_page.dart';
import 'package:lectalk/pages/mahasiswa/main_layout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class LoginScreen extends StatefulWidget {
  // Tetap support key lama
  const LoginScreen(Key? key) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Dialog Error
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Login Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C4A6B),
      // [PENTING] Pastikan ini true agar layout naik saat keyboard muncul
      resizeToAvoidBottomInset: true,

      // GestureDetector: Menutup keyboard saat klik area kosong
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          // CustomScrollView dengan Slivers adalah solusi layout paling stabil
          slivers: [
            // 1. BAGIAN ATAS (Header & Gambar)
            // Menggunakan SliverToBoxAdapter karena ini konten statis
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Back button
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 8),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Illustration
                    SizedBox(
                      height: 260,
                      child: Center(
                        child: Image.asset(
                          "assets/images/student.png",
                          width: 300,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // 2. BAGIAN BAWAH (Form Putih)
            // SliverFillRemaining otomatis mengisi sisa layar
            // hasScrollBody: false -> Kunci agar layout tidak pecah saat keyboard muncul
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFDFDFD),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 40,
                  ),
                  child: Column(
                    // MainAxisAlignment.start agar form mulai dari atas kotak putih
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Email Field
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.person_outline),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Color(0xFF4A6FA5),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Color(0xFFBEBEBE),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Color(0xFF4A6FA5),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Color(0xFFBEBEBE),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () async {
                            // ... LOGIKA LOGIN ANDA TETAP SAMA ...
                            _handleLogin();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A6FA5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Spacer bawah (opsional) agar tidak terlalu mepet bawah saat keyboard tutup
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi Login (Saya pindahkan kesini biar rapi)
  Future<void> _handleLogin() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Email dan password tidak boleh kosong.");
      return;
    }

    if (!email.contains("@")) {
      _showError("Format email tidak valid.");
      return;
    }

    if (password.length < 8) {
      _showError("Password minimal 8 karakter.");
      return;
    }

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        _showError("Login gagal.");
        return;
      }

      final data = await supabase
          .from('user_profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        _showError("Role tidak ditemukan.");
        return;
      }

      final role = data['role'];

      if (!mounted) return;

      if (role == "mahasiswa") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
      } else if (role == "dosen") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LecturerChatPage()),
        );
      } else {
        _showError("Role tidak dikenali: $role");
      }
    } catch (e) {
      if (e.toString().contains("invalid_credentials")) {
        _showError("Email atau password salah.");
      } else {
        _showError("Terjadi kesalahan sistem.");
      }
    }
  }
}
