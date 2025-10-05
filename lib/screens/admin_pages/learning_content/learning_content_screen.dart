import 'package:flutter/material.dart';

import '../../../components/app_background.dart';
import 'learning_tab_bar.dart';
import 'tabs/courses_tab.dart';
import 'tabs/exercises_tab.dart';
import 'tabs/lessons_tab.dart';
import 'tabs/vocab_grammar_tab.dart';
import '../testadmin/tests_tab.dart';

class LearningContentScreen extends StatelessWidget {
  final int initialIndex; // thêm tham số

  const LearningContentScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      initialIndex: initialIndex, // set tab mặc định
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Nội dung học',
            style: TextStyle(
              color: Color(0xFF3F978B),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 5,
          bottom: const LearningTabBar(),
        ),
        body: AppBackground(
          child: TabBarView(
            children: [
              const CoursesTab(),
              const LessonListScreen(),
              const ExercisesTab(),
              const VocabGrammarTab(),
              AdminTestsScreen(),

            ],
          ),
        ),
      ),
    );
  }
}
