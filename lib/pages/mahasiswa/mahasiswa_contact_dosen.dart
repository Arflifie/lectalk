import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lectalk/pages/mahasiswa/mahasiswa_chatting.dart';

final lecturersProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('user_profiles')
      .select()
      .eq('role', 'dosen')
      .order('created_at');

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

  final List<String> _filters = [
    'All',
    'Fakultas Teknik',
    'Sistem Informasi',
    'Manajemen',
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
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // 🔍 SEARCH BAR — versi Template
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => _searchQuery = value.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: "Search name/NIP",
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

                // 🔘 FILTER CATEGORY — versi Template
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
                                  : Colors.grey.shade300!,
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

                // 📦 GRID LIST DOSEN — gaya Template
                Expanded(
                  child: lecturersAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text("Error: $err")),
                    data: (lecturers) {
                      // Filter search
                      var filtered = lecturers.where((l) {
                        final name = (l['full_name'] ?? '')
                            .toString()
                            .toLowerCase();
                        return name.contains(_searchQuery);
                      }).toList();

                      // Filter kategori
                      if (_selectedFilterIndex != 0) {
                        filtered = filtered.where((l) {
                          return (l['department'] ?? '')
                              .toString()
                              .contains(_filters[_selectedFilterIndex]);
                        }).toList();
                      }

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text("Tidak ada dosen ditemukan"),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.75,
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

  // 🟦 KARTU DOSEN — versi desain Template (lebih soft, modern)
  Widget _buildLecturerCard(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              partnerId: data['id'],
              partnerName: data['full_name'] ?? 'Dosen',
              partnerAvatar: data['avatar_url'],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // FOTO
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B84B1), Color(0xFF4A73A0)],
                ),
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: data['avatar_url'] != null
                      ? NetworkImage(data['avatar_url'])
                      : null,
                  child: data['avatar_url'] == null
                      ? const Icon(Icons.person, color: Colors.white, size: 30)
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // NAMA
            Text(
              data['full_name'] ?? 'No Name',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 5),

            // DEPARTEMEN
            Text(
              data['department'] ?? '-',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
