import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Constants ---
class AppColors {
  static const Color primaryBlue = Color(0xFF1A3B5D);
  static const Color bubbleGrey = Color(0xFFD8D8D8);
  static const Color bubbleMe = Color(0xFFDCF8C6);
  static const Color micBlue = Color(0xFF5C9DFF);
}

final supabase = Supabase.instance.client;

// ==========================================
// 1. PROVIDER (FIX TIPE DATA & FILTER)
// ==========================================
final chatDetailStreamProvider = StreamProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, partnerId) {
      final myUserId = supabase.auth.currentUser?.id;

      return supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .order(
            'created_at',
            ascending: false,
          ) // Pesan terbaru di atas (untuk list reverse)
          .map((data) {
            // 1. Paksa konversi tipe data dulu biar gak error List<dynamic>
            final List<Map<String, dynamic>> messages =
                List<Map<String, dynamic>>.from(data);

            // 2. Filter pesan hanya antara SAYA dan PARTNER
            return messages.where((msg) {
              final sender = msg['sender_id'];
              final receiver = msg['recipient_id'];
              return (sender == myUserId && receiver == partnerId) ||
                  (sender == partnerId && receiver == myUserId);
            }).toList();
          });
    });

// ==========================================
// 2. UI HALAMAN CHAT DETAIL
// ==========================================
class ChatScreen extends ConsumerStatefulWidget {
  final String partnerId;
  final String partnerName;
  final String? partnerAvatar;

  const ChatScreen({
    super.key,
    required this.partnerId,
    required this.partnerName,
    this.partnerAvatar,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Tandai pesan terbaca saat pertama kali buka
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- LOGIC 1: UPDATE STATUS READ KE DATABASE ---
  // Ini yang bikin lingkaran hijau di halaman depan hilang otomatis
  Future<void> _markMessagesAsRead() async {
    final myUserId = supabase.auth.currentUser?.id;
    if (myUserId == null) return;

    try {
      await supabase
          .from('messages')
          .update({'is_read': true}) // Set jadi terbaca
          .eq('sender_id', widget.partnerId) // Pesan dari partner
          .eq('recipient_id', myUserId) // Dikirim ke saya
          .eq('is_read', false); // Hanya yang belum dibaca
    } catch (e) {
      debugPrint("Gagal update read status: $e");
    }
  }

  // --- LOGIC 2: KIRIM PESAN ---
  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final myUserId = supabase.auth.currentUser?.id;
    if (myUserId == null) return;

    _textController.clear();

    try {
      await supabase.from('messages').insert({
        'content': text,
        'sender_id': myUserId,
        'recipient_id': widget.partnerId,
        'is_read': false, // Default belum dibaca
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // Helper Format Waktu
  String _formatTime(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp).toLocal();
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return '';
    }
  }

  // Helper Icon Centang (Biru/Abu)
  Widget _buildStatusIcon(bool isRead) {
    return Icon(
      Icons.done_all,
      size: 16,
      color: isRead ? Colors.blue : Colors.grey, // Biru jika isRead true
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatDetailStreamProvider(widget.partnerId));
    final myUserId = supabase.auth.currentUser?.id;

    // --- LOGIC 3: REALTIME LISTENER ---
    // Jika ada pesan baru masuk saat kita sedang melihat layar ini,
    // kode ini akan otomatis menjalankannya 'mark as read'.
    ref.listen(chatDetailStreamProvider(widget.partnerId), (previous, next) {
      next.whenData((messages) {
        // Cek apakah ada pesan dari partner yang belum dibaca
        final hasUnread = messages.any(
          (msg) =>
              msg['sender_id'] == widget.partnerId && msg['is_read'] == false,
        );

        if (hasUnread) {
          _markMessagesAsRead();
        }
      });
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey,
              backgroundImage: widget.partnerAvatar != null
                  ? NetworkImage(widget.partnerAvatar!)
                  : null,
              child: widget.partnerAvatar == null
                  ? const Icon(Icons.person, size: 20, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.partnerName,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Area Chat Bubble
          Expanded(
            child: Container(
              color: const Color(0xFFF2F2F2),
              child: chatAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (messages) {
                  if (messages.isEmpty) {
                    return const Center(
                      child: Text(
                        "Mulai percakapan...",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true, // Scroll dari bawah ke atas
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg['sender_id'] == myUserId;
                      final isRead = msg['is_read'] as bool? ?? false;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? AppColors.bubbleMe : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: isMe
                                  ? const Radius.circular(12)
                                  : Radius.zero,
                              bottomRight: isMe
                                  ? Radius.zero
                                  : const Radius.circular(12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Isi Pesan
                              Text(
                                msg['content'] ?? '',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Waktu + Centang
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatTime(msg['created_at']),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  // Tampilkan centang hanya jika pesan SAYA
                                  if (isMe) ...[
                                    const SizedBox(width: 4),
                                    _buildStatusIcon(isRead),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Area Input Teks
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 8,
              right: 8,
              top: 10,
              bottom: 10 + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Ketik pesan...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.micBlue,
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
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
