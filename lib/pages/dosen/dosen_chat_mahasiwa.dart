import 'package:flutter/material.dart';

// --- Constants (Warna & Style Khusus Chat) ---
class AppColors {
  static const Color primaryBlue = Color(0xFF1A3B5D); // Header
  static const Color backgroundGrey = Color(0xFFF5F5F5); // Background
  static const Color bubbleGrey = Color(0xFFD8D8D8); // Bubble Chat
  static const Color inputPill = Color(0xFFBDBDBD); // Input Container
  static const Color micBlue = Color(0xFF5C9DFF); // Tombol Mic
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
  const LecturerChatScreen({super.key});

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
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

  Widget _buildCustomHeader() {
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
                      image: DecorationImage(
                        image: NetworkImage('https://i.pravatar.cc/150?img=33'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Taufiqurahman",
                          style: AppTextStyles.headerTitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "NIM: F1E130500",
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

  Widget _buildInputArea() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        color: const Color(0xFFF2F2F2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.inputPill,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.sentiment_satisfied_alt,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                    Container(width: 1, height: 24, color: Colors.white54),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: "",
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        style: const TextStyle(color: Colors.white),
                        minLines: 1,
                        maxLines: 4,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.micBlue,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.mic, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Widget Component Terpisah ---

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
    final bgColor = AppColors.bubbleGrey;

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
              Text(text, style: AppTextStyles.messageText),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(time, style: AppTextStyles.timeText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}