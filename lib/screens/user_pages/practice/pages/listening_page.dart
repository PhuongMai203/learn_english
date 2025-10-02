import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:learn_english/components/app_background.dart';

class ListeningPage extends StatefulWidget {
  const ListeningPage({super.key});

  @override
  State<ListeningPage> createState() => _ListeningPageState();
}

class _ListeningPageState extends State<ListeningPage> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;

  Map<String, dynamic>? _exerciseDoc;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRandomExercise();

    _flutterTts.setCompletionHandler(() {
      setState(() => _isPlaying = false);
    });
  }

  /// Lấy random 1 document từ Firestore
  Future<void> _fetchRandomExercise() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection("listening_exercises").get();

      if (snapshot.docs.isNotEmpty) {
        final randomDoc = snapshot.docs[Random().nextInt(snapshot.docs.length)];
        setState(() {
          _exerciseDoc = randomDoc.data();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint("Error fetching exercise: $e");
      setState(() => _loading = false);
    }
  }

  /// Đọc văn bản bằng FlutterTTS với tốc độ chậm
  Future<void> _speakText(String text) async {
    if (text.isEmpty) return;
    if (_isPlaying) {
      await _flutterTts.stop();
      setState(() => _isPlaying = false);
    } else {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.4); // nói chậm hơn
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(text);
      setState(() => _isPlaying = true);
    }
  }

  /// Kiểm tra đáp án
  void _checkAnswer(int selectedIndex) {
    if (_answered) return;
    final currentQuestion = _exerciseDoc!["questions"][_currentIndex];
    final correctIndex = currentQuestion["correctIndex"];

    setState(() {
      _selectedAnswer = selectedIndex;
      _answered = true;
      if (selectedIndex == correctIndex) {
        _score++;
      }
    });
  }

  /// Câu tiếp theo
  void _nextQuestion() {
    if (_currentIndex < _exerciseDoc!["questions"].length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      _showResult();
    }
  }

  /// Câu trước
  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _selectedAnswer = null;
        _answered = false;
      });
    }
  }

  /// Hiện kết quả cuối cùng
  void _showResult() {
    final total = _exerciseDoc!["questions"].length;
    final percent = ((_score / total) * 100).toStringAsFixed(0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 64, color: Color(0xFFFFC107)),
              const SizedBox(height: 16),
              const Text(
                "Hoàn thành!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Bạn đã trả lời đúng $_score/$total câu\n"
                    "Tỉ lệ đúng: $percent%",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentIndex = 0;
                    _score = 0;
                    _selectedAnswer = null;
                    _answered = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Làm lại"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_exerciseDoc == null) {
      return const Scaffold(
        body: Center(child: Text("Không tìm thấy dữ liệu")),
      );
    }

    final questions =
    List<Map<String, dynamic>>.from(_exerciseDoc!["questions"]);
    final currentQuestion = questions[_currentIndex];

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            "Luyện nghe - Câu ${_currentIndex + 1}/${questions.length}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF90CAF9),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔊 Nút nghe
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _speakText(_exerciseDoc!["scriptText"] ?? ""),
                    icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                    label: Text(_isPlaying ? "Dừng lại" : "Nghe đoạn văn"),
                  ),
                ),
                const SizedBox(height: 20),

                // Câu hỏi
                Text(
                  currentQuestion["question"],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Các đáp án
                ...List.generate(currentQuestion["options"].length, (index) {
                  final option = currentQuestion["options"][index];
                  final correctIndex = currentQuestion["correctIndex"];
                  final optionLabel = String.fromCharCode(65 + index); // A,B,C,D

                  Color? color;
                  if (_answered) {
                    if (_selectedAnswer == index) {
                      color = (index == correctIndex)
                          ? Colors.green[300]
                          : Colors.red[300];
                    } else if (index == correctIndex) {
                      color = Colors.green[100];
                    }
                  }

                  return GestureDetector(
                    onTap: () => _checkAnswer(index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: color ?? Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blueAccent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$optionLabel. ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: color != null
                                  ? Colors.black
                                  : Colors.blueAccent,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              option,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // Nút điều hướng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _currentIndex > 0 ? _previousQuestion : null,
                      child: const Icon(Icons.arrow_back),
                    ),
                    ElevatedButton(
                      onPressed: _answered ? _nextQuestion : null,
                      child: Text(
                        _currentIndex == questions.length - 1
                            ? "Kết thúc"
                            : "Tiếp theo",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
