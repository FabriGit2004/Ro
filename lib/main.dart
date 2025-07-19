import 'package:flutter/material.dart';

void main() {
  runApp(const PixelKnightGame());
}

class PixelKnightGame extends StatefulWidget {
  const PixelKnightGame({super.key});

  @override
  State<PixelKnightGame> createState() => _PixelKnightGameState();
}

class _PixelKnightGameState extends State<PixelKnightGame> with SingleTickerProviderStateMixin {
  double knightPos = 0.0;
  bool lookingRight = false;
  int level = 0;
  bool enemyDefeated = false;
  bool showHeart = false;

  late final AnimationController _heartController;
  late final Animation<double> _heartAnimation;

  final List<String> backgrounds = [
    'assets/bg1.png',
    'assets/bg2.png',
    'assets/bg3.png',
  ];

  final double enemyPosX = 0.65;
  final double princessPosX = 0.9;

  @override
  void initState() {
    super.initState();

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _heartAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void moveKnight(bool right) {
    setState(() {
      if (right) {
        knightPos += 0.05;
        if (knightPos > 1.0) knightPos = 1.0;
        lookingRight = false;
      } else {
        knightPos -= 0.05;
        if (knightPos < 0) knightPos = 0;
        lookingRight = true;
      }

      if (knightPos > 0.9 && enemyDefeated && level < 2) {
        level++;
        knightPos = 0;
        enemyDefeated = false;
        showHeart = false;
        _heartController.stop();
      }

      if (level == 2 && (knightPos - princessPosX).abs() < 0.25) {
        if (!showHeart) {
          showHeart = true;
          _heartController.repeat(reverse: true);
        }
      } else {
        if (showHeart) {
          showHeart = false;
          _heartController.stop();
        }
      }
    });
  }

  void attackEnemy() {
    if ((knightPos - enemyPosX).abs() < 0.3 && !enemyDefeated) {
      setState(() {
        enemyDefeated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = 390.0;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                backgrounds[level],
                fit: BoxFit.cover,
              ),
            ),

            if (!enemyDefeated && level < 2)
              Positioned(
                left: enemyPosX * screenWidth,
                bottom: 100,
                child: Image.asset('assets/enemy.png', width: 60),
              ),

            if (level == 2)
              Positioned(
                left: princessPosX * screenWidth - 20,
                bottom: 100,
                child: Image.asset('assets/princess.png', width: 60),
              ),

            if (showHeart)
              Positioned(
                left: (princessPosX * screenWidth) - 10,
                bottom: 160,
                child: ScaleTransition(
                  scale: _heartAnimation,
                  child: Image.asset('assets/heart.png', width: 40),
                ),
              ),

            Positioned(
              left: knightPos * screenWidth,
              bottom: 100,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scale(lookingRight ? 1.0 : -1.0, 1.0),
                child: Image.asset('assets/knight.png', width: 60),
              ),
            ),

            Positioned(
              bottom: 20,
              left: 20,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 40),
                    onPressed: () => moveKnight(false),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward, size: 40),
                    onPressed: () => moveKnight(true),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Image.asset('assets/sword.png', width: 30),
                    onPressed: attackEnemy,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
