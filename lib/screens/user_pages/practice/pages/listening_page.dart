import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:learn_english/components/app_background.dart';

class ListeningPage extends StatefulWidget {
  const ListeningPage({super.key});

  @override
  State<ListeningPage> createState() => _ListeningPageState();
}

class _ListeningPageState extends State<ListeningPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _answered = false;

  final List<Map<String, dynamic>> _exercises = [
    {
      "text": "I usually wake up at 6 a.m.",
      "options": ["Tôi thường thức dậy lúc 6 giờ sáng", "Tôi đi ngủ lúc 6 giờ sáng"],
      "answer": "Tôi thường thức dậy lúc 6 giờ sáng",
      "transcript": "I usually wake up at 6 a.m."
    },
    {
      "text": "She is reading a book in the library.",
      "options": ["Cô ấy đang đọc sách trong thư viện", "Cô ấy đang viết sách"],
      "answer": "Cô ấy đang đọc sách trong thư viện",
      "transcript": "She is reading a book in the library."
    },
    {
      "text": "They are playing football in the park.",
      "options": ["Họ đang chơi bóng đá trong công viên", "Họ đang ăn tối trong công viên"],
      "answer": "Họ đang chơi bóng đá trong công viên",
      "transcript": "They are playing football in the park."
    },
  ];

  Future<void> _playText(String text) async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.play(UrlSource(
          "https://translate.google.com/translate_tts?ie=UTF-8&q=$text&tl=en&client=tw-ob"));
      setState(() => _isPlaying = true);

      _audioPlayer.onPlayerComplete.listen((_) {
        setState(() => _isPlaying = false);
      });
    }
  }

  void _checkAnswer(String selected) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = selected;
      _answered = true;
      if (selected == _exercises[_currentIndex]["answer"]) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      _showResult();
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _selectedAnswer = null;
        _answered = false;
      });
    }
  }

  void _showResult() {
    final total = _exercises.length;
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
              const Icon(Icons.emoji_events,
                  size: 64, color: Color(0xFFFFC107)), // icon vàng
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                    ),
                    child: const Text("Làm lại"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                    ),
                    child: const Text("Đóng"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _exercises[_currentIndex];

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            "Luyện nghe - Câu ${_currentIndex + 1}/${_exercises.length}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF90CAF9), // pastel blue
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Transcript
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  exercise["transcript"] ?? "",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xF5000000),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Play button
              ElevatedButton.icon(
                onPressed: () => _playText(exercise["text"]),
                icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                label: Text(_isPlaying ? "Dừng lại" : "Nghe đoạn văn"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF64B5F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
              ),
              const SizedBox(height: 20),

              // Options
              ...exercise["options"].map<Widget>((option) {
                final isCorrect = option == exercise["answer"];
                final isSelected = option == _selectedAnswer;

                Color? color;
                if (_answered) {
                  if (isSelected) {
                    color = isCorrect ? Colors.green[300] : Colors.red[300];
                  } else if (isCorrect) {
                    color = Colors.green[100];
                  }
                }

                return GestureDetector(
                  onTap: () => _checkAnswer(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: color ?? const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color ?? const Color(0xFF90CAF9),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? (isCorrect
                              ? Icons.check_circle
                              : Icons.cancel_outlined)
                              : Icons.circle_outlined,
                          color: isSelected
                              ? (isCorrect ? Colors.green : Colors.red)
                              : const Color(0xFF0D47A1),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const Spacer(),

              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed:
                    _currentIndex > 0 ? _previousQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF90CAF9),
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Icon(Icons.arrow_back),
                  ),
                  ElevatedButton(
                    onPressed: _answered ? _nextQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF64B5F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 24),
                    ),
                    child: Text(
                      _currentIndex == _exercises.length - 1
                          ? "Kết thúc"
                          : "Tiếp theo",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
