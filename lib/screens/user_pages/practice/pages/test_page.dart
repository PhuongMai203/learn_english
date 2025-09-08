import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_english/components/app_background.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  Map<String, dynamic>? _test;
  List<int?> _userAnswers = [];
  bool _submitted = false;
  int _score = 0;

  Timer? _timer;
  int _timeLeft = 0;
  bool _timeUp = false;

  @override
  void initState() {
    super.initState();
    _loadRandomTest();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadRandomTest() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection("tests").get();

      if (snapshot.docs.isNotEmpty) {
        final randomDoc =
        snapshot.docs[Random().nextInt(snapshot.docs.length)];
        final data = randomDoc.data();

        final durationMinutes = data["duration"] ?? 1;
        final totalSeconds = durationMinutes * 60;

        setState(() {
          _test = data;
          _userAnswers =
          List<int?>.filled((data["questions"] as List).length, null);
          _submitted = false;
          _score = 0;
          _timeLeft = totalSeconds;
          _timeUp = false;
        });

        _startTimer();
      }
    } catch (e) {
      debugPrint("Lỗi khi lấy dữ liệu: $e");
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        timer.cancel();
        setState(() {
          _timeUp = true;
          _submitted = true;
        });
      }
    });
  }

  void _submit() {
    if (_test == null) return;

    final questions = List<Map<String, dynamic>>.from(_test!["questions"]);
    int correct = 0;

    for (int i = 0; i < questions.length; i++) {
      if (_userAnswers[i] == questions[i]["correctAnswerIndex"]) {
        correct++;
      }
    }

    setState(() {
      _score = ((correct / questions.length) * 100).round();
      _submitted = true;
      _timer?.cancel();
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Bài Kiểm Tra", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Color(0xE5B56DDC),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: _test == null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xE5B56DDC)),
              ),
              SizedBox(height: 16),
              Text(
                "Đang tải đề kiểm tra...",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xE57610A6),
                ),
              ),
            ],
          ),
        )
            : _submitted
            ? _buildResults()
            : _buildTestContent(),
      ),
    );
  }

  Widget _buildResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_timeUp) ...[
              Icon(
                Icons.timer_off_rounded,
                size: 70,
                color: Colors.red.shade400,
              ),
              SizedBox(height: 20),
              Text(
                "Hết thời gian!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Bạn đã không hoàn thành bài kiểm tra trong thời gian quy định",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ] else ...[
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _score >= 50
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "$_score",
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: _score >= 50
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Điểm số của bạn",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "$_score/100",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _score >= 50
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                ),
              ),
              SizedBox(height: 16),
              Text(
                _score >= 80 ? "Xuất sắc!"
                    : _score >= 50 ? "Khá tốt!"
                    : "Cần cố gắng hơn!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _loadRandomTest,
              icon: Icon(Icons.refresh),
              label: Text("Làm bài kiểm tra khác"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xE59C5DC1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTestContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _test!["title"] ?? "Không có tiêu đề",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade800,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      "Thời lượng:",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(), // đẩy đồng hồ ra bên phải
                    if (_test != null && !_submitted)
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 18,
                            color: _timeLeft <= 60 ? Colors.red : Color(
                                0xE5450561),
                          ),
                          SizedBox(width: 6),
                          Text(
                            _formatTime(_timeLeft),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _timeLeft <= 60 ? Colors.red : Color(
                                  0xE5470668),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),


              ],
            ),
          ),
          SizedBox(height: 24),

          // Questions
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: (_test!["questions"] as List).length,
            itemBuilder: (context, index) {
              final q = _test!["questions"][index];
              final options = List<String>.from(q["options"] ?? []);

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "Câu ${index + 1}: ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade600,
                          ),
                          children: [
                            TextSpan(
                              text: q["content"] ?? "",
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Column(
                        children: options.asMap().entries.map((entry) {
                          final optIndex = entry.key;
                          final opt = entry.value;
                          final isSelected = _userAnswers[index] == optIndex;
                          final isCorrect = q["correctAnswerIndex"] == optIndex;

                          Color borderColor = Colors.grey.shade300;
                          Color bgColor = Colors.transparent;
                          Color textColor = Colors.black87;

                          if (_submitted) {
                            if (isCorrect) {
                              borderColor = Colors.green;
                              bgColor = Colors.green.shade50;
                              textColor = Colors.green.shade800;
                            } else if (isSelected && !isCorrect) {
                              borderColor = Colors.red;
                              bgColor = Colors.red.shade50;
                              textColor = Colors.red.shade800;
                            }
                          } else if (isSelected) {
                            borderColor = Color(0xE5B75EE4);
                            bgColor = Colors.deepPurple.shade50;
                            textColor = Colors.deepPurple.shade700;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: borderColor,
                                width: 1.5,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _submitted
                                  ? null
                                  : () {
                                setState(() {
                                  _userAnswers[index] = optIndex;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: borderColor,
                                          width: 2,
                                        ),
                                        color: isSelected ? Color(0xE5C77AF3) : Colors.transparent,
                                      ),
                                      child: isSelected
                                          ? Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                          : null,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        opt,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    if (_submitted && isCorrect)
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    if (_submitted && isSelected && !isCorrect)
                                      Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 24),

          // Nút nộp bài
          Center(
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xE5B45CEC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 20),
                  SizedBox(width: 8),
                  Text("Nộp bài kiểm tra"),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}