class Question {
  String text;                  // Nội dung câu hỏi
  List<String> options;         // Danh sách đáp án
  int correctIndex;             // Vị trí đáp án đúng
  String level;                 // Độ khó (Dễ, Trung bình, Khó)

  Question({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.level,
  });
}

class Test {
  final String id;
  String name;                  // Tên bài test
  String description;           // Mô tả
  int duration;                 // Thời gian làm bài (phút)
  bool isActive;                // Có hiển thị hay không
  final DateTime createdDate;   // Ngày tạo
  List<Question> questions;     // Danh sách câu hỏi

  Test({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.isActive,
    required this.createdDate,
    required this.questions,
  });

  int get questionCount => questions.length;
}
