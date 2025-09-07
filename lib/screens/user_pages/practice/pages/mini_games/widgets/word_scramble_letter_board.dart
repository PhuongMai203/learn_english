import 'package:flutter/material.dart';

class WordScrambleLetterBoard extends StatelessWidget {
  final String currentWord;
  final List<String> shuffledLetters;
  final List<String> selectedLetters;
  final Animation<double> shakeAnimation;
  final void Function(String) onLetterTap;
  final void Function(int) onRemoveLetter;

  const WordScrambleLetterBoard({
    super.key,
    required this.currentWord,
    required this.shuffledLetters,
    required this.selectedLetters,
    required this.shakeAnimation,
    required this.onLetterTap,
    required this.onRemoveLetter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ô chữ đã chọn
        AnimatedBuilder(
          animation: shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(shakeAnimation.value, 0),
              child: child,
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text("Sắp xếp các chữ cái thành từ có nghĩa:",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(currentWord.length, (index) {
                    String? letter =
                    index < selectedLetters.length ? selectedLetters[index] : null;
                    return GestureDetector(
                      onTap: letter != null ? () => onRemoveLetter(index) : null,
                      child: Container(
                        width: 50,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: letter != null
                              ? const Color(0xFF81C784)
                              : const Color(0xFFEEEEEE),
                        ),
                        child: Text(
                          letter?.toUpperCase() ?? "",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: letter != null
                                ? Colors.white
                                : const Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Các chữ cái shuffle
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: shuffledLetters.length,
            itemBuilder: (context, index) {
              final letter = shuffledLetters[index];
              return GestureDetector(
                onTap: () => onLetterTap(letter),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(1, 2),
                      )
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF388E3C),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
