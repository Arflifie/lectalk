// File: dosen_chat_mahasiwa.dart

import 'package:flutter/material.dart';

// --- Constants (Warna & Style Khusus Chat) ---
class AppColors {
  static const Color primaryBlue = Color(0xFF1A3B5D); // Header
  static const Color backgroundGrey = Color(0xFFF5F5F5); // Background
  static const Color bubbleGrey = Color(0xFFD8D8D8); // Bubble Chat
  // Warna Input diubah menjadi putih untuk desain sederhana
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
  // FINAL PROPERTIES
  final String mahasiswaName;
  final String mahasiswaNIM;
  final String mahasiswaId;
  final String? mahasiswaFoto;
  // Kita asumsikan Anda juga mengirim URL foto mahasiswa saat navigasi
  // Untuk saat ini, kita akan pakai URL dummy/placeholder di header,
  // karena URL foto tidak dikirim dari dosen_contact_mahasiswa.dart.

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

  // Dummy Data - Percakapan dari sudut pandang dosen
  final List<Map<String, dynamic>> _messages = [
    {
      "text":
          "Good afternoon, Mr. Bambang Listiyanto, I apologize for interrupting your time. I am Taufiqurahman with NIM F1E130500, a student under your thesis guidance. I would like to consult regarding the completion of chapter I of my thesis which will discuss political campaign strategies on social media. When can I meet you for guidance and consultation? I will adjust to your schedule. Thank you very much, Mr. for your time. Good afternoon.",
      "time": "14.27",
      "isMe": false,
    },
    {
      "text":
          "Good afternoon, Taufiqurahman. Thank you for your message. No need to apologize — I appreciate your initiative.\nIt's good that you're progressing with your thesis. I'd be happy to guide you. I'm available this Wednesday or Friday at 10:00 AM. Please let me know which time works best for you.\nAlso, if possible, kindly send me your Chapter I draft beforehand so I can review it briefly before our meeting.\nLooking forward to our discussion.",
      "time": "14.54",
      "isMe": true,
    },
    {"text": "Okey sir", "time": "14.54", "isMe": false},
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // [BARU] Fungsi Kirim Pesan (Placeholder)
  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add({
          "text": text,
          "time":
              "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
          "isMe": true,
        });
      });
      _textController.clear();
      // TODO: Implement Supabase chat logic (Insert message)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildCustomHeader(),
          Expanded(
            child: Container(
              color: const Color(0xFFF2F2F2),
              child: ListView.builder(
                // Tambahkan reverse: true untuk menampilkan pesan dari bawah
                reverse: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: _messages.length,
                // Mengakses dari akhir list untuk reverse: true
                itemBuilder: (context, index) {
                  final msg = _messages[_messages.length - 1 - index];
                  return ChatBubble(
                    text: msg['text'],
                    time: msg['time'],
                    isMe: msg['isMe'],
                  );
                },
              ),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  // [MODIFIKASI] Header menggunakan data dinamis
  Widget _buildCustomHeader() {
    // Gunakan URL foto yang dikirim, atau placeholder jika null/kosong
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
                    decoration: BoxDecoration(
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
                        : const Icon(
                            Icons.person,
                            color: Colors.white,
                          ), // Placeholder default
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // [DINAMIS] Nama Mahasiswa
                        Text(
                          widget.mahasiswaName,
                          style: AppTextStyles.headerTitle.copyWith(
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        // [DINAMIS] NIM Mahasiswa
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

  // [MODIFIKASI] Input Area disederhanakan (hanya text & tombol kirim)
  Widget _buildInputArea() {
    // Tambahkan listener untuk mengubah tombol Mic menjadi tombol Kirim
    final isTextFieldEmpty = _textController.text.isEmpty;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        color: const Color(0xFFF2F2F2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Input Text
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    controller: _textController,
                    onChanged: (text) {
                      setState(() {
                        // Memaksa rebuild untuk mengupdate ikon tombol
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Ketik pesan...",
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: const TextStyle(color: Colors.black87),
                    minLines: 1,
                    maxLines: 5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Tombol Kirim (Send)
            Container(
              decoration: BoxDecoration(
                color: isTextFieldEmpty ? Colors.grey : AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: isTextFieldEmpty
                    ? null
                    : _sendMessage, // Panggil _sendMessage
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Widget Component Terpisah (ChatBubble - Tidak Berubah) ---

class ChatBubble extends StatelessWidget {
  // ... (kode ChatBubble tidak berubah) ...
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
    // Ganti warna bubble sesuai pengirim
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
                    color: isMe ? Colors.white70 : Colors.grey, // Warna waktu
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
