import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final supabase = Supabase.instance.client;

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const Color primaryColor = Color(0xFF1E3A5F);
  static const Color accentColor = Color(0xFF4A749B);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _facultyController = TextEditingController();
  final TextEditingController _studyController = TextEditingController();

  // State untuk foto
  XFile? _pickedFile;
  Uint8List? _pickedImageBytes;
  String? _currentPhotoUrl;
  bool _isLoading = false;
  bool _photoDeleted = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _facultyController.dispose();
    _studyController.dispose();
    super.dispose();
  }

  // Load Profile
  Future<void> _loadProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      final data = await supabase
          .from('mahasiswa')
          .select(
            'nama_mahasiswa, nim, fakultas, prodi, foto_mahasiswa',
          )
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        _nameController.text = data['nama_mahasiswa'] ?? '';
        _nimController.text = data['nim'] ?? '';
        _facultyController.text = data['fakultas'] ?? '';
        _studyController.text = data['prodi'] ?? '';
        _currentPhotoUrl = data['foto_mahasiswa'];
      }
    } catch (e) {
      _showSnackBar("Gagal memuat data profil.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Show Photo Options Modal
  void _showPhotoOptions() {
    final bool hasPhoto = (_pickedFile != null || 
                          (_currentPhotoUrl != null && !_photoDeleted));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Foto Profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ),

              // Options
              if (hasPhoto) ...[
                // View Photo
                _buildModalOption(
                  icon: Icons.remove_red_eye_outlined,
                  label: 'Lihat Foto',
                  onTap: () {
                    Navigator.pop(context);
                    _viewPhoto();
                  },
                ),
                const Divider(height: 1),

                // Change Photo
                _buildModalOption(
                  icon: Icons.photo_camera_outlined,
                  label: 'Ganti Foto',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                const Divider(height: 1),

                // Remove Photo
                _buildModalOption(
                  icon: Icons.delete_outline,
                  label: 'Hapus Foto',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _deletePhoto();
                  },
                ),
              ] else ...[
                // Upload Photo (jika tidak ada foto)
                _buildModalOption(
                  icon: Icons.add_photo_alternate_outlined,
                  label: 'Upload Foto',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
              ],

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // View Photo Fullscreen
  void _viewPhoto() {
    String? photoUrl;
    Widget? photoWidget;

    if (_pickedFile != null) {
      if (kIsWeb && _pickedImageBytes != null) {
        photoWidget = Image.memory(_pickedImageBytes!, fit: BoxFit.contain);
      } else if (!kIsWeb) {
        photoWidget = Image.file(File(_pickedFile!.path), fit: BoxFit.contain);
      }
    } else if (_currentPhotoUrl != null) {
      photoUrl = _currentPhotoUrl;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: photoWidget ??
                  (photoUrl != null
                      ? Image.network(photoUrl, fit: BoxFit.contain)
                      : const Icon(Icons.person, size: 100, color: Colors.white)),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pick Image
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
        _photoDeleted = false;

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

  // Delete Photo
  void _deletePhoto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Foto Profil'),
        content: const Text('Apakah Anda yakin ingin menghapus foto profil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _pickedFile = null;
                _pickedImageBytes = null;
                _currentPhotoUrl = null;
                _photoDeleted = true;
              });
              Navigator.pop(context);
              _showSnackBar('Foto profil akan dihapus saat menyimpan', isError: false);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Upload Photo
  Future<String?> _uploadPhoto(dynamic fileOrBytes, String userId) async {
    try {
      final fileExt = kIsWeb
          ? _pickedFile!.name.split('.').last
          : (fileOrBytes as File).path.split('.').last;

      final fileName = '$userId.$fileExt';
      final filePath = 'mahasiswa_photos/$fileName';

      await supabase.storage.from('image_mahasiswa').uploadBinary(
            filePath,
            fileOrBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final publicUrl =
          supabase.storage.from('image_mahasiswa').getPublicUrl(filePath);
      return publicUrl;
    } on StorageException catch (e) {
      _showSnackBar("Gagal mengunggah foto (Storage Error: ${e.message}).");
      return null;
    } catch (e) {
      _showSnackBar("Gagal mengunggah foto: ${e.toString()}");
      return null;
    }
  }

  // Upsert Profile
  Future<void> _upsertProfile(String? photoUrl) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      _showSnackBar("Autentikasi gagal. Silakan login kembali.");
      return;
    }

    final Map<String, dynamic> dataToUpsert = {
      'id': userId,
      'nama_mahasiswa': _nameController.text.trim(),
      'nim': _nimController.text.trim(),
      'fakultas': _facultyController.text.trim(),
      'prodi': _studyController.text.trim(),
    };

    if (_photoDeleted) {
      dataToUpsert['foto_mahasiswa'] = null as dynamic;
    } else if (photoUrl != null) {
      dataToUpsert['foto_mahasiswa'] = photoUrl;
    }

    try {
      await supabase.from('mahasiswa').upsert(dataToUpsert);
      _showSnackBar("Profil berhasil diperbarui!", isError: false);
      
      if (_photoDeleted) {
        setState(() => _currentPhotoUrl = null);
      } else if (photoUrl != null) {
        setState(() => _currentPhotoUrl = photoUrl);
      }
      
      Navigator.pop(context);
    } on PostgrestException catch (e) {
      String errorMessage = "Gagal menyimpan data: ${e.message}";
      if (e.code == '23505') {
        errorMessage = "NIM yang Anda masukkan sudah digunakan.";
      } else if (e.code == '23502') {
        errorMessage = "Gagal: Pastikan semua kolom terisi dengan benar.";
      }
      _showSnackBar(errorMessage);
    } catch (e) {
      _showSnackBar("Terjadi kesalahan tak terduga saat menyimpan data.");
    }
  }

  // Handle Save
  Future<void> _handleSave() async {
    if (_nameController.text.trim().isEmpty ||
        _nimController.text.trim().isEmpty ||
        _facultyController.text.trim().isEmpty ||
        _studyController.text.trim().isEmpty) {
      _showSnackBar(
        "Mohon lengkapi semua data profil (Nama, NIM, Fakultas, Prodi).",
      );
      return;
    }

    setState(() => _isLoading = true);

    String? photoUrl;

    if (_pickedFile != null && !_photoDeleted) {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final fileData = kIsWeb ? _pickedImageBytes! : File(_pickedFile!.path);

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

  // Show SnackBar
  void _showSnackBar(String message, {bool isError = true}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Colors.red.shade700 : Colors.green.shade700,
        ),
      );
    }
  }

  // Modal Option Item
  Widget _buildModalOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.grey[700], size: 26),
            const SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: color ?? Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom TextField
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
                keyboardType:
                    isNumeric ? TextInputType.number : TextInputType.text,
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
    final double headerHeight = size.height * 0.25;

    // Profile Image Widget
    Widget profileImageWidget;

    if (_photoDeleted) {
      profileImageWidget = const Icon(
        Icons.person_rounded,
        size: 80,
        color: Color(0xFF6C7E90),
      );
    } else if (_pickedFile != null) {
      if (kIsWeb && _pickedImageBytes != null) {
        profileImageWidget = Image.memory(
          _pickedImageBytes!,
          fit: BoxFit.cover,
          width: 130,
          height: 130,
        );
      } else if (!kIsWeb) {
        profileImageWidget = Image.file(
          File(_pickedFile!.path),
          fit: BoxFit.cover,
          width: 130,
          height: 130,
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
        width: 130,
        height: 130,
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

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          // Header Area
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
                        'Edit Profil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
            ),
          ),

          // White Body Container
          Positioned.fill(
            top: headerHeight - 40,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 90, 25, 30),
                child: Column(
                  children: [
                    // Form Fields
                    _buildCustomTextField("Nama Lengkap", _nameController),
                    const SizedBox(height: 15),
                    _buildCustomTextField("NIM", _nimController, isNumeric: true),
                    const SizedBox(height: 15),
                    _buildCustomTextField("Fakultas", _facultyController),
                    const SizedBox(height: 15),
                    _buildCustomTextField("Program Studi", _studyController),

                    const SizedBox(height: 40),

                    // Save Button
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Simpan",
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
          ),

          // Profile Picture (Clickable) - CENTERED
          Positioned(
            top: headerHeight - 65,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _showPhotoOptions,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Foto
                        profileImageWidget,
                        
                        // Overlay dengan icon edit (hanya saat pressed)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _showPhotoOptions,
                            customBorder: const CircleBorder(),
                            splashColor: Colors.black.withOpacity(0.2),
                            highlightColor: Colors.black.withOpacity(0.1),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}