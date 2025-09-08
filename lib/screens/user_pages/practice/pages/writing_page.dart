import 'dart:math';
import 'package:flutter/material.dart';
import 'package:learn_english/components/app_background.dart';

class WritingPage extends StatefulWidget {
  const WritingPage({super.key});

  @override
  State<WritingPage> createState() => _WritingPageState();
}

class _WritingPageState extends State<WritingPage> {
  final TextEditingController _controller = TextEditingController();
  late Map<String, dynamic> _currentTopic;

  int _timeLeft = 900;
  int? _score;
  String? _feedback;
  bool _submitted = false; // đã nộp bài?
  bool _timeUp = false; // hết giờ?

  final List<Map<String, dynamic>> topics = [
    {
      "title": "Viết một đoạn ngắn giới thiệu bản thân.",
      "answer": "My name is ... I am ... years old. I like ...",
      "keywords": ["name", "years old", "like"]
    },
    {
      "title": "Viết về sở thích của bạn.",
      "answer": "I like reading books and playing football.",
      "keywords": ["like", "reading", "books", "football"]
    },
    {
      "title": "Viết một đoạn về gia đình của bạn.",
      "answer": "There are four people in my family: ...",
      "keywords": ["family", "father", "dad", "mother", "mom", "parents", "brother", "sister"]
    },
    {
      "title": "Viết một đoạn về ngôi trường của bạn.",
      "answer": "My school is big and beautiful.",
      "keywords": ["school", "teacher", "student", "classroom"]
    },
    {
      "title": "Viết một đoạn về một người bạn thân.",
      "answer": "My best friend is kind and friendly.",
      "keywords": ["friend", "best friend", "classmate", "kind", "friendly", "play", "help"]
    },
    {
      "title": "Viết về một chuyến đi đáng nhớ.",
      "answer": "Last summer I went to the beach with my family.",
      "keywords": ["trip", "summer", "beach", "family"]
    },
    {
      "title": "Viết một đoạn về thói quen hàng ngày của bạn.",
      "answer": "I usually get up at 6 a.m. and go to school.",
      "keywords": ["usually", "get up", "school", "homework"]
    },
    {
      "title": "Viết một đoạn về một bộ phim bạn yêu thích.",
      "answer": "My favorite movie is ... because ...",
      "keywords": ["movie", "favorite", "because"]
    },
    {
      "title": "Viết một đoạn về một cuốn sách bạn thích.",
      "answer": "I like reading ... because it is interesting.",
      "keywords": ["book", "reading", "interesting"]
    },
    {
      "title": "Viết về thời tiết hôm nay.",
      "answer": "Today the weather is sunny and hot.",
      "keywords": ["weather", "sunny", "hot", "rainy", "cold"]
    },
    {
      "title": "Viết về kế hoạch cuối tuần của bạn.",
      "answer": "I am going to visit my grandparents this weekend.",
      "keywords": ["weekend", "grandparents", "visit"]
    },
    {
      "title": "Viết một đoạn về thành phố bạn đang sống.",
      "answer": "I live in ... It is a big city.",
      "keywords": ["city", "live", "big"]
    },
    {
      "title": "Viết về một món ăn bạn thích.",
      "answer": "My favorite food is ...",
      "keywords": ["food", "favorite", "eat"]
    },
    {
      "title": "Viết một đoạn về một môn học bạn thích.",
      "answer": "I like English because it is useful.",
      "keywords": ["subject", "English", "favorite"]
    },
    {
      "title": "Viết một đoạn về một môn thể thao bạn thích.",
      "answer": "I like football. It is exciting.",
      "keywords": ["sport", "football", "exciting"]
    },
    {
      "title": "Viết về ước mơ của bạn.",
      "answer": "I want to become a doctor in the future.",
      "keywords": ["dream", "future", "doctor"]
    },
    {
      "title": "Viết một đoạn về một ngày nghỉ lễ.",
      "answer": "On Christmas holiday, my family ...",
      "keywords": ["holiday", "family", "celebrate", "food"]
    },
    {
      "title": "Viết về một người nổi tiếng mà bạn ngưỡng mộ.",
      "answer": "I admire ... because ...",
      "keywords": ["famous", "admire", "because"]
    },
    {
      "title": "Viết một đoạn về lợi ích của việc học tiếng Anh.",
      "answer": "Learning English helps me communicate with foreigners.",
      "keywords": ["English", "learning", "communicate"]
    },
    {
      "title": "Viết một đoạn nghị luận về môi trường.",
      "answer": "We must protect the environment by ...",
      "keywords": ["environment", "protect", "pollution", "clean"]
    },
  ];

  @override
  void initState() {
    super.initState();
    _pickRandomTopic();
    _startTimer();
  }

  void _pickRandomTopic() {
    final random = Random();
    setState(() {
      _currentTopic = topics[random.nextInt(topics.length)];
      _score = null;
      _feedback = null;
      _submitted = false;
      _timeUp = false;
      _timeLeft = 900; // reset 5 phút
      _controller.clear();
    });
    _startTimer();
  }

  void _startTimer() async {
    Future.doWhile(() async {
      if (_timeLeft <= 0 || _submitted) {
        if (_timeLeft <= 0 && !_submitted) {
          setState(() {
            _timeUp = true; // hết giờ mà chưa nộp
          });
        }
        return false;
      }
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _timeLeft--;
        });
      }
      return true;
    });
  }

  int _levenshtein(String word1, String word2) {
    int len1 = word1.length;
    int len2 = word2.length;
    List<List<int>> dp =
    List.generate(len1 + 1, (_) => List.filled(len2 + 1, 0));

    for (int i = 0; i <= len1; i++) dp[i][0] = i;
    for (int j = 0; j <= len2; j++) dp[0][j] = j;

    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        if (word1[i - 1] == word2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] =
              1 + min(dp[i - 1][j], min(dp[i][j - 1], dp[i - 1][j - 1]));
        }
      }
    }
    return dp[len1][len2];
  }

  double _similarity(String w1, String w2) {
    int dist = _levenshtein(w1, w2);
    int maxLen = max(w1.length, w2.length);
    if (maxLen == 0) return 1.0;
    return 1 - (dist / maxLen);
  }

  void _submit() {
    final userText = _controller.text.toLowerCase();

    List<String> keywords = List<String>.from(_currentTopic["keywords"] ?? []);
    if (keywords.isEmpty) {
      setState(() {
        _score = 0;
        _feedback = "Chưa có từ khóa để chấm điểm.";
        _submitted = true;
      });
      return;
    }

    int matched = 0;
    List<String> missing = [];

    for (var kw in keywords) {
      bool found = false;
      for (var word in userText.split(RegExp(r'\s+'))) {
        if (_similarity(word, kw.toLowerCase()) > 0.8) {
          found = true;
          break;
        }
      }
      if (found) {
        matched++;
      } else {
        missing.add(kw);
      }
    }

    double scorePercent = (matched / keywords.length) * 100;
    int score = scorePercent.round();

    String comment;
    if (score >= 80) {
      comment = "Bài viết đúng chủ đề và có đủ ý chính.";
    } else {
      comment =
      "Bài viết thiếu ý chính hoặc dùng từ khác. Gợi ý thêm: ${missing.join(", ")}";
    }

    setState(() {
      _score = score;
      _feedback = "Điểm: $score/100\nNhận xét: $comment";
      _submitted = true; // dừng đếm giờ
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Luyện viết"),
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_submitted && !_timeUp)
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      "Thời gian còn lại: $_timeLeft giây",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.assignment, color: Colors.black87),
                  const SizedBox(width: 8),
                  Expanded(   // 👈 Thêm Expanded để Text chiếm phần còn lại và xuống dòng
                    child: Text(
                      "Đề bài: ${_currentTopic["title"]}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    enabled: !_submitted && !_timeUp,
                    cursorColor: Colors.black,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(4),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Nút hành động
              if (!_submitted && !_timeUp)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.send),
                        label: const Text("Nộp bài"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FloatingActionButton(
                      mini: true,
                      onPressed: _pickRandomTopic,
                      backgroundColor: Colors.orange,
                      child: const Icon(Icons.refresh),
                    ),
                  ],
                ),

              if (_submitted && !_timeUp) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _score! > 85 ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    _feedback ?? "",
                    style: TextStyle(
                      fontSize: 16,
                      color: _score! > 85 ? Colors.green[900] : Colors.red[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickRandomTopic,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Làm bài khác"),
                ),
              ],

              if (_timeUp) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    "⏰ Hết thời gian!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickRandomTopic,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text("Làm lại"),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
