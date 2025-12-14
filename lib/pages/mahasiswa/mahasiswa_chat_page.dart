import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lectalk/pages/mahasiswa/mahasiswa_chatting.dart';

final supabase = Supabase.instance.client;

// 1. Stream Semua Pesan (Raw)
final messageStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
      return supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .order('created_at')
          .map((data) => data);
    });

// 2. Logic Mengolah Recent Chats (Group by User)
final recentChatsProvider = Provider.autoDispose<List<Map<String, dynamic>>>((
  ref,
) {
  final messagesValue = ref.watch(messageStreamProvider);
  final myUserId = supabase.auth.currentUser?.id;

  return messagesValue.when(
    data: (messages) {
      if (myUserId == null) return [];

      final Map<String, Map<String, dynamic>> uniqueConversations = {};

      for (var msg in messages) {
        // --- SAFE GUARDS (Pencegahan Error Null) ---
        final senderId = msg['sender_id']?.toString();
        final recipientId = msg['recipient_id']?.toString();
        final createdAtStr = msg['created_at']?.toString();

        // 1. Jika ID atau Tanggal kosong, lewati pesan ini (jangan bikin crash)
        if (senderId == null || recipientId == null || createdAtStr == null) {
          continue;
        }
        // -------------------------------------------

        if (senderId == myUserId || recipientId == myUserId) {
          // Tentukan lawan bicara
          final partnerId = (senderId == myUserId) ? recipientId : senderId;

          if (!uniqueConversations.containsKey(partnerId)) {
            uniqueConversations[partnerId] = msg;
          } else {
            final existingMsg = uniqueConversations[partnerId];
            final existingTimeStr = existingMsg?['created_at']?.toString();

            if (existingTimeStr != null) {
              final newTime = DateTime.tryParse(createdAtStr) ?? DateTime.now();
              final oldTime =
                  DateTime.tryParse(existingTimeStr) ?? DateTime(1970);

              if (newTime.isAfter(oldTime)) {
                uniqueConversations[partnerId] = msg;
              }
            }
          }
        }
      }

      // Sortir pesan terbaru paling atas
      return uniqueConversations.values.toList()..sort((a, b) {
        final tA =
            DateTime.tryParse(a['created_at'].toString()) ?? DateTime(1970);
        final tB =
            DateTime.tryParse(b['created_at'].toString()) ?? DateTime(1970);
        return tB.compareTo(tA);
      });
    },
    loading: () => [],
    error: (e, s) {
      debugPrint("Error recentChats: $e");
      return [];
    },
  );
});

// 3. Provider Profil (Cek Tabel Mahasiswa & Dosen)
final userProfileProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, userId) async {
    final supabase = Supabase.instance.client;

    try {
      // A. Cek tabel MAHASISWA
      final mhsData = await supabase
          .from('mahasiswa')
          .select('nama_mahasiswa, foto_mahasiswa')
          .eq('id', userId)
          .maybeSingle();

      if (mhsData != null) {
        return {
          'name': mhsData['nama_mahasiswa'],
          'avatar': mhsData['foto_mahasiswa'],
          'type': 'Mahasiswa',
        };
      }

      // B. Cek tabel DOSEN
      final dosenData = await supabase
          .from('dosen_profile')
          .select('nama_dosen, foto_dosen')
          .eq('id', userId)
          .maybeSingle();

      if (dosenData != null) {
        return {
          'name': dosenData['nama_dosen'],
          'avatar': dosenData['foto_dosen'],
          'type': 'Dosen',
        };
      }

      return {'name': 'Unknown User', 'avatar': null};
    } catch (e) {
      debugPrint('Error fetch profile: $e');
      return {'name': 'Error', 'avatar': null};
    }
  },
);

// --- UI CHAT PAGE ---
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});
  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final myUserId = Supabase.instance.client.auth.currentUser?.id;
  String _searchQuery = "";

  String _formatTime(String timestamp) {
    try {
      final DateTime dateTime = DateTime.parse(timestamp).toLocal();
      return DateFormat('HH:mm').format(dateTime);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentChats = ref.watch(recentChatsProvider);
    final streamAsync = ref.watch(messageStreamProvider); // Untuk loading state

    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // 🔎 Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      onChanged: (v) =>
                          setState(() => _searchQuery = v.toLowerCase()),
                      decoration: const InputDecoration(
                        hintText: "Search conversation...",
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.search, color: Colors.grey),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🗂 List Chat
                Expanded(
                  child: streamAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                    data: (_) {
                      // Filter search
                      final filteredChats = recentChats
                          .where(
                            (chat) =>
                                chat['content']
                                    ?.toString()
                                    .toLowerCase()
                                    .contains(_searchQuery) ??
                                false,
                          )
                          .toList();

                      if (filteredChats.isEmpty) {
                        return const Center(
                          child: Text(
                            "No messages found",
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: filteredChats.length,
                        itemBuilder: (context, index) {
                          final chat = filteredChats[index];
                          final partnerId = chat['sender_id'] == myUserId
                              ? chat['recipient_id'] // ✅ Gunakan recipient_id
                              : chat['sender_id'];

                          return _ChatListItem(
                            partnerId: partnerId,
                            lastMessage: chat['content'] ?? '',
                            time: _formatTime(chat['created_at']),
                          );
                        },
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
}

class _ChatListItem extends ConsumerWidget {
  final String partnerId;
  final String lastMessage;
  final String time;

  const _ChatListItem({
    required this.partnerId,
    required this.lastMessage,
    required this.time,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider(partnerId));

    return GestureDetector(
      onTap: () {
        profileAsync.whenData((profile) {
          // Navigasi ke ChatScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                partnerId: partnerId,
                // ✅ FIX: Gunakan key 'name' dan 'avatar' sesuai Provider di atas
                partnerName: profile['name'] ?? 'Unknown',
                partnerAvatar: profile['avatar'],
              ),
            ),
          );
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            // Avatar
            profileAsync.when(
              data: (profile) => CircleAvatar(
                radius: 28,
                // ✅ FIX: Gunakan key 'avatar'
                backgroundImage: (profile['avatar'] != null)
                    ? NetworkImage(profile['avatar'])
                    : null,
                child: (profile['avatar'] == null)
                    ? const Icon(Icons.person)
                    : null,
              ),
              loading: () => const CircleAvatar(
                radius: 28,
                child: CircularProgressIndicator(),
              ),
              error: (_, __) =>
                  const CircleAvatar(radius: 28, child: Icon(Icons.error)),
            ),
            const SizedBox(width: 12),
            // Nama + Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  profileAsync.when(
                    // ✅ FIX: Gunakan key 'name'
                    data: (profile) => Text(
                      profile['name'] ?? "Unknown",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    loading: () => Container(
                      height: 14,
                      width: 80,
                      color: Colors.grey.shade300,
                    ),
                    error: (_, __) => const Text("Error"),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}
