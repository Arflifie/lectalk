import 'package:flutter/material.dart';

class EditProfileDosenPage extends StatefulWidget {
  const EditProfileDosenPage({super.key});

  @override
  State<EditProfileDosenPage> createState() => _EditProfileDosenPageState();
}

class _EditProfileDosenPageState extends State<EditProfileDosenPage> {
  // Warna Utama
  static const Color primaryColor = Color(0xFF1E3A5F); // Biru Tua
  static const Color accentColor = Color(0xFF4A749B); // Biru Agak Soft

  // Controller dengan data awal sesuai gambar
  final TextEditingController _nameController = TextEditingController(
    text: "Erik Matahir",
  );
  final TextEditingController _idController = TextEditingController(
    text: "123474774",
  );
  final TextEditingController _facultyController = TextEditingController(
    text: "Sains and Technology",
  );
  final TextEditingController _studyController = TextEditingController(
    text: "Information System",
  );

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _facultyController.dispose();
    _studyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar
    final size = MediaQuery.of(context).size;
    final double headerHeight =
        size.height * 0.28; // Header dibuat sedikit lebih tinggi

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // --- 1. Header Area (Tombol Back & Judul) ---
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios, // Ikon lebih modern
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    // Judul dibuat lebih besar, bold, dan rata kiri
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'Edit Profil Dosen', // Judul lebih jelas
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- 2. White Body Container (Konten Form) ---
          Container(
            margin: EdgeInsets.only(top: headerHeight - 40),
            height: size.height - (headerHeight - 40),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                120, // Top padding lebih besar untuk foto
                20,
                20,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Agar form melebar penuh
                children: [
                  // Form Fields
                  _buildCustomTextField("Nama Dosen", _nameController),
                  const SizedBox(height: 20),
                  _buildCustomTextField("NIP", _idController, isNumeric: true),
                  const SizedBox(height: 20),
                  _buildCustomTextField("Fakultas", _facultyController),
                  const SizedBox(height: 20),
                  _buildCustomTextField("Program Studi", _studyController),

                  const SizedBox(height: 50),

                  // Save Button
                  SizedBox(
                    height: 55, // Tinggi tombol sedikit lebih besar
                    child: ElevatedButton(
                      onPressed: () {
                        // Logic Simpan Data
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            primaryColor, // Menggunakan warna biru tua yang kuat
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // Rounded lebih penuh
                        ),
                        elevation: 5,
                        shadowColor: primaryColor.withOpacity(0.4),
                      ),
                      child: const Text(
                        "Simpan Perubahan",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
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
                  width: 140, // Foto sedikit lebih besar
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300, // Warna abu-abu placeholder
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 5, // Border putih lebih tebal
                    ),
                    // Jika Anda sudah punya aset, ganti dengan Image.asset atau NetworkImage
                    image:
                        null, // Dihapus untuk menghindari error AssetNotFound
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 80,
                    color: Color(0xFF6C7E90),
                  ),
                ),
                // Ikon Kamera
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10), // Padding lebih besar
                    decoration: BoxDecoration(
                      color: accentColor, // Menggunakan warna aksen biru soft
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
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

  // --- Widget Helper untuk Input Field Custom (Diupgrade) ---
  Widget _buildCustomTextField(
    String label,
    TextEditingController controller, {
    bool isNumeric = false,
  }) {
    // Menggunakan FocusNode untuk mendeteksi fokus (efek modern)
    final FocusNode focusNode = FocusNode();

    // Memberi status fokus pada State
    bool isFocused = false;

    return StatefulBuilder(
      builder: (context, setInnerState) {
        focusNode.addListener(() {
          setInnerState(() {
            isFocused = focusNode.hasFocus;
          });
        });

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              // Border berubah warna ketika fokus
              color: isFocused ? primaryColor : Colors.grey.shade300,
              width: isFocused ? 2.0 : 1.0,
            ),
            boxShadow: [
              if (isFocused)
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label Kecil di Atas
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isFocused ? primaryColor : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Input Field
              TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: isNumeric
                    ? TextInputType.number
                    : TextInputType.text,
                style: const TextStyle(
                  fontSize: 17, // Ukuran font sedikit diperbesar
                  fontWeight: FontWeight.w700, // Teks input lebih tebal
                  color: Color(0xFF333333),
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.only(top: 4, bottom: 4),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
