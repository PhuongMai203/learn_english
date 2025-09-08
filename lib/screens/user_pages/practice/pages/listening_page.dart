import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ListeningPage extends StatefulWidget {
  const ListeningPage({super.key});

  @override
  State<ListeningPage> createState() => _ListeningPageState();
}

class _ListeningPageState extends State<ListeningPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, dynamic>> _exercises = [
    {
      "title": "1",
      "audioUrl":
      "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
      "transcript": "She usually ___ to school by bus.",
      "options": ["go", "gone", "goes", "going"],
      "answer": "goes",
    },
    {
      "title": "2",
      "audioUrl":
      "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
      "transcript": "I ___ a book every evening.",
      "options": ["read", "reads", "reading", "wrote"],
      "answer": "read",
    },
    {
      "title": "3",
      "audioUrl":
      "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
      "transcript": "They ___ football in the park yesterday.",
      "options": ["play", "played", "playing", "plays"],
      "answer": "played",
    },
  ];

  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _isPlaying = false;

  void _checkAnswer(String selected, String correct) {
    setState(() {
      _selectedAnswer = selected;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (_currentIndex < _exercises.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
        });
      } else {
        _showFinishDialog();
      }
    });
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🎉 Hoàn thành"),
        content: const Text("Bạn đã hoàn thành tất cả bài luyện nghe."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String url) async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
    }
    await _audioPlayer.play(UrlSource(url));
    setState(() => _isPlaying = true);

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() => _isPlaying = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _exercises[_currentIndex];
    final options = (exercise["options"] as List).cast<String>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Luyện nghe - Câu ${_currentIndex + 1}/${_exercises.length}"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Nút play audio
            ElevatedButton.icon(
              onPressed: () => _playAudio(exercise["audioUrl"]),
              icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(_isPlaying ? "Dừng lại" : "Nghe lại"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Transcript
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                exercise["transcript"] ?? "",
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // 🔹 Options
            ...options.map((opt) {
              final isCorrect = opt == exercise["answer"];
              final isSelected = opt == _selectedAnswer;

              Color? color;
              if (_selectedAnswer != null && isSelected) {
                color = isCorrect ? Colors.green : Colors.red;
              }

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color ?? Colors.blue.shade50,
                    foregroundColor: color != null ? Colors.white : Colors.black,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: _selectedAnswer == null
                      ? () => _checkAnswer(opt, exercise["answer"])
                      : null,
                  child: Text(opt),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
