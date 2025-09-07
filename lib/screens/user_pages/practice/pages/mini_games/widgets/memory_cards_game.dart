import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MemoryCardsGamePage extends StatefulWidget {
  const MemoryCardsGamePage({super.key});

  @override
  State<MemoryCardsGamePage> createState() => _MemoryCardsGamePageState();
}

class _MemoryCardsGamePageState extends State<MemoryCardsGamePage> {
  List<Map<String, dynamic>> _words = [];
  late List<_CardItem> _cards;

  _CardItem? _firstSelected;
  int _matchedPairs = 0;
  int _score = 0;
  bool _isProcessing = false;

  // Timer
  int _timeLeft = 60;
  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWords();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// 🔹 Lấy 6 từ random từ Firestore
  Future<void> _fetchWords() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('vocabulary')
          .orderBy('createdAt', descending: true)
          .get();

      final allDocs = snapshot.docs.map((doc) => doc.data()).toList();

      if (allDocs.length < 6) {
        debugPrint("⚠️ Vocabulary chưa đủ 6 từ!");
      }

      // Random 6 docs
      allDocs.shuffle(Random());
      final selected = allDocs.take(6).toList();

      setState(() {
        _words = selected;
        _initGame();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Error loading vocabulary: $e");
    }
  }

  void _initGame() {
    _cards = [];
    for (var word in _words) {
      // EN card (word + pronunciation + type)
      _cards.add(
        _CardItem(
          text: "${word["word"]} ${word["pronunciation"]}\n(${word["type"]})",
          pairId: word["word"],
        ),
      );
      // VI card (meaning)
      _cards.add(
        _CardItem(
          text: word["meaning"],
          pairId: word["word"],
        ),
      );
    }

    _cards.shuffle(Random());
    _firstSelected = null;
    _matchedPairs = 0;
    _score = 0;
    _timeLeft = 60;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        _showResultDialog(false); // hết giờ
      }
    });
    setState(() {});
  }

  void _onCardTap(_CardItem card) async {
    if (_isProcessing || card.isMatched || card.isRevealed || _timeLeft == 0) return;

    setState(() {
      card.isRevealed = true;
    });

    if (_firstSelected == null) {
      _firstSelected = card;
    } else {
      _isProcessing = true;

      if (_firstSelected!.pairId == card.pairId && _firstSelected != card) {
        // Match
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() {
          _firstSelected!.isMatched = true;
          card.isMatched = true;
          _firstSelected = null;
          _matchedPairs++;
          _score += 10;

          if (_matchedPairs == _words.length) {
            _timer?.cancel();
            _showResultDialog(true);
          }
        });
      } else {
        // Not match
        await Future.delayed(const Duration(milliseconds: 1000));
        setState(() {
          _firstSelected!.isRevealed = false;
          card.isRevealed = false;
          _firstSelected = null;
        });
      }
      _isProcessing = false;
    }
  }

  void _showResultDialog(bool isWin) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isWin
                    ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
                    : [Colors.red.shade400, Colors.red.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isWin ? Icons.celebration : Icons.close,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  isWin ? "Chúc mừng!" : "Hết giờ!",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isWin
                      ? "Bạn đã hoàn thành trò chơi"
                      : "Bạn chưa kịp hoàn thành",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Điểm số: $_score",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _initGame();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor:
                    isWin ? const Color(0xFF2E7D32) : Colors.red.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Chơi lại"),
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

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("🎯 Memory Cards"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _fetchWords(), // 👉 load lại từ mới random
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Timer + Score
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
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
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return _buildCard(card);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              "Cặp đã tìm: $_matchedPairs/${_words.length}",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(_CardItem card) {
    return GestureDetector(
      onTap: () => _onCardTap(card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: card.isMatched
              ? const Color(0xFFC8E6C9).withOpacity(0.7)
              : card.isRevealed
              ? Colors.white
              : const Color(0xFF4CAF50),
          border: card.isMatched
              ? Border.all(color: const Color(0xFF2E7D32), width: 2)
              : null,
        ),
        child: Center(
          child: card.isRevealed || card.isMatched
              ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              card.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: card.isMatched
                    ? const Color(0xFF2E7D32)
                    : Colors.black87,
              ),
            ),
          )
              : const Icon(Icons.help_outline,
              color: Colors.white, size: 32),
        ),
      ),
    );
  }
}

class _CardItem {
  final String text;
  final String pairId;
  bool isRevealed;
  bool isMatched;

  _CardItem({
    required this.text,
    required this.pairId,
    this.isRevealed = false,
    this.isMatched = false,
  });
}
