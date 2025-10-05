import 'package:cloud_firestore/cloud_firestore.dart';

class UserController {
  static Future<List<Map<String, dynamic>>> fetchUsersFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();

    print('✅ Fetched ${snapshot.docs.length} users');

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'docId': doc.id,
        'username': data['username'] ?? 'Không có tên',
        'email': data['email'] ?? 'Không có email',
        'phone': data['phone'] ?? 'Không có số điện thoại',
        'role': data['role'] ?? 'user',
        'status': data['status'] ?? 'Active',
        'joinDate': data['createdAt'] != null
            ? _formatTimestamp(data['createdAt'])
            : 'Chưa rõ',
        'photoURL': data['photoURL'] ?? '',

      };
    }).toList();
  }

  static Future<void> deleteUser(String docId) async {
    await FirebaseFirestore.instance.collection('users').doc(docId).delete();
  }

  static Future<void> addUser(Map<String, dynamic> userData) async {
    await FirebaseFirestore.instance.collection('users').add(userData);
  }

  static Future<void> updateUser(String docId, Map<String, dynamic> userData) async {
    await FirebaseFirestore.instance.collection('users').doc(docId).update(userData);
  }

  static String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
