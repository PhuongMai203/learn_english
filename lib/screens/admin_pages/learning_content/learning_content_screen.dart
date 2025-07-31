import 'package:flutter/material.dart';

import '../../../components/app_background.dart';
import 'learning_tab_bar.dart';
import 'tabs/courses_tab.dart';
import 'tabs/exercises_tab.dart';
import 'tabs/lessons_tab.dart';
import 'tabs/vocab_grammar_tab.dart';

class LearningContentScreen extends StatelessWidget {
  const LearningContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white, // Đặt màu nền trắng cho Scaffold
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
              LessonsTab(),
              ExercisesTab(),
              VocabGrammarTab(),
            ],
          ),
        ),
      ),
    );
  }
}