import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lectalk/pages/dosen/dosen_chat_page.dart';
// import 'package:lectalk/pages/mahasiswa/mahasiswa_chat_page.dart';
import 'package:lectalk/pages/mahasiswa/main_layout.dart';

// Import bagian Supabase
import 'package:supabase_flutter/supabase_flutter.dart';

// Mengmabil And Point Supabase CLient suapya bisa terhubung ke supabase
final supabase = Supabase.instance.client;

class LoginScreen extends StatefulWidget {
  // Tetap menggunakan format lama agar kompatibel dengan 'LoginScreen(null)'
  const LoginScreen(Key? key) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Validasi Form menggunakan Alert Dialog
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
      // PERBAIKAN: Gunakan LayoutBuilder untuk mendeteksi tinggi layar
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            // PERBAIKAN: SingleChildScrollView agar bisa digeser saat keyboard muncul
            child: ConstrainedBox(
              constraints: BoxConstraints(
                // Memastikan tinggi minimal konten = tinggi layar (agar Full Screen)
                minHeight: constraints.maxHeight,
              ),
              // PERBAIKAN: IntrinsicHeight agar widget Expanded bisa bekerja dalam ScrollView
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // --- Bagian Header (Back Button & Gambar) ---
                    SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          // Back button
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 8),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
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

                          // Illustration (center)
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

                    // --- FORM CARD (Expanded) ---
                    // Expanded akan mengisi sisa ruang ke bawah
                    Expanded(
                      child: Container(
                        width: double.infinity,
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // TITLE
                              const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Username Field
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
                                    final email = _usernameController.text
                                        .trim();
                                    final password = _passwordController.text
                                        .trim();

                                    // Validasi 1: input tidak boleh kosong
                                    if (email.isEmpty || password.isEmpty) {
                                      _showError(
                                        "Email dan password tidak boleh kosong.",
                                      );
                                      return;
                                    }

                                    // Validasi 2: email harus format benar
                                    if (!email.contains("@")) {
                                      _showError("Format email tidak valid.");
                                      return;
                                    }

                                    // Validasi 3: password minimal 8 karakter
                                    if (password.length < 8) {
                                      _showError(
                                        "Password minimal 8 karakter.",
                                      );
                                      return;
                                    }

                                    try {
                                      // Login ke Supabase
                                      final response = await supabase.auth
                                          .signInWithPassword(
                                            email: email,
                                            password: password,
                                          );

                                      final user = response.user;

                                      if (user == null) {
                                        _showError(
                                          "Login gagal. Periksa email dan password.",
                                        );
                                        return;
                                      }

                                      // Ambil role dari user_profiles
                                      final data = await supabase
                                          .from('user_profiles')
                                          .select('role')
                                          .eq('id', user.id)
                                          .maybeSingle();

                                      if (data == null) {
                                        _showError(
                                          "Role tidak ditemukan untuk user ini.",
                                        );
                                        return;
                                      }

                                      // Mengmabil Role
                                      final role = data['role'];

                                      // Arahkan sesuai role
                                      if (role == "mahasiswa") {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const MainLayout(),
                                          ),
                                        );
                                      } else if (role == "dosen") {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => LecturerChatPage(),
                                          ),
                                        );
                                      } else {
                                        _showError(
                                          "Role tidak dikenali: $role",
                                        );
                                      }
                                    } catch (e) {
                                      if (e.toString().contains(
                                        "invalid_credentials",
                                      )) {
                                        _showError(
                                          "Email atau password salah.",
                                        );
                                      } else {
                                        _showError(
                                          "Terjadi kesalahan. Coba lagi nanti.",
                                        );
                                      }
                                    }
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
                                      letterSpacing: 0.3,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 35),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
