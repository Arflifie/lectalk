import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controller dengan data awal sesuai gambar
  final TextEditingController _nameController = TextEditingController(
    text: "Taufiqurahman",
  );
  final TextEditingController _idController = TextEditingController(
    text: "F1E130500",
  );
  final TextEditingController _instituteController = TextEditingController(
    text: "Universitas Jambi",
  );
  final TextEditingController _facultyController = TextEditingController(
    text: "Sains and Technology",
  );
  final TextEditingController _studyController = TextEditingController(
    text: "Information System",
  );
  final TextEditingController _yearController = TextEditingController(
    text: "2030",
  );

  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar
    final size = MediaQuery.of(context).size;
    final double headerHeight = size.height * 0.25; // Tinggi header biru

    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F), // Background Biru Tua
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // --- 1. Header Area (Tombol Back & Teks Profil) ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'Profil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- 2. White Body Container ---
          Container(
            margin: EdgeInsets.only(
              top: headerHeight - 40,
            ), // Naik sedikit agar rounded terlihat
            height: size.height,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                25,
                80,
                25,
                30,
              ), // Top padding besar untuk foto
              child: Column(
                children: [
                  // Form Fields
                  _buildCustomTextField("Name", _nameController),
                  const SizedBox(height: 15),
                  _buildCustomTextField("ID", _idController),
                  const SizedBox(height: 15),
                  _buildCustomTextField("Institute", _instituteController),
                  const SizedBox(height: 15),
                  _buildCustomTextField("Faculty", _facultyController),
                  const SizedBox(height: 15),
                  _buildCustomTextField("Study Program", _studyController),
                  const SizedBox(height: 15),
                  _buildCustomTextField("Admission Year", _yearController),

                  const SizedBox(height: 40),

                  // Save Button
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Logic Simpan Data
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF4A749B,
                        ), // Warna biru agak soft sesuai gambar
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 3. Profile Picture & Camera Icon ---
          Positioned(
            top: headerHeight - 90, // Posisi menumpuk garis batas
            child: Stack(
              children: [
                // Foto Lingkaran
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ), // Border putih tebal
                    image: const DecorationImage(
                      image: AssetImage(
                        'assets/profile_pic.png',
                      ), // Ganti aset Anda
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Ikon Kamera
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF6C7E90,
                      ), // Warna abu-biru icon kamera
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Helper untuk Input Field Custom ---
  Widget _buildCustomTextField(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade500,
          width: 1.5,
        ), // Border abu-abu tegas
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label Kecil di Atas
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Input Field
          TextField(
            controller: controller,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold, // Teks input tebal sesuai gambar
              color: Color(0xFF333333),
            ),
            decoration: const InputDecoration(
              isDense: true, // Merapatkan jarak vertikal
              contentPadding: EdgeInsets.only(top: 4, bottom: 4),
              border: InputBorder.none, // Hilangkan border bawaan TextField
            ),
          ),
        ],
      ),
    );
  }
}
