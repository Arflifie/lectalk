import 'package:flutter/material.dart';

// Halaman Dummy untuk Profil
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: const Color(0xFF1E3A5F),
      ),
      body: const Center(child: Text("Ini Halaman Profil")),
    );
  }
}
