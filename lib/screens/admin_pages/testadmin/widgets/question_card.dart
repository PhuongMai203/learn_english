import 'package:flutter/material.dart';
import 'package:learn_english/screens/admin_pages/testadmin/widgets/models.dart';

class QuestionCard extends StatelessWidget {
  final int index;
  final Question question;
  final bool expanded;
  final VoidCallback? onDuplicate;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onExpand;

  const QuestionCard({
    super.key,
    this.index = 0,
    required this.question,
    this.expanded = false,
    this.onDuplicate,
    this.onEdit,
    this.onDelete,
    this.onExpand,
  });


  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key(question.id),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        initiallyExpanded: expanded,
        onExpansionChanged: (_) => onExpand?.call(),
        leading: const Icon(Icons.drag_handle, color: Colors.grey),
        title: Text(
          '${index + 1}. ${question.content}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('Correct: ${question.options[question.correctAnswerIndex]}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.content_copy, color: Colors.orange), onPressed: onDuplicate),
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: question.options.asMap().entries.map((entry) {
                final optionIndex = entry.key;
                final optionText = entry.value;
                return Row(
                  children: [
                    Icon(
                      optionIndex == question.correctAnswerIndex
                          ? Icons.check_circle
                          : Icons.circle,
                      color: optionIndex == question.correctAnswerIndex
                          ? Colors.green
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      optionText,
                      style: TextStyle(
                        color: optionIndex == question.correctAnswerIndex ? Colors.green : Colors.black,
                        fontWeight: optionIndex == question.correctAnswerIndex
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
