import 'package:flutter/material.dart';
import 'package:learn_english/components/app_background.dart';
import 'widgets/quick_quiz_game.dart';
import 'widgets/memory_cards_game.dart';
import 'widgets/word_scramble_game.dart';
import 'widgets/fill_in_blank_game.dart';

class MiniGamePage extends StatelessWidget {
  const MiniGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      {
        "icon": Icons.extension,
        "title": "Memory Cards",
        "desc": "Lật tìm cặp từ vựng",
        "widget": const MemoryCardsGamePage(),
        "color": const Color(0xFF2E7D32), // Dark Green
      },
      {
        "icon": Icons.quiz,
        "title": "Quick Quiz",
        "desc": "Câu hỏi trắc nghiệm nhanh",
        "widget": const QuickQuizGamePage(),
        "color": const Color(0xFF54BC8E), // Green
      },
      {
        "icon": Icons.shuffle,
        "title": "Word Scramble",
        "desc": "Xếp chữ đúng thứ tự",
        "widget": const WordScrambleGamePage(),
        "color": const Color(0xFF66BB6A), // Light Green
      },
      {
        "icon": Icons.text_fields,
        "title": "Fill in the blank",
        "desc": "Điền từ còn thiếu",
        "widget": const FillInBlankGamePage(),
        "color": Colors.teal, // Medium Green
      },
    ];

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Mini Games",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.2,
              )),
          backgroundColor: const Color(0xFF1B5E20), // Deep Green
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.9,
            children: games.map((game) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => game["widget"] as Widget,
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                splashColor: Colors.white.withOpacity(0.3),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        game["color"] as Color,
                        Color.lerp(game["color"] as Color, Colors.black, 0.1)!
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (game["color"] as Color).withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decorative elements
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Icon(
                          Icons.circle,
                          size: 80,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      Positioned(
                        bottom: -10,
                        left: -10,
                        child: Icon(
                          Icons.circle,
                          size: 60,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),

                      // Content
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              game["icon"] as IconData,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              game["title"] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              game["desc"] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}