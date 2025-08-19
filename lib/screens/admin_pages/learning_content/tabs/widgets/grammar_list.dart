import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'grammar_item.dart';

class GrammarList extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> exercises;
  final FirebaseFirestore firestore;
  final VoidCallback onUpdated;

  const GrammarList({
    super.key,
    required this.exercises,
    required this.firestore,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: exercises.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final doc = exercises[index];

        return GrammarItem(
          exerciseId: doc.id,   // ✅ đổi từ grammarId → exerciseId
          firestore: firestore,
          onUpdated: onUpdated,
        );
      },
    );
  }
}
