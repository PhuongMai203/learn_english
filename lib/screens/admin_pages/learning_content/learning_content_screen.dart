import 'package:flutter/material.dart';

import '../../../components/app_background.dart';
import 'learning_tab_bar.dart';
import 'tabs/courses_tab.dart';
import 'tabs/exercises_tab.dart';
import 'tabs/lessons_tab.dart';
import 'tabs/vocab_grammar_tab.dart';

class LearningContentScreen extends StatelessWidget {
  final int initialIndex; // thêm tham số

  const LearningContentScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: initialIndex, // set tab mặc định
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Nội dung học',
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 5,
          bottom: const LearningTabBar(),
        ),
        body: const AppBackground(
          child: TabBarView(
            children: [
              CoursesTab(),
              LessonListScreen(),
              ExercisesTab(),
              VocabGrammarTab(),
            ],
          ),
        ),
      ),
    );
  }
}
