import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_english/components/app_background.dart';

class QuickQuizGamePage extends StatefulWidget {
  const QuickQuizGamePage({super.key});

  @override
  State<QuickQuizGamePage> createState() => _QuickQuizGamePageState();
}

class _QuickQuizGamePageState extends State<QuickQuizGamePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  String? _selectedAnswer;
  Timer? _timer;
  int _timeLeft = 20;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  Future<void> _fetchQuestions() async {
    try {
      // Lấy vocabulary_exercises
      final vocabSnap = await _firestore
          .collection("vocabulary_exercises")
          .orderBy("createdAt", descending: true)
          .get();

      // Lấy grammar_exercises
      final grammarSnap = await _firestore
          .collection("grammar_exercises")
          .orderBy("createdAt", descending: true)
          .get();

      List<Map<String, dynamic>> vocabQuestions =
      vocabSnap.docs.map((doc) => doc.data()).toList();
      List<Map<String, dynamic>> grammarQuestions =
      grammarSnap.docs.map((doc) => doc.data()).toList();

      // Shuffle để random
      vocabQuestions.shuffle(Random());
      grammarQuestions.shuffle(Random());

      // Lấy tối đa 5 câu từ mỗi collection
      final selectedVocab = vocabQuestions.take(5).toList();
      final selectedGrammar = grammarQuestions.take(5).toList();

      // Gộp lại thành 10 câu
      List<Map<String, dynamic>> allQuestions = [];
      allQuestions.addAll(selectedVocab);
      allQuestions.addAll(selectedGrammar);

      // Shuffle lại 1 lần nữa cho lẫn lộn
      allQuestions.shuffle(Random());

      setState(() {
        _questions = allQuestions;
        _currentIndex = 0;
        _score = 0;
      });

      _startTimer();
    } catch (e) {
      debugPrint("❌ Lỗi load quiz: $e");
    }
  }

  void _startTimer() {
    _timeLeft = 20;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _nextQuestion(); // hết giờ -> sang câu tiếp
      }
    });
  }

  void _checkAnswer(String optionKey) {
    if (_isAnswered) return;

    final correct = _questions[_currentIndex]["correctAnswer"];
    setState(() {
      _selectedAnswer = optionKey;
      _isAnswered = true;
      if (optionKey == correct) {
        _score += 10;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnswered = false;
        _selectedAnswer = null;
      });
      _startTimer();
    } else {
      _timer?.cancel();
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.deepPurpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 64, color: Colors.yellow),
              const SizedBox(height: 16),
              const Text(
                "Kết quả",
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                "Điểm số: $_score",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _fetchQuestions();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Chơi lại"),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = _questions[_currentIndex];
    final options = Map<String, dynamic>.from(question["options"]);
    final correct = question["correctAnswer"];

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Quick Quiz"),
          backgroundColor: Color(0xFF54BC8E),
          foregroundColor: Colors.white,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchQuestions,
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Timer + Score
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const Icon(Icons.timer, color: Colors.red),
                    const SizedBox(width: 6),
                    Text("$_timeLeft s",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red)),
                  ]),
                  Row(children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text("$_score điểm",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber)),
                  ]),
                ],
              ),
              const SizedBox(height: 20),

              // Câu hỏi
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "Câu ${_currentIndex + 1}/${_questions.length}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        question["words"][0],
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Options
              Expanded(
                child: ListView(
                  children: options.keys.map((key) {
                    final isSelected = _selectedAnswer == key;
                    final isCorrect = correct == key;

                    Color cardColor = Colors.white;
                    if (_isAnswered) {
                      if (isCorrect) {
                        cardColor = Colors.green.shade300;
                      } else if (isSelected) {
                        cardColor = Colors.red.shade300;
                      }
                    } else if (isSelected) {
                      cardColor = Colors.blue.shade100;
                    }

                    return GestureDetector(
                      onTap: () => _checkAnswer(key),
                      child: Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            "$key. ${options[key]}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
