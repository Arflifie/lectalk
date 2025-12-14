// File: dosen_chat_mahasiwa.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// Akses Supabase Client
final supabase = Supabase.instance.client;

// --- Constants (Warna & Style Khusus Chat) ---
class AppColors {
  static const Color primaryBlue = Color(0xFF1A3B5D); // Header
  static const Color backgroundGrey = Color(0xFFF2F2F2); // Background
  static const Color bubbleGrey = Color(0xFFD8D8D8); // Bubble Chat
  static const Color inputPill = Colors.white;
  static const Color micBlue = Color(0xFF5C9DFF); // Tombol Mic/Send
}

class AppTextStyles {
  static const TextStyle headerTitle = TextStyle(
    color: Colors.black87,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );
  static const TextStyle messageText = TextStyle(
    color: Colors.black87,
    fontSize: 14,
    height: 1.3,
  );
  static const TextStyle timeText = TextStyle(color: Colors.grey, fontSize: 11);
}

// --- Main Screen ---

class LecturerChatScreen extends StatefulWidget {
  final String mahasiswaName;
  final String mahasiswaNIM;
  final String mahasiswaId;
  final String? mahasiswaFoto;

  const LecturerChatScreen({
    super.key,
    required this.mahasiswaName,
    required this.mahasiswaNIM,
    required this.mahasiswaId,
    this.mahasiswaFoto,
  });

  @override
  State<LecturerChatScreen> createState() => _LecturerChatScreenState();
}

class _LecturerChatScreenState extends State<LecturerChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _currentUserId;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  late RealtimeChannel _chatChannel;

  @override
  void initState() {
    super.initState();
    _currentUserId = supabase.auth.currentUser?.id;
    if (_currentUserId != null) {
      _loadMessages();
      _setupRealtimeSubscription();
    }
  }

  @override
  void dispose() {
    supabase.removeChannel(_chatChannel);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- LOGIKA SUPABASE ---

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      // [PERBAIKAN SINTAKS OR]: Menggunakan format AND() di dalam OR() Postgrest
      final List<Map<String, dynamic>> messagesData = await supabase
          .from('messages')
          .select('*')
          .or(
            'and(sender_id.eq.$_currentUserId,recipient_id.eq.${widget.mahasiswaId}),'
            'and(sender_id.eq.${widget.mahasiswaId},recipient_id.eq.$_currentUserId)',
          )
          .order('created_at', ascending: true);

      setState(() {
        _messages = messagesData;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } on PostgrestException catch (e) {
      print('Error loading messages: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat pesan: ${e.message}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _setupRealtimeSubscription() {
    _chatChannel = supabase.channel('chat_${widget.mahasiswaId}');

    _chatChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            final message = payload.newRecord;
            final senderId = message['sender_id'];
            final recipientId = message['recipient_id'];

            // HANYA terima pesan yang datang DARI PIHAK LAIN (Mahasiswa)
            // Pesan dari diri sendiri sudah di-handle oleh Optimistic UI Update.
            if (senderId == widget.mahasiswaId &&
                recipientId == _currentUserId) {
              if (mounted) {
                setState(() {
                  _messages.add(message);
                });
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );
              }
            }
          },
        )
        .subscribe();
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    final currentUserId = _currentUserId;

    _textController.clear();
    // setState() di sini untuk membersihkan input field dan update status tombol
    setState(() {});

    if (text.isEmpty || currentUserId == null) return;

    // 1. Persiapkan data pesan untuk TAMPILAN OPTIMISTIC
    final newMessage = {
      'sender_id': currentUserId,
      'recipient_id': widget.mahasiswaId,
      'content': text,
      'created_at': DateTime.now()
          .toUtc()
          .toIso8601String(), // Waktu lokal/mock
      // Supabase akan mengabaikan created_at ini dan memakai waktu server,
      // tetapi ini dibutuhkan untuk tampilan lokal instan.
      'is_read': false, // Asumsi belum dibaca lawan, tapi status dikirim
    };

    // 2. OPTIMISTIC UI UPDATE: Tampilkan pesan di layar SEGERA
    setState(() {
      _messages.add(newMessage);
    });
    _scrollToBottom(); // Gulir ke pesan baru

    // 3. Kirim ke Supabase
    try {
      await supabase.from('messages').insert({
        'sender_id': currentUserId,
        'recipient_id': widget.mahasiswaId,
        'content': text,
      });

      // Catatan: Karena kita sudah menambahkan pesan secara optimis,
      // notifikasi Realtime dari pesan yang kita kirim sendiri (jika RLS mengizinkan)
      // kemungkinan akan menyebabkan pesan ganda (DUPLICATE).
    } on PostgrestException catch (e) {
      print('Error sending message: $e');

      // 4. ROLLBACK: Hapus pesan yang optimis ditambahkan jika pengiriman gagal
      setState(() {
        _messages.removeWhere(
          (msg) =>
              msg['content'] == text &&
              msg['sender_id'] == currentUserId &&
              msg['created_at'] == newMessage['created_at'],
        );
        // Atau cara termudah:
        // _messages.removeLast();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim pesan: ${e.message}')),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // --- WIDGETS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: Column(
        children: [
          _buildCustomHeader(),
          Expanded(child: _buildChatArea()),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildCustomHeader() {
    final String photoUrl = widget.mahasiswaFoto ?? '';
    final bool hasPhoto = photoUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 15, left: 10, right: 16),
      color: AppColors.primaryBlue,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  // Avatar mahasiswa
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: hasPhoto
                        ? ClipOval(
                            child: Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, color: Colors.white),
                            ),
                          )
                        : const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.mahasiswaName,
                          style: AppTextStyles.headerTitle.copyWith(
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "NIM: ${widget.mahasiswaNIM}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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

  Widget _buildChatArea() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_messages.isEmpty) {
      return Center(
        child: Text(
          "Mulai percakapan dengan ${widget.mahasiswaName}",
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final bool isMe = message['sender_id'] == _currentUserId;
        final DateTime time = DateTime.parse(message['created_at']).toLocal();

        return ChatBubble(
          text: message['content'],
          time: DateFormat('HH:mm').format(time),
          isMe: isMe,
        );
      },
    );
  }

  Widget _buildInputArea() {
    final bool isTextFieldEmpty = _textController.text.trim().isEmpty;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: AppColors.inputPill,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _textController,
                  onChanged: (text) {
                    setState(() {});
                  },
                  style: AppTextStyles.messageText.copyWith(
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Tulis pesan...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  minLines: 1,
                  maxLines: 5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Tombol Kirim (Send Button)
            GestureDetector(
              onTap: isTextFieldEmpty ? null : _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isTextFieldEmpty ? Colors.grey : AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Chat Bubble Component ---
class ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bgColor = isMe ? AppColors.primaryBlue : AppColors.bubbleGrey;
    final txtColor = isMe ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: AppTextStyles.messageText.copyWith(color: txtColor),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  time,
                  style: AppTextStyles.timeText.copyWith(
                    color: isMe ? Colors.white70 : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
