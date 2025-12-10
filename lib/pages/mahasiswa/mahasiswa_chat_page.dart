import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lectalk/pages/mahasiswa/mahasiswa_chatting.dart';

final supabase = Supabase.instance.client;

// Stream pesan
final messageStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return supabase
      .from('messages')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .map((data) => data);
});

// Recent chats
final recentChatsProvider =
    Provider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final messagesValue = ref.watch(messageStreamProvider);
  final myUserId = supabase.auth.currentUser?.id;

  return messagesValue.when(
    data: (messages) {
      if (myUserId == null) return [];

      final Map<String, Map<String, dynamic>> uniqueConversations = {};

      for (var msg in messages) {
        final senderId = msg['sender_id'];
        final receiverId = msg['receiver_id'];

        if (senderId == myUserId || receiverId == myUserId) {
          final partnerId = senderId == myUserId ? receiverId : senderId;

          if (!uniqueConversations.containsKey(partnerId)) {
            uniqueConversations[partnerId] = msg;
          } else {
            final existingTime =
                DateTime.parse(uniqueConversations[partnerId]!['created_at']);
            final newTime = DateTime.parse(msg['created_at']);
            if (newTime.isAfter(existingTime)) {
              uniqueConversations[partnerId] = msg;
            }
          }
        }
      }

      return uniqueConversations.values.toList()
        ..sort((a, b) => b['created_at'].compareTo(a['created_at']));
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Profile partner chat
final userProfileProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final response =
      await supabase.from('user_profiles').select().eq('id', userId).single();
  return response;
});

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
    final streamAsync = ref.watch(messageStreamProvider);

    // ⛔ Scaffold + AppBar dihapus total
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
                      onChanged: (v) =>
                          setState(() => _searchQuery = v.toLowerCase()),
                      decoration: const InputDecoration(
                        hintText: "Search conversation...",
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.search, color: Colors.grey),
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
                      final filteredChats = recentChats
                          .where((chat) =>
                              chat['content']
                                      ?.toString()
                                      .toLowerCase()
                                      .contains(_searchQuery) ??
                              false)
                          .toList();

                      if (filteredChats.isEmpty) {
                        return const Center(
                          child: Text(
                            "Belum ada pesan",
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        itemCount: filteredChats.length,
                        itemBuilder: (context, index) {
                          final chat = filteredChats[index];
                          final partnerId = chat['sender_id'] == myUserId
                              ? chat['receiver_id']
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
                )
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                partnerId: partnerId,
                partnerName: profile['full_name'] ?? 'Unknown',
                partnerAvatar: profile['avatar_url'],
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
                backgroundImage: (profile['avatar_url'] != null)
                    ? NetworkImage(profile['avatar_url'])
                    : null,
                child: (profile['avatar_url'] == null)
                    ? const Icon(Icons.person)
                    : null,
              ),
              loading: () =>
                  const CircleAvatar(radius: 28, child: CircularProgressIndicator()),
              error: (_, __) =>
                  const CircleAvatar(radius: 28, child: Icon(Icons.error)),
            ),

            const SizedBox(width: 12),

            // Nama + message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  profileAsync.when(
                    data: (profile) => Text(
                      profile['full_name'] ?? "Unknown",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
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

            Text(
              time,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
