import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// 1. Provider untuk Stream pesan (Raw Data)
final messageStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
      return supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .order('created_at')
          .map((data) => data);
    });

// 2. Provider untuk mengolah pesan menjadi "Daftar Kontak Unik" (Derived State)
final recentChatsProvider = Provider.autoDispose<List<Map<String, dynamic>>>((
  ref,
) {
  // Ambil data dari stream di atas
  final messagesValue = ref.watch(messageStreamProvider);
  final myUserId = supabase.auth.currentUser?.id;

  return messagesValue.when(
    data: (messages) {
      if (myUserId == null) return [];

      final Map<String, Map<String, dynamic>> uniqueConversations = {};

      for (var msg in messages) {
        final senderId = msg['sender_id'];
        final receiverId = msg['receiver_id'];

        // Cek apakah pesan melibatkan kita
        if (senderId == myUserId || receiverId == myUserId) {
          final partnerId = (senderId == myUserId) ? receiverId : senderId;

          // Logic: Simpan pesan terbaru saja per partnerId
          if (!uniqueConversations.containsKey(partnerId)) {
            uniqueConversations[partnerId] = msg;
          } else {
            final existingTime = DateTime.parse(
              uniqueConversations[partnerId]!['created_at'],
            );
            final newTime = DateTime.parse(msg['created_at']);
            if (newTime.isAfter(existingTime)) {
              uniqueConversations[partnerId] = msg;
            }
          }
        }
      }

      // Return list yang sudah diurutkan berdasarkan waktu terbaru
      return uniqueConversations.values.toList()
        ..sort((a, b) => b['created_at'].compareTo(a['created_at']));
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// 3. Provider untuk mengambil Profil User (Nama/Avatar) berdasarkan ID
//    Menggunakan .family karena kita butuh parameter 'userId'
final userProfileProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, userId) async {
    final response = await supabase
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .single();
    return response;
  },
);
