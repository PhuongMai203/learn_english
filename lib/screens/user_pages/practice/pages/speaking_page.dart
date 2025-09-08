import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:learn_english/components/app_background.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeakingPage extends StatefulWidget {
  const SpeakingPage({super.key});

  @override
  State<SpeakingPage> createState() => _SpeakingPageState();
}

class _SpeakingPageState extends State<SpeakingPage> {
  late FlutterTts _flutterTts;
  late stt.SpeechToText _speech;

  bool _isListening = false;
  String _userText = "";
  bool _speechAvailable = false;

  Map<String, dynamic>? _currentWord; // document hiện tại

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _speech = stt.SpeechToText();

    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.4);
    _flutterTts.setPitch(1.0);

    _initSpeech();
    _loadRandomWord();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) => debugPrint("🔊 Status: $status"),
      onError: (error) => debugPrint("❌ Error: $error"),
    );
    setState(() {});
  }

  Future<void> _loadRandomWord() async {
    final snapshot = await FirebaseFirestore.instance.collection("vocabulary").get();

    if (snapshot.docs.isNotEmpty) {
      final randomDoc = snapshot.docs[Random().nextInt(snapshot.docs.length)];
      setState(() {
        _currentWord = randomDoc.data();
        _userText = "";
      });
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speech.stop();
    super.dispose();
  }

  void _playSample() async {
    if (_currentWord != null) {
      await _flutterTts.speak(_currentWord!["word"]);
    }
  }

  void _startListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Micro không khả dụng. Hãy bật quyền truy cập.")),
      );
      return;
    }

    setState(() {
      _isListening = true;
      _userText = "";
    });

    bool available = await _speech.listen(
      onResult: (result) {
        setState(() {
          _userText = result.recognizedWords;
        });

        if (result.finalResult) {
          _stopListening();
          Future.delayed(const Duration(seconds: 3), () {
            _loadRandomWord();
          });
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      localeId: "en_US",
      partialResults: true,
    );

    if (!available) {
      setState(() => _isListening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể bắt đầu ghi âm.")),
      );
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  String _normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r"[^\w\s]"), "").replaceAll(RegExp(r"\s+"), " ").trim();
  }

  bool get _isCorrect {
    if (_currentWord == null) return false;
    return _normalize(_userText) == _normalize(_currentWord!["word"]);
  }

  @override
  Widget build(BuildContext context) {
    final word = _currentWord?["word"] ?? "...";
    final meaning = _currentWord?["meaning"] ?? "";
    final pronunciation = _currentWord?["pronunciation"] ?? "";
    final type = _currentWord?["type"] ?? "";

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Luyện nói",style: TextStyle( fontSize: 20),),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: _currentWord == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        word,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "$type | $pronunciation",
                        style: const TextStyle(
                            fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        meaning,
                        style: const TextStyle(
                            fontSize: 20, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _playSample,
                    icon: const Icon(Icons.volume_up, size: 26),
                    label: const Text("Nghe mẫu"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: _loadRandomWord,
                    icon: const Icon(Icons.refresh, size: 26),
                    label: const Text("Từ khác"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 🔹 Nút luyện nói to ở dưới
              ElevatedButton.icon(
                onPressed: _isListening ? _stopListening : _startListening,
                icon: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  size: 28,
                ),
                label: Text(
                  _isListening ? "Dừng ghi âm" : "Bắt đầu luyện nói",
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor:
                  _isListening ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (_isListening)
                const Text(
                  "🎙 Đang nghe...",
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),

              const SizedBox(height: 20),

              if (_userText.isNotEmpty)
                Column(
                  children: [
                    const Text(
                      "Bạn vừa nói:",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _userText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isCorrect
                          ? "Phát âm chính xác!"
                          : "Thử lại nhé!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                        _isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
