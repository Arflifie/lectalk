import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Impor kIsWeb

final supabase = Supabase.instance.client;

class EditProfileDosenPage extends StatefulWidget {
  const EditProfileDosenPage({super.key});

  @override
  State<EditProfileDosenPage> createState() => _EditProfileDosenPageState();
}

class _EditProfileDosenPageState extends State<EditProfileDosenPage> {
  static const Color primaryColor = Color(0xFF1E3A5F);
  static const Color accentColor = Color(0xFF4A749B);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _facultyController = TextEditingController();
  final TextEditingController _studyController = TextEditingController();

  // State baru untuk foto
  XFile? _pickedFile;
  Uint8List? _pickedImageBytes; // Untuk web display
  String? _currentPhotoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _facultyController.dispose();
    _studyController.dispose();
    super.dispose();
  }

  // --- LOGIC UTAMA ---

  Future<void> _loadProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);
    // ... (logic load profile sama)
    try {
      final data = await supabase
          .from('dosen_profile')
          .select(
            'nama_dosen, nip_dosen, fakultas_dosen, prodi_dosen, foto_dosen',
          )
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        _nameController.text = data['nama_dosen'] ?? '';
        _idController.text = data['nip_dosen'] ?? '';
        _facultyController.text = data['fakultas_dosen'] ?? '';
        _studyController.text = data['prodi_dosen'] ?? '';
        _currentPhotoUrl = data['foto_dosen'];
      }
    } catch (e) {
      _showSnackBar("Gagal memuat data profil.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // REVISI: Menggunakan XFile dan membaca bytes untuk web
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1000,
      maxHeight: 1000,
    );

    if (picked != null) {
      setState(() {
        _pickedFile = picked;

        if (kIsWeb) {
          picked.readAsBytes().then((bytes) {
            setState(() {
              _pickedImageBytes = bytes;
            });
          });
        }
      });
    }
  }

  // REVISI: Menerima data dinamis (File atau Uint8List)
  Future<String?> _uploadPhoto(dynamic fileOrBytes, String userId) async {
    try {
      final fileExt = kIsWeb
          ? _pickedFile!.name.split('.').last
          : (fileOrBytes as File).path.split('.').last;

      final fileName = '$userId.$fileExt';
      final filePath = 'dosen_photos/$fileName';

      // Menggunakan uploadBinary yang mendukung File (Mobile) dan Uint8List (Web)
      await supabase.storage
          .from('image_dosen')
          .uploadBinary(
            filePath,
            fileOrBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final publicUrl = supabase.storage
          .from('image_dosen')
          .getPublicUrl(filePath);
      return publicUrl;
    } on StorageException catch (e) {
      _showSnackBar("Gagal mengunggah foto (Storage Error: ${e.message}).");
      return null;
    } catch (e) {
      _showSnackBar("Gagal mengunggah foto: ${e.toString()}");
      return null;
    }
  }

  // ... (_upsertProfile tidak berubah) ...

  Future<void> _upsertProfile(String? photoUrl) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      _showSnackBar("Autentikasi gagal. Silakan login kembali.");
      return;
    }
    final dataToUpsert = {
      'id': userId,
      'nama_dosen': _nameController.text.trim(),
      'nip_dosen': _idController.text.trim(),
      'fakultas_dosen': _facultyController.text.trim(),
      'prodi_dosen': _studyController.text.trim(),
      if (photoUrl != null) 'foto_dosen': photoUrl,
    };
    try {
      await supabase.from('dosen_profile').upsert(dataToUpsert);
      _showSnackBar("Profil berhasil diperbarui!", isError: false);
      if (photoUrl != null) {
        setState(() => _currentPhotoUrl = photoUrl);
      }
      Navigator.pop(context);
    } on PostgrestException catch (e) {
      // ... (Error handling sama)
      String errorMessage = "Gagal menyimpan data: ${e.message}";
      if (e.code == '23505') {
        errorMessage =
            "NIP yang Anda masukkan sudah digunakan oleh dosen lain.";
      } else if (e.code == '23502') {
        errorMessage = "Gagal: Pastikan semua kolom terisi dengan benar.";
      }
      _showSnackBar(errorMessage);
    } catch (e) {
      _showSnackBar("Terjadi kesalahan tak terduga saat menyimpan data.");
    }
  }

  // REVISI: Menggunakan _pickedFile
  Future<void> _handleSave() async {
    if (_nameController.text.trim().isEmpty ||
        _idController.text.trim().isEmpty ||
        _facultyController.text.trim().isEmpty ||
        _studyController.text.trim().isEmpty) {
      _showSnackBar(
        "Mohon lengkapi semua data profil (Nama, NIP, Fakultas, Prodi).",
      );
      return;
    }

    setState(() => _isLoading = true);

    String? photoUrl;

    if (_pickedFile != null) {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        // Tentukan data yang akan diupload
        final fileData = kIsWeb
            ? _pickedImageBytes! // Uint8List untuk Web
            : File(_pickedFile!.path); // File untuk Mobile

        photoUrl = await _uploadPhoto(fileData, userId);
        if (photoUrl == null) {
          setState(() => _isLoading = false);
          return;
        }
      }
    }

    await _upsertProfile(photoUrl);
    setState(() => _isLoading = false);
  }

  // --- WIDGETS & BUILD METHOD ---

  // Helper untuk menampilkan notifikasi
  void _showSnackBar(String message, {bool isError = true}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? Colors.red.shade700
              : Colors.green.shade700,
        ),
      );
    }
  }

  // --- Widget Helper untuk Input Field Custom (Sama seperti sebelumnya) ---
  Widget _buildCustomTextField(
    String label,
    TextEditingController controller, {
    bool isNumeric = false,
  }) {
    final FocusNode focusNode = FocusNode();
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
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isFocused ? primaryColor : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: isNumeric
                    ? TextInputType.number
                    : TextInputType.text,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double headerHeight = size.height * 0.28;

    // REVISI UTAMA: Logika Widget Gambar
    Widget profileImageWidget;

    if (_pickedFile != null) {
      if (kIsWeb && _pickedImageBytes != null) {
        profileImageWidget = Image.memory(
          _pickedImageBytes!,
          fit: BoxFit.cover,
        );
      } else if (!kIsWeb) {
        profileImageWidget = Image.file(
          File(_pickedFile!.path),
          fit: BoxFit.cover,
        );
      } else {
        profileImageWidget = const Icon(
          Icons.person_rounded,
          size: 80,
          color: Color(0xFF6C7E90),
        );
      }
    } else if (_currentPhotoUrl != null) {
      profileImageWidget = Image.network(
        _currentPhotoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.person_rounded,
          size: 80,
          color: Color(0xFF6C7E90),
        ),
      );
    } else {
      profileImageWidget = const Icon(
        Icons.person_rounded,
        size: 80,
        color: Color(0xFF6C7E90),
      );
    }

    // ... (rest of the build method is largely the same, but now uses profileImageWidget) ...

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // ... (Header Area) ...
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
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'Edit Profil Dosen',
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
                30,
                120, // Top padding untuk memberi ruang foto
                30,
                30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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

                  // --- Save Button (Diperbarui dengan logic Save) ---
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        shadowColor: primaryColor.withOpacity(0.4),
                      ),
                      child: _isLoading
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : const Text(
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

          // --- 3. Profile Picture & Camera Icon (Menggunakan profileImageWidget) ---
          Positioned(
            top: headerHeight - 90,
            child: Stack(
              children: [
                // Foto Lingkaran
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 5),
                  ),
                  child: ClipOval(
                    child: profileImageWidget, // Widget Gambar Dinamis
                  ),
                ),
                // Ikon Kamera (Tombol Pemilih Gambar)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
