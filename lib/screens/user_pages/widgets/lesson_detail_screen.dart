import 'package:flutter/material.dart';
import 'package:learn_english/components/app_background.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LessonDetailScreen extends StatefulWidget {
  final String lessonId; // thêm để filter exercises
  final String title;
  final String description;
  final String mediaUrl;
  final bool isVideo;

  const LessonDetailScreen({
    super.key,
    required this.lessonId,
    required this.title,
    required this.description,
    required this.mediaUrl,
    required this.isVideo,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;

  bool get isYoutubeUrl =>
      widget.mediaUrl.contains("youtube.com") ||
          widget.mediaUrl.contains("youtu.be");

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      if (isYoutubeUrl) {
        final videoId = YoutubePlayer.convertUrlToId(widget.mediaUrl);
        if (videoId != null && videoId.isNotEmpty) {
          _youtubeController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
          );
        }
      } else {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.mediaUrl),
        )..initialize().then((_) {
          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: false,
            looping: false,
            aspectRatio: _videoController!.value.aspectRatio,
          );
          setState(() {});
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  /// ---------------- HIỂN THỊ BÀI TẬP ----------------
  Widget _buildExercises() {
    final firestore = FirebaseFirestore.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          "Bài tập liên quan",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        // Grammar exercises
        StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection("grammar_exercises")
              .where("lessonId", isEqualTo: widget.lessonId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return const SizedBox();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text("📝 Bài tập ngữ pháp",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return ExerciseCard(
                    question: data['words'][0],
                    options: Map<String, dynamic>.from(data['options']),
                    correctAnswer: data['correctAnswer'],
                  );
                }),
              ],
            );
          },
        ),

        // Vocabulary exercises
        StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection("vocabulary_exercises")
              .where("lessonId", isEqualTo: widget.lessonId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return const SizedBox();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text("📚 Bài tập từ vựng",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return ExerciseCard(
                    question: data['words'][0],
                    options: Map<String, dynamic>.from(data['options']),
                    correctAnswer: data['correctAnswer'],
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.title, style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFFFF7B54),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isVideo && _youtubeController != null)
                YoutubePlayer(controller: _youtubeController!)
              else if (widget.isVideo &&
                  _videoController != null &&
                  _videoController!.value.isInitialized &&
                  _chewieController != null)
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: Chewie(controller: _chewieController!),
                )
              else if (widget.isVideo)
                  const Center(child: CircularProgressIndicator()),

              const SizedBox(height: 16),
              Text(widget.description, style: const TextStyle(fontSize: 16)),

              // hiển thị bài tập
              _buildExercises(),
            ],
          ),
        ),
      ),
    );
  }
}

/// ----------------- WIDGET EXERCISE -----------------
class ExerciseCard extends StatefulWidget {
  final String question;
  final Map<String, dynamic> options;
  final String correctAnswer;

  const ExerciseCard({
    super.key,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  String? _selectedOption;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Câu hỏi: ${widget.question}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),

            // Options
            ...widget.options.entries.map((e) {
              final optionKey = e.key;
              final optionValue = e.value;
              Color bgColor = Colors.white;
              Color textColor = Colors.black87;
              BorderSide border = const BorderSide(color: Colors.grey);

              if (_submitted) {
                if (optionKey == widget.correctAnswer) {
                  bgColor = Colors.green.shade400;
                  textColor = Colors.white;
                  border = BorderSide.none;
                } else if (_selectedOption == optionKey &&
                    optionKey != widget.correctAnswer) {
                  bgColor = Colors.red.shade400;
                  textColor = Colors.white;
                  border = BorderSide.none;
                }
              } else if (_selectedOption == optionKey) {
                // khi chọn nhưng chưa nộp
                bgColor = Colors.green.shade100;
                border = BorderSide(color: Colors.green);
              }

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.fromBorderSide(border),
                ),
                child: ListTile(
                  title: Text(
                    "$optionKey. $optionValue",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  leading: Radio<String>(
                    value: optionKey,
                    groupValue: _selectedOption,
                    onChanged: _submitted
                        ? null
                        : (val) {
                      setState(() {
                        _selectedOption = val;
                      });
                    },
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),

            // Submit button
            if (!_submitted)
              ElevatedButton(
                onPressed: _selectedOption == null
                    ? null
                    : () {
                  setState(() {
                    _submitted = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7B54),
                ),
                child: Text("Nộp bài",
                  style: TextStyle(
                  fontSize: 16, color: Colors.white),
                  ),
              ),
          ],
        ),
      ),
    );
  }
}
