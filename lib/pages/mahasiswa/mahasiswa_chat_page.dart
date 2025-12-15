import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ⚠️ PENTING: Ganti import ini dengan lokasi file ChatScreen (Halaman Detail Chat) Anda yang asli.
// Jika file ChatScreen Anda ada di folder 'pages', uncomment baris di bawah:
import 'package:lectalk/pages/mahasiswa/mahasiswa_chatting.dart';

final supabase = Supabase.instance.client;

// ==========================================
// 1. PROVIDERS
// ==========================================

// A. Stream Semua Pesan (Raw Data) + FIX TIPE DATA
final messageStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
      return supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .order('created_at')
          .map((data) {
            // PERBAIKAN PENTING: Paksa konversi tipe data agar tidak error List<dynamic>
            return List<Map<String, dynamic>>.from(data);
          });
    });

// B. Logic Recent Chats + Hitung Unread
// B. Logic Recent Chats + Hitung Unread
final recentChatsProvider = Provider.autoDispose<List<Map<String, dynamic>>>((
  ref,
) {
  final messagesValue = ref.watch(messageStreamProvider);
  final myUserId = supabase.auth.currentUser?.id;

  return messagesValue.when(
    data: (messages) {
      if (myUserId == null) return [];

      final Map<String, Map<String, dynamic>> conversations = {};

      for (var msg in messages) {
        final senderId = msg['sender_id']?.toString();
        final recipientId = msg['recipient_id']?.toString();
        final createdAtStr = msg['created_at']?.toString();
        final isRead = msg['is_read'] as bool? ?? false;

        if (senderId == null || recipientId == null || createdAtStr == null) {
          continue;
        }

        if (senderId == myUserId || recipientId == myUserId) {
          final partnerId = (senderId == myUserId) ? recipientId : senderId;

          if (!conversations.containsKey(partnerId)) {
            conversations[partnerId] = {'message': msg, 'unread_count': 0};
          }

          // LOGIC 1: HITUNG UNREAD
          if (recipientId == myUserId && !isRead) {
            conversations[partnerId]!['unread_count'] =
                (conversations[partnerId]!['unread_count'] as int) + 1;
          }

          // LOGIC 2: CARI PESAN TERBARU
          final currentStoredMsg =
              conversations[partnerId]!['message'] as Map<String, dynamic>;
          final currentStoredTime =
              DateTime.tryParse(currentStoredMsg['created_at'].toString()) ??
              DateTime(1970);
          final newMsgTime = DateTime.tryParse(createdAtStr) ?? DateTime.now();

          if (newMsgTime.isAfter(currentStoredTime)) {
            conversations[partnerId]!['message'] = msg;
          }
        }
      }

      // --- PERBAIKAN DI SINI (Baris 90-an ke bawah) ---
      // Kita deklarasikan tipe variabelnya secara eksplisit
      final List<Map<String, dynamic>> resultList = conversations.entries.map((
        entry,
      ) {
        // Ambil pesan dan paksa jadi Map<String, dynamic>
        final msg = Map<String, dynamic>.from(entry.value['message'] as Map);
        final count = entry.value['unread_count'] as int;

        return <String, dynamic>{...msg, 'unread_count': count};
      }).toList();

      // Sortir
      resultList.sort((a, b) {
        final tA =
            DateTime.tryParse(a['created_at'].toString()) ?? DateTime(1970);
        final tB =
            DateTime.tryParse(b['created_at'].toString()) ?? DateTime(1970);
        return tB.compareTo(tA);
      });

      return resultList;
    },
    loading: () => [],
    error: (e, s) {
      debugPrint("Error recentChats: $e");
      return [];
    },
  );
});

// C. Provider Profil User (Nama & Foto)
final userProfileProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, userId) async {
    final supabase = Supabase.instance.client;
    try {
      // Cek Mahasiswa
      final mhsData = await supabase
          .from('mahasiswa')
          .select('nama_mahasiswa, foto_mahasiswa')
          .eq('id', userId)
          .maybeSingle();

      if (mhsData != null) {
        return {
          'name': mhsData['nama_mahasiswa'],
          'avatar': mhsData['foto_mahasiswa'],
        };
      }

      // Cek Dosen
      final dosenData = await supabase
          .from('dosen_profile')
          .select('nama_dosen, foto_dosen')
          .eq('id', userId)
          .maybeSingle();

      if (dosenData != null) {
        return {
          'name': dosenData['nama_dosen'],
          'avatar': dosenData['foto_dosen'],
        };
      }
      return {'name': 'Unknown User', 'avatar': null};
    } catch (e) {
      return {'name': 'Error', 'avatar': null};
    }
  },
);

// ==========================================
// 2. HALAMAN UTAMA (LIST CHAT)
// ==========================================

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
                // --- Search Bar ---
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
                        hintText: "Search Conversation...",
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.search, color: Colors.grey),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- List Chat ---
                Expanded(
                  child: streamAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                    data: (_) {
                      // Filter Search
                      final filteredChats = recentChats.where((chat) {
                        final content =
                            chat['content']?.toString().toLowerCase() ?? '';
                        return content.contains(_searchQuery);
                      }).toList();

                      if (filteredChats.isEmpty) {
                        return const Center(
                          child: Text(
                            "No messages yet",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
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
                              ? chat['recipient_id']
                              : chat['sender_id'];

                          return _ChatListItem(
                            partnerId: partnerId,
                            lastMessage: chat['content'] ?? '',
                            time: _formatTime(chat['created_at']),
                            // Kirim jumlah unread ke widget item
                            unreadCount: chat['unread_count'] ?? 0,
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

// ==========================================
// 3. WIDGET ITEM CHAT (DESAIN WA)
// ==========================================

class _ChatListItem extends ConsumerWidget {
  final String partnerId;
  final String lastMessage;
  final String time;
  final int unreadCount; // Parameter baru

  const _ChatListItem({
    required this.partnerId,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
  });

  // Fungsi: Tandai pesan sebagai terbaca di database
  Future<void> _markAsRead() async {
    final myUserId = supabase.auth.currentUser?.id;
    if (myUserId == null) return;

    // Update is_read = true KHUSUS untuk pesan dari partner ini ke saya
    await supabase.from('messages').update({'is_read': true}).match({
      'sender_id': partnerId,
      'recipient_id': myUserId,
      'is_read': false,
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider(partnerId));

    return GestureDetector(
      onTap: () {
        // 1. Jika ada pesan belum dibaca, tandai sudah dibaca (update DB)
        if (unreadCount > 0) {
          _markAsRead();
        }

        // 2. Navigasi ke halaman detail chat
        profileAsync.whenData((profile) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                partnerId: partnerId,
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
          color: Colors.white, // Background putih bersih
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // --- AVATAR ---
            profileAsync.when(
              data: (profile) => CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: (profile['avatar'] != null)
                    ? NetworkImage(profile['avatar'])
                    : null,
                child: (profile['avatar'] == null)
                    ? const Icon(Icons.person, color: Colors.white)
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

            // --- NAMA & PESAN TERAKHIR ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama User
                  profileAsync.when(
                    data: (profile) => Text(
                      profile['name'] ?? "Unknown",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
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

                  // Last Message
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      // Jika unread > 0, teks jadi hitam tebal (mirip WA)
                      // Jika sudah dibaca, teks jadi abu-abu
                      color: unreadCount > 0
                          ? Colors.black87
                          : Colors.grey[600],
                      fontWeight: unreadCount > 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            // --- WAKTU & MARKER HIJAU ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Jam
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    // Jam jadi hijau jika ada pesan baru
                    color: unreadCount > 0
                        ? const Color(0xFF25D366)
                        : Colors.grey[500],
                    fontWeight: unreadCount > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 6),

                // Marker Lingkaran Hijau (Hanya muncul jika unread > 0)
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF25D366), // Hijau Khas WhatsApp
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 22,
                      minHeight: 22,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
