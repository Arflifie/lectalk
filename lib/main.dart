import 'package:flutter/material.dart';
// import 'package:lectalk/pages/dosen/dosen_chat_page.dart';
import 'package:lectalk/pages/landing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//halaman mahasiswa dan dosen
import 'package:lectalk/pages/dosen/dosen_chat_page.dart';
import 'package:lectalk/pages/mahasiswa/main_layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lectalk',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
      ),

      home: const AuthCheck(),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final supabase = Supabase.instance.client;

    // 1. Cek ada sesi tersimpan di HP?
    final session = supabase.auth.currentSession;

    await Future.delayed(const Duration(milliseconds: 100));

    if (session == null) {
      // jika tidak ada sesi
      _navigate(const LandingScreen());
    } else {
      // jika ada sesi
      _checkRoleAndNavigate(session.user.id);
    }
  }

  Future<void> _checkRoleAndNavigate(String userId) async {
    final supabase = Supabase.instance.client;

    try {
      // Ambil role dari tabel user_profiles
      final data = await supabase
          .from('user_profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        final role = data['role'];
        if (role == 'mahasiswa') {
          _navigate(const MainLayout());
        } else if (role == 'dosen') {
          _navigate(const LecturerChatPage());
        } else {
          _navigate(const LandingScreen());
        }
      } else {
        _navigate(const LandingScreen());
      }
    } catch (e) {
      debugPrint("Error check role: $e");
      _navigate(const LandingScreen());
    }
  }

  void _navigate(Widget screen) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan splash
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
