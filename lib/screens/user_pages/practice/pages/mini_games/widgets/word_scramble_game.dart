import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_english/components/app_background.dart';
import 'word_scramble_header.dart';
import 'word_scramble_letter_board.dart';

class WordScrambleGamePage extends StatefulWidget {
  const WordScrambleGamePage({super.key});

  @override
  State<WordScrambleGamePage> createState() => _WordScrambleGamePageState();
}

class _WordScrambleGamePageState extends State<WordScrambleGamePage>
    with TickerProviderStateMixin {
  List<String> _words = []; // 🔹 Lấy từ Firestore
  bool _isLoading = true;

  late String _currentWord;
  late List<String> _shuffledLetters;
  List<String> _selectedLetters = [];

  int _score = 0;
  int _timeLeft = 60;
  int _currentLevel = 1;
  Timer? _timer;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _successController;

  int _currentIndex = 0; // 🔹 Chỉ số từ hiện tại

  @override
  void initState() {
    super.initState();
    _fetchWords(); // 🔹 Lấy dữ liệu từ Firestore

    _shakeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  Future<void> _fetchWords() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('vocabulary').get();

      final words = snapshot.docs
          .map((doc) => doc['word']?.toString().trim())
          .where((w) => w != null && w.isNotEmpty)
          .cast<String>()
          .toList();

      words.shuffle(); // 🔹 Trộn ngẫu nhiên danh sách

      setState(() {
        _words = words.take(20).toList(); // 🔹 Giới hạn tối đa 20 từ
        _isLoading = false;
      });

      if (_words.isNotEmpty) {
        _currentIndex = 0;
        _startNewWord();
        _startTimer();
      }
    } catch (e) {
      debugPrint("❌ Lỗi khi lấy dữ liệu từ Firestore: $e");
      setState(() => _isLoading = false);
    }
  }

  void _startNewWord() {
    if (_words.isEmpty) return;

    if (_currentIndex >= _words.length) {
      _currentIndex = 0;
      _words.shuffle(); // 🔹 Trộn lại khi chơi hết danh sách
    }

    _currentWord = _words[_currentIndex];
    _shuffledLetters = _currentWord.split('')..shuffle();
    _selectedLetters = [];
    _currentIndex++; // 🔹 Sang từ tiếp theo

    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        timer.cancel();
        _showTimeUpDialog();
      }
    });
  }

  void _onLetterTap(String letter) {
    if (_selectedLetters.length < _currentWord.length) {
      setState(() {
        _selectedLetters.add(letter);
        _shuffledLetters.remove(letter);
      });
    }
  }

  void _onRemoveLetter(int index) {
    final letter = _selectedLetters[index];
    setState(() {
      _selectedLetters.removeAt(index);
      _shuffledLetters.add(letter);
    });
  }

  void _checkAnswer() {
    if (_selectedLetters.join('') == _currentWord) {
      _score += 10;
      if (_score % 30 == 0) _currentLevel++;
      _successController.forward(from: 0);
      _showResultDialog(true);
    } else {
      _shakeController.forward(from: 0);
      _showResultDialog(false);
    }
  }

  void _showResultDialog(bool isCorrect) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isCorrect
                    ? [const Color(0xFF81C784), const Color(0xFF66BB6A)] // Màu nhạt hơn
                    : [const Color(0xFFEF9A9A), const Color(0xFFE57373)], // Màu đỏ nhạt hơn
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCorrect ? Icons.celebration : Icons.error,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  isCorrect ? "Chính xác!" : "Sai rồi",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isCorrect
                      ? "Bạn đã sắp xếp đúng từ '${_currentWord.toUpperCase()}'"
                      : "Đáp án đúng là '${_currentWord.toUpperCase()}'",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _startNewWord();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: isCorrect ? const Color(0xFF66BB6A) : const Color(0xFFE57373),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: Icon(isCorrect ? Icons.play_arrow : Icons.refresh),
                  label: Text(
                    isCorrect ? "Tiếp tục" : "Thử lại",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFB74D), Color(0xFFFFA726)], // Màu cam nhạt hơn
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timer_off,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Hết thời gian!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Bạn không kịp sắp xếp từ '${_currentWord.toUpperCase()}'",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _startTimer();
                    _startNewWord();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFFA726),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    "Chơi lại",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_words.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("⚠️ Không có dữ liệu từ vựng trong Firestore")),
      );
    }

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Word Scramble",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          backgroundColor: const Color(0xFF66BB6A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body: Column(
          children: [
            WordScrambleHeader(
              score: _score,
              level: _currentLevel,
              timeLeft: _timeLeft,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: WordScrambleLetterBoard(
                currentWord: _currentWord,
                shuffledLetters: _shuffledLetters,
                selectedLetters: _selectedLetters,
                shakeAnimation: _shakeAnimation,
                onLetterTap: _onLetterTap,
                onRemoveLetter: _onRemoveLetter,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton.icon(
                onPressed: _checkAnswer,
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  backgroundColor: const Color(0xFF66BB6A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.check_circle, size: 28),
                label: const Text("KIỂM TRA",
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
