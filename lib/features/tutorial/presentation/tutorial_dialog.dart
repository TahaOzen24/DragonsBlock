import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/audio/procedural_audio.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../../core/theme/game_theme.dart';

class TutorialDialog extends StatefulWidget {
  const TutorialDialog({super.key});

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> slides = [
      {
        'icon': '🧩',
        'title': AppStrings.tutorialSlide1Title,
        'desc': AppStrings.tutorialSlide1Desc,
        'badge': AppStrings.tutorialSlide1Badge,
        'color': GameTheme.neonCyan,
      },
      {
        'icon': '🔥',
        'title': AppStrings.tutorialSlide2Title,
        'desc': AppStrings.tutorialSlide2Desc,
        'badge': AppStrings.tutorialSlide2Badge,
        'color': GameTheme.fireOrange,
      },
      {
        'icon': '⚡',
        'title': AppStrings.tutorialSlide3Title,
        'desc': AppStrings.tutorialSlide3Desc,
        'badge': AppStrings.tutorialSlide3Badge,
        'color': GameTheme.goldAccent,
      },
      {
        'icon': '🐉',
        'title': AppStrings.tutorialSlide4Title,
        'desc': AppStrings.tutorialSlide4Desc,
        'badge': AppStrings.tutorialSlide4Badge,
        'color': GameTheme.voidPurple,
      },
      {
        'icon': '👑',
        'title': AppStrings.tutorialSlide5Title,
        'desc': AppStrings.tutorialSlide5Desc,
        'badge': AppStrings.tutorialSlide5Badge,
        'color': GameTheme.goldAccent,
      },
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GameTheme.bgDark.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: slides[_currentPage]['color'] as Color, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: (slides[_currentPage]['color'] as Color).withValues(alpha: 0.35),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Close
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Page View
            SizedBox(
              height: 280,
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (idx) {
                  ProceduralAudio.instance.playTabSwitch();
                  setState(() {
                    _currentPage = idx;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  final color = slide['color'] as Color;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: GameTheme.bgDarkest,
                          border: Border.all(color: color, width: 2),
                          boxShadow: [
                            BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 18),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          slide['icon'] as String,
                          style: const TextStyle(fontSize: 34),
                        ),
                      ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 12),

                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: color.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          slide['badge'] as String,
                          style: TextStyle(
                            color: color,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Title
                      Text(
                        slide['title'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Desc
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          slide['desc'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: GameTheme.textMuted,
                            fontSize: 11.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Indicator Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (idx) {
                final isSelected = idx == _currentPage;
                final color = slides[_currentPage]['color'] as Color;
                return Container(
                  width: isSelected ? 18 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? color : GameTheme.gridBorder,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Navigation Button
            ElevatedButton(
              onPressed: () {
                if (_currentPage < slides.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  ProceduralAudio.instance.playButtonClick();
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: slides[_currentPage]['color'] as Color,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 6,
              ),
              child: Text(
                _currentPage < slides.length - 1
                    ? AppStrings.next
                    : AppStrings.letsPlay,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
