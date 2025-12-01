import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:lectalk/pages/chat.dart';
import 'package:lectalk/pages/chat_page.dart';
import 'package:lectalk/pages/lecturer_chat.dart';
import 'package:lectalk/pages/lecturer_chat_page.dart';
import 'package:lectalk/pages/login_student.dart';
import 'package:lectalk/pages/profil.dart';
import 'package:lectalk/pages/template_page.dart';
import 'package:lectalk/pages/contact_page.dart';
import 'package:lectalk/pages/landing.dart';
import 'package:lectalk/pages/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const MyApp());
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

      home: const LecturerDataPage(),
    );
  }
}
