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

// --- Provider ---
final chatDetailStreamProvider = StreamProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, partnerId) {
      final myUserId = supabase.auth.currentUser?.id;

      return supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false) //urutin pesan
          .map((messages) {
            return messages.where((msg) {
              final sender = msg['sender_id'];
              final receiver = msg['recipient_id'];
              return (sender == myUserId && receiver == partnerId) ||
                  (sender == partnerId && receiver == myUserId);
            }).toList();
          });
    });

// --- UI ---
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
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        _isTyping = _textController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final myUserId = supabase.auth.currentUser?.id;
    if (myUserId == null) return;

    _textController.clear();
    setState(() => _isTyping = false);

    try {
      await supabase.from('messages').insert({
        'content': text,
        'sender_id': myUserId,
        'recipient_id': widget.partnerId,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  String _formatTime(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp).toLocal();
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatDetailStreamProvider(widget.partnerId));
    final myUserId = supabase.auth.currentUser?.id;

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
          Expanded(
            child: Container(
              color: const Color(0xFFF2F2F2),
              child: chatAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (messages) {
                  if (messages.isEmpty) {
                    return const Center(child: Text("Mulai percakapan..."));
                  }

                  // ✅ FIX: Reverse Scroll View (Bottom to Top)
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg['sender_id'] == myUserId;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
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
                              Text(
                                msg['content'] ?? '',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(msg['created_at']),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
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
          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
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
                    icon: Icon(
                      _isTyping ? Icons.send : Icons.mic,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _isTyping ? _sendMessage : () {},
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
