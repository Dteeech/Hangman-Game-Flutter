import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hangman Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HangmanGamePage(),
    );
  }
}

class HangmanGamePage extends StatefulWidget {
  const HangmanGamePage({Key? key}) : super(key: key);

  @override
  _HangmanGamePageState createState() => _HangmanGamePageState();
}

class _HangmanGamePageState extends State<HangmanGamePage> {
  final List<String> words = ['flutter', 'dart', 'hangman', 'game'];
  List<bool> letterUsed = List.filled(26, false);
  late String currentWord;
  late String displayedWord;
  int remainingAttempts = 10;
  bool isGameOver = false;
  TextEditingController wordController = TextEditingController();
  int incorrectAttempts = 0;
  late AnimationController _controller;
  late Animation<double> _jumpAnimation;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      currentWord = '';
      displayedWord = '';
      remainingAttempts = 10;
      isGameOver = false;
      incorrectAttempts = 0;
      letterUsed = List.filled(26, false); // Réinitialiser la liste des lettres utilisées
    });
  }

  void _checkLetter(String letter) {
    setState(() {
      if (!isGameOver && !letterUsed[letter.codeUnitAt(0) - 'a'.codeUnitAt(0)]) {
        bool letterFound = false;
        String newDisplayedWord = '';
        for (int i = 0; i < currentWord.length; i++) {
          if (currentWord[i] == letter) {
            newDisplayedWord += letter;
            letterFound = true;
          } else {
            newDisplayedWord += displayedWord[i];
          }
        }
        displayedWord = newDisplayedWord;
        if (!letterFound) {
          remainingAttempts--;
          incorrectAttempts++;
          if (remainingAttempts == 0) {
            isGameOver = true;
          }
        }
        if (displayedWord == currentWord) {
          isGameOver = true;
        }
        letterUsed[letter.codeUnitAt(0) - 'a'.codeUnitAt(0)] = true; // Marquer la lettre comme utilisée
      }
    });
  }

  void _startGameWithCustomWord() {
    String word = wordController.text.trim().toLowerCase();
    if (word.isNotEmpty) {
      setState(() {
        currentWord = word;
        displayedWord = '*' * word.length;
        wordController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hangman Game'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (currentWord.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: wordController,
                        decoration: const InputDecoration(
                            labelText: 'Enter a word to guess'),
                      ),
                      ElevatedButton(
                        onPressed: _startGameWithCustomWord,
                        child: const Text('Start Game'),
                      ),
                    ],
                  ),
                ),
              if (currentWord.isNotEmpty)
                Column(
                  children: [
                    Text(
                      'Remaining attempts: $remainingAttempts',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      displayedWord,
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    if (isGameOver)
                      Text(
                        displayedWord == currentWord ? 'You won!' : 'You lost!',
                        style: const TextStyle(fontSize: 20, color: Colors.red),
                      ),
                    if (!isGameOver)
                      Wrap(
                        spacing: 10,
                        children: List.generate(
                          26,
                          (index) => TextButton(
                            onPressed: letterUsed[index] ? null : () {
                              final letter = String.fromCharCode('a'.codeUnitAt(0) + index);
                              _checkLetter(letter);
                            },
                            child: Text(
                              String.fromCharCode('a'.codeUnitAt(0) + index),
                              style: TextStyle(
                                fontSize: 20,
                                decoration: letterUsed[index] ? TextDecoration.lineThrough : null, // Barre la lettre si elle a été utilisée
                                color: letterUsed[index] ? Colors.red : null, // Change la couleur en rouge si elle a été utilisée
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (isGameOver)
                      ElevatedButton(
                        onPressed: _startNewGame,
                        child: const Text('New Game'),
                      ),
                    const SizedBox(height: 20),
                    // Dessin du pendu
                    CustomPaint(
                      size: const Size(200, 200),
                      painter:
                          HangmanPainter(incorrectAttempts: incorrectAttempts),
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


class HangmanPainter extends CustomPainter {
  final int incorrectAttempts;

  HangmanPainter({required this.incorrectAttempts});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Ligne du haut
    if (incorrectAttempts > 0) {
      canvas.drawLine(Offset(size.width / 4, size.height / 6),
          Offset(3 * size.width / 4, size.height / 6), paint);
    }

    // Ligne verticale
    if (incorrectAttempts > 1) {
      canvas.drawLine(
        Offset(size.width / 4, size.height / 6), // Début à gauche
        Offset(size.width / 4, 5 * size.height / 6), // Fin à la hauteur totale
        paint,
      );
    }

    // Petite ligne diagonale
    if (incorrectAttempts > 2) {
      canvas.drawLine(
        Offset(
            1.5 * size.width / 4,
            size.height /
                6), // Début légèrement à droite du début de la première ligne horizontale
        Offset(size.width / 4, 2 * size.height / 4), // Fin au 3/4 de la hauteur
        paint,
      );
    }

    // Ligne verticale
    if (incorrectAttempts > 3) {
      canvas.drawLine(
        Offset(
            size.width / 2,
            size.height /
                6), // Début au milieu de la première ligne horizontale
        Offset(size.width / 2, size.height / 3), // Fin à un tiers de la hauteur
        paint,
      );
    }

    // Tête du pendu
    if (incorrectAttempts > 4) {
      canvas.drawCircle(
          Offset(size.width / 2, size.height / 5 + 40), 15, paint);
    }

    // Corps
    if (incorrectAttempts > 5) {
      canvas.drawLine(
        Offset(size.width / 2, size.height / 5 + 50), // Début au niveau du cou
        Offset(size.width / 2, size.height / 3 + 80), // Fin un peu plus bas
        paint,
      );
    }

    if (incorrectAttempts > 6) {
      // Bras gauche
      canvas.drawLine(Offset(size.width / 2, size.height / 3 + 50),
          Offset(size.width / 2 - 30, size.height / 3 + 20), paint);
    }

    if (incorrectAttempts > 7) {
      // Bras droit
      canvas.drawLine(
          Offset(
              size.width / 2, size.height / 3 + 50), // Début au niveau du corps
          Offset(size.width / 2 + 30,
              size.height / 3 + 20), // Fin un peu plus bas et vers la droite
          paint);
    }

    // Jambe gauche
    if (incorrectAttempts > 8) {
      canvas.drawLine(
        Offset(
            size.width / 2, size.height / 3 + 80), // Début au niveau du corps
        Offset(size.width / 2 - 30,
            size.height * 2 / 2), // Fin un peu plus bas et vers la gauche
        paint,
      );
    }

    if (incorrectAttempts > 9) {
      // Jambe droite
      canvas.drawLine(Offset(size.width / 2, size.height / 3 + 80),
          Offset(size.width / 2 + 30, size.height * 2 / 2), paint);
    }
  }
//ici pour l'animation liée au canva
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
