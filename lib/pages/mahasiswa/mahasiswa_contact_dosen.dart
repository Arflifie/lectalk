import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Import Detail Chat
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

    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Lecturer Data",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Search
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        onChanged: (value) =>
                            setState(() => _searchQuery = value.toLowerCase()),
                        decoration: const InputDecoration(
                          hintText: 'Search name/NIP',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          suffixIcon: Icon(Icons.search, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Filter
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedFilterIndex = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedFilterIndex == index
                                  ? const Color(0xFF1E3A5F).withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: _selectedFilterIndex == index
                                    ? const Color(0xFF1E3A5F)
                                    : Colors.grey.shade400,
                              ),
                            ),
                            child: Text(
                              _filters[index],
                              style: TextStyle(
                                color: _selectedFilterIndex == index
                                    ? const Color(0xFF1E3A5F)
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Grid List
                  Expanded(
                    child: lecturersAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                      data: (lecturers) {
                        var filteredList = lecturers
                            .where(
                              (l) => (l['full_name'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains(_searchQuery),
                            )
                            .toList();
                        if (_selectedFilterIndex != 0) {
                          filteredList = filteredList
                              .where(
                                (l) => (l['department'] ?? '')
                                    .toString()
                                    .contains(_filters[_selectedFilterIndex]),
                              )
                              .toList();
                        }

                        if (filteredList.isEmpty)
                          return const Center(
                            child: Text("Tidak ada dosen ditemukan"),
                          );

                        return GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) =>
                              _buildLecturerCard(context, filteredList[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLecturerCard(BuildContext context, Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5B84B1), Color(0xFF4A73A0)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 85,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                      image: (data['avatar_url'] != null)
                          ? DecorationImage(
                              image: NetworkImage(data['avatar_url']),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: data['avatar_url'] == null
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white),
                      const SizedBox(height: 10),
                      // TOMBOL CHAT
                      InkWell(
                        onTap: () {
                          // PERBAIKAN: Navigasi ke ChatScreen (Detail)
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
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data['full_name'] ?? 'No Name',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    data['department'] ?? '-',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
