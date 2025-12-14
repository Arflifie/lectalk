import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lectalk/pages/dosen/dosen_chat_page.dart';
import 'package:lectalk/pages/mahasiswa/main_layout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mengambil Instance Supabase Client
final supabase = Supabase.instance.client;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Tambahan loading indicator biar UX lebih bagus

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

  // --- LOGIKA LOGIN (Dipisah supaya rapi) ---
  Future<void> _handleLogin() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validasi Input
    if (email.isEmpty || password.isEmpty) {
      _showError("Email dan password tidak boleh kosong.");
      return;
    }
    if (!email.contains("@")) {
      _showError("Format email tidak valid.");
      return;
    }
    if (password.length < 6) {
      // Biasanya minimal 6 di Supabase
      _showError("Password terlalu pendek.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Login ke Supabase Auth
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw "User tidak ditemukan.";
      }

      // 3. Ambil Role dari tabel user_profiles
      final data = await supabase
          .from('user_profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      if (data == null) {
        _showError(
          "Profil user tidak ditemukan di database. (Cek tabel user_profiles)",
        );
        return;
      }

      final role = data['role'];

      // 4. Navigasi Sesuai Role
      if (role == "mahasiswa") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
      } else if (role == "dosen") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LecturerChatPage()),
        );
      } else {
        _showError("Role tidak dikenali: $role");
      }
    } catch (e) {
      // Debugging Error
      debugPrint("🔥🔥 ERROR LOGIN: $e");

      if (mounted) {
        if (e.toString().contains("invalid_credentials")) {
          _showError("Email atau password salah.");
        } else if (e.toString().contains("Email not confirmed")) {
          _showError("Email belum diverifikasi. Cek inbox email Anda.");
        } else {
          _showError("Gagal login: ${e.toString()}");
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UI UTAMA ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C4A6B),
      // LayoutBuilder + SingleScrollView + IntrinsicHeight
      // Kombinasi ini membuat desain Full Height tapi aman saat keyboard muncul
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // --- BAGIAN ATAS (Back Button & Gambar) ---
                    SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          // Back Button
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

                    // --- BAGIAN BAWAH (Form Putih - Expanded) ---
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
                              // Title
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
                                keyboardType: TextInputType.emailAddress,
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
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A6FA5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
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

                              const SizedBox(height: 20), // Spacer bawah
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
