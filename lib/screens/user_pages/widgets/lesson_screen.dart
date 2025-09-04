import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_english/components/app_background.dart';

import 'lesson_detail_screen.dart';

class LessonScreen extends StatelessWidget {
  final String courseId;
  const LessonScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "Danh sách bài học",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFFF7B54),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('courses')
              .doc(courseId)
              .collection('lessons')
              .orderBy('createdAt', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Lỗi: ${snapshot.error}"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final lessons = snapshot.data!.docs;

            if (lessons.isEmpty) {
              return const Center(
                child: Text(
                  "Chưa có bài học nào",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final data = lessons[index].data() as Map<String, dynamic>;
                final title = data['title'] ?? 'Bài học';
                final description = data['description'] ?? '';
                final isVideo = data['isVideo'] ?? false;
                final mediaUrl = data['mediaUrl'];

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    if (mediaUrl != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LessonDetailScreen(
                            title: title,
                            description: description,
                            mediaUrl: mediaUrl,
                            isVideo: isVideo,
                          ),
                        ),
                      );
                    }
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white.withOpacity(0.9),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Hero(
                            tag: "lesson_$index",
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isVideo
                                    ? Icons.play_circle_fill
                                    : Icons.menu_book,
                                color: const Color(0xFFFF7B54),
                                size: 36,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFFFF7B54),
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
