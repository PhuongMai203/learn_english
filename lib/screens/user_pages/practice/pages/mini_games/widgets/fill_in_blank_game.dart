import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_english/components/app_background.dart';

class FillInBlankGamePage extends StatefulWidget {
  const FillInBlankGamePage({super.key});

  @override
  State<FillInBlankGamePage> createState() => _FillInBlankGamePageState();
}

class _FillInBlankGamePageState extends State<FillInBlankGamePage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('grammar_exercises').get();

      final allQuestions = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "title": data['title'],
          "words": List<String>.from(data['words']),
          "options": Map<String, String>.from(data['options']),
          "correctAnswer": data['correctAnswer'],
        };
      }).toList();

      allQuestions.shuffle(); // 🔹 trộn ngẫu nhiên tất cả
      final random10 = allQuestions.take(10).toList(); // 🔹 lấy đúng 10 câu

      setState(() {
        _questions = random10;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Lỗi khi lấy dữ liệu grammar_exercises: $e");
      setState(() => _isLoading = false);
    }
  }

  void _checkAnswer(String optionKey) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = optionKey;
      _answered = true;
      if (_selectedAnswer == _questions[_currentIndex]['correctAnswer']) {
        _score += 10;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      _showFinalScore();
    }
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("🎉 Hoàn thành!"),
        content: Text("Bạn đã đạt được $_score điểm."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _score = 0;
                _currentIndex = 0;
                _answered = false;
                _selectedAnswer = null;
              });
              _fetchQuestions(); // 🔄 lấy lại 10 câu random mới
            },
            child: const Text("Chơi lại"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("⚠️ Không có dữ liệu trong grammar_exercises")),
      );
    }

    final question = _questions[_currentIndex];
    final sentence = question['words'][0];
    final options = question['options'] as Map<String, String>;
    final correctAnswer = question['correctAnswer'];

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Fill in the Blank"),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "Câu ${_currentIndex + 1}/${_questions.length}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: Colors.teal.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    sentence,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: options.entries.map((entry) {
                  final optionKey = entry.key;
                  final optionText = entry.value;

                  Color optionColor = Colors.white;
                  if (_answered) {
                    if (optionKey == correctAnswer) {
                      optionColor = Colors.green.shade200;
                    } else if (optionKey == _selectedAnswer) {
                      optionColor = Colors.red.shade200;
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ElevatedButton(
                      onPressed: () => _checkAnswer(optionKey),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: optionColor,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "$optionKey.",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          Text(optionText, style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              if (_answered)
                ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Tiếp tục",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 20),
              Text("⭐ Điểm: $_score",
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.teal,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
