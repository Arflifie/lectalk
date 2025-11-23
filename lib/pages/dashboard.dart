import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Definisi Warna
  final Color darkBlue = const Color(0xFF1E2D49);
  final Color lightBlue = const Color(0xFF6FA8FF);
  final Color lightGrey = const Color(0xFFF0F0F0);
  final Color textGrey = const Color(0xFF888888);

  // --- DATA DUMMY (STATE) ---
  // Di aplikasi asli, data ini didapat dari API/Database
  final List<Map<String, String>> chatList = [
    {
      "name": "Bambang Listiyanto, S.Kom.",
      "message": "Okey sir",
      "time": "11.47",
      "image": "https://i.pravatar.cc/150?img=11",
    },
    {
      "name": "Dr. Budi Santoso",
      "message": "Jangan lupa kumpulkan tugas...",
      "time": "10.30",
      "image": "https://i.pravatar.cc/150?img=3",
    },
    {
      "name": "Siti Aminah, M.T.",
      "message": "Baik, terima kasih infonya.",
      "time": "Yesterday",
      "image": "https://i.pravatar.cc/150?img=5",
    },
    {
      "name": "Admin Prodi",
      "message": "Jadwal ujian sudah keluar",
      "time": "Yesterday",
      "image": "https://i.pravatar.cc/150?img=8",
    },
    {
      "name": "Pak Rektor",
      "message": "Semangat belajarnya!",
      "time": "Mon",
      "image": "https://i.pravatar.cc/150?img=12",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      // Floating Action Button untuk simulasi menambah data
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 80,
        ), // Supaya tidak tertutup navbar
        child: FloatingActionButton(
          mini: true,
          backgroundColor: lightBlue,
          child: const Icon(Icons.add),
          onPressed: () {
            // CONTOH PERUBAHAN STATE
            setState(() {
              chatList.insert(0, {
                "name": "Mahasiswa Baru",
                "message": "Permisi pak, mau tanya...",
                "time": "Just Now",
                "image":
                    "https://i.pravatar.cc/150?img=${chatList.length + 20}",
              });
            });
          },
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Icon(Icons.menu, color: Colors.white, size: 30),
                    ],
                  ),
                ),

                // 2. White Body Container
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        // Search Bar (Tetap di atas)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildSearchBar(),
                        ),
                        const SizedBox(height: 10),

                        // ListView Builder (Dinamis)
                        Expanded(
                          child: ListView.builder(
                            // Tambah padding bawah agar item terakhir tidak tertutup navbar
                            padding: const EdgeInsets.only(
                              top: 10,
                              left: 20,
                              right: 20,
                              bottom: 100,
                            ),
                            itemCount: chatList.length,
                            itemBuilder: (context, index) {
                              final item = chatList[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: _buildListItem(
                                  name: item['name']!,
                                  message: item['message']!,
                                  time: item['time']!,
                                  imageUrl: item['image']!,
                                ),
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

            // 3. Custom Bottom Navigation Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildCustomBottomBar(context),
            ),
          ],
        ),
      ),
    );
  }

  // ... Widget Helper (_buildSearchBar, _buildListItem, _buildCustomBottomBar) ...
  // ... Sama persis dengan kode sebelumnya, copy-paste bagian bawah ini ...

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade400),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Search",
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          suffixIcon: Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildListItem({
    required String name,
    required String message,
    required String time,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 25, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textGrey, fontSize: 14),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(time, style: TextStyle(fontSize: 12, color: textGrey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomBar(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 80),
              painter: BNBCustomPainter(darkBlue),
            ),
          ),
          Positioned(
            bottom: 35,
            left: 40,
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: lightBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            left: 58,
            child: const Text(
              "Chat",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: 80),
                _buildNavItem(Icons.school_outlined, "Lecturer Data"),
                _buildNavItem(Icons.description_outlined, "Template"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

class BNBCustomPainter extends CustomPainter {
  final Color color;
  BNBCustomPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    Path path = Path();
    path.moveTo(0, 20);
    path.quadraticBezierTo(20, 20, 30, 40);
    path.quadraticBezierTo(72, 90, 115, 40);
    path.quadraticBezierTo(125, 20, 150, 20);
    path.lineTo(size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
