import 'package:flutter/material.dart';
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

void main() {
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

      home: const LecturerChatScreen(),
    );
  }
}
