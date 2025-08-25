class Question {
  final String id;
  String content;
  List<String> options;
  int correctAnswerIndex;

  Question({
    required this.id,
    required this.content,
    required this.options,
    required this.correctAnswerIndex,
  });

  Question copy() {
    return Question(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      options: List<String>.from(options),
      correctAnswerIndex: correctAnswerIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      content: map['content'],
      options: List<String>.from(map['options']),
      correctAnswerIndex: map['correctAnswerIndex'],
    );
  }
}

class Test {
  final String id;
  String title;
  String description;
  int duration;
  bool isActive;
  final DateTime createdDate;
  List<Question> questions;

  Test({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.isActive,
    required this.createdDate,
    required this.questions,
  });

  int get questionCount => questions.length;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'isActive': isActive,
      'createdDate': createdDate.toIso8601String(),
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }

  factory Test.fromMap(Map<String, dynamic> map) {
    return Test(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      duration: map['duration'],
      isActive: map['isActive'],
      createdDate: DateTime.parse(map['createdDate']),
      questions: (map['questions'] as List)
          .map((q) => Question.fromMap(Map<String, dynamic>.from(q)))
          .toList(),
    );
  }
}
