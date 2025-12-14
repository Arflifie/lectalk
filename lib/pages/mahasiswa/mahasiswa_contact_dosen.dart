import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lectalk/pages/mahasiswa/mahasiswa_chatting.dart'; // Pastikan import ini benar

// 1. PROVIDER: Ambil data dari tabel 'dosen_profile' sesuai schema
final lecturersProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final supabase = Supabase.instance.client;

      // Mengambil data langsung dari tabel khusus dosen
      final response = await supabase
          .from('dosen_profile')
          .select()
          .order('nama_dosen'); // Urutkan berdasarkan nama abjad

      return List<Map<String, dynamic>>.from(response);
    });

class LecturerDataPage extends ConsumerStatefulWidget {
  const LecturerDataPage({super.key});

  @override
  ConsumerState<LecturerDataPage> createState() => _LecturerDataPageState();
}

class _LecturerDataPageState extends ConsumerState<LecturerDataPage> {
  int _selectedFilterIndex = 0;
  String _searchQuery = "";

  // List Filter Prodi (Sesuaikan dengan data di database Anda)
  final List<String> _filters = [
    'All',
    'Sistem Informasi',
    'Teknik Informatika',
    'Manajemen',
    'Ilmu Hukum',
    // Tambahkan prodi lain sesuai kebutuhan
  ];

  @override
  Widget build(BuildContext context) {
    final lecturersAsync = ref.watch(lecturersProvider);

    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // 🔍 SEARCH BAR (Nama, NIP, Fakultas, Prodi)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => _searchQuery = value.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: "Cari Nama, NIP, atau Prodi...",
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔘 FILTER PRODI
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final selected = index == _selectedFilterIndex;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedFilterIndex = index),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF1E3A5F)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF1E3A5F)
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _filters[index],
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontSize: 13,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // 📦 GRID LIST DOSEN
                Expanded(
                  child: lecturersAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text("Error: $err")),
                    data: (lecturers) {
                      // --- LOGIC FILTERING ---
                      var filtered = lecturers.where((l) {
                        // 1. Ambil data kolom (Safe string)
                        final nama = (l['nama_dosen'] ?? '')
                            .toString()
                            .toLowerCase();
                        final nip = (l['nip_dosen'] ?? '')
                            .toString()
                            .toLowerCase();
                        final prodi = (l['prodi_dosen'] ?? '')
                            .toString()
                            .toLowerCase();
                        final fakultas = (l['fakultas_dosen'] ?? '')
                            .toString()
                            .toLowerCase();

                        // 2. Cek Search Query
                        final matchesSearch =
                            nama.contains(_searchQuery) ||
                            nip.contains(_searchQuery) ||
                            prodi.contains(_searchQuery) ||
                            fakultas.contains(_searchQuery);

                        return matchesSearch;
                      }).toList();

                      // 3. Cek Filter Kategori (Prodi)
                      if (_selectedFilterIndex != 0) {
                        final selectedProdi = _filters[_selectedFilterIndex]
                            .toLowerCase();
                        filtered = filtered.where((l) {
                          final prodi = (l['prodi_dosen'] ?? '')
                              .toString()
                              .toLowerCase();
                          // Menggunakan contains agar fleksibel (misal "Teknik" kena "Fakultas Teknik")
                          return prodi.contains(selectedProdi);
                        }).toList();
                      }

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_off,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text("Tidak ada dosen ditemukan"),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 20,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              childAspectRatio:
                                  0.70, // Rasio tinggi kartu disesuaikan
                            ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) =>
                            _buildLecturerCard(filtered[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🟦 KARTU DOSEN — Desain Baru
  Widget _buildLecturerCard(Map<String, dynamic> data) {
    // Ambil data dengan aman
    final String name = data['nama_dosen'] ?? 'No Name';
    final String nip = data['nip_dosen'] ?? '-';
    final String prodi = data['prodi_dosen'] ?? '-';
    final String fakultas = data['fakultas_dosen'] ?? '-';
    final String? avatarUrl = data['foto_dosen'];
    final String userId = data['id'];

    return GestureDetector(
      onTap: () {
        // Navigasi ke ChatScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              partnerId: userId,
              partnerName: name,
              partnerAvatar: avatarUrl,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            // BAGIAN FOTO (Atas)
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
                  ),
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl == null
                        ? const Icon(Icons.person, color: Colors.grey, size: 35)
                        : null,
                  ),
                ),
              ),
            ),

            // BAGIAN INFO (Bawah)
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // NAMA
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // NIP
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "NIP: $nip",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // PRODI & FAKULTAS
                    Text(
                      prodi,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      fakultas,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
