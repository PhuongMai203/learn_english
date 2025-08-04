import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserController {
  static Future<List<Map<String, dynamic>>> fetchUsersFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs
        .where((doc) => doc['role'] != 'admin')
        .map((doc) => {
      'name': doc['username'] ?? 'Không có tên',
      'email': doc['email'] ?? 'Không có email',
      'role': doc['role'] ?? 'user',
      'status': doc.data().containsKey('status') ? doc['status'] : 'Active',
      'joinDate': doc['createdAt'] != null
          ? _formatTimestamp(doc['createdAt'])
          : 'Chưa rõ',
      'photoURL': doc.data().containsKey('photoURL') ? doc['photoURL'] : '',
      'docId': doc.id,
    })
        .toList();
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
