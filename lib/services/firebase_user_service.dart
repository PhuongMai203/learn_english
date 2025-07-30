import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUserService {
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  Future<void> registerUser({
    required String uid,
    required String username,
    required String email,
    required String phone,
  }) async {
    try {
      await usersCollection.doc(uid).set({
        'uid': uid,
        'username': username,
        'email': email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi khi lưu người dùng: $e');
    }
  }

  Future<bool> checkUsernameExists(String username) async {
    final querySnapshot = await usersCollection
        .where('username', isEqualTo: username)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

}
