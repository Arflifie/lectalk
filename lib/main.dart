import 'package:flutter/material.dart';
import 'package:lectalk/pages/landing.dart';
import 'package:lectalk/pages/dashboard.dart';
import 'package:lectalk/pages/chat_page.dart';
// import 'package:lectalk/pages/landing.dart';

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
      home: const ChatPage(),
    );
  }
}
