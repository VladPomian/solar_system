import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/animation_constants.dart';
import '../../../../core/constants/ui_constants.dart';
import '../models/sections_model.dart';
import '../widgets/sections_card.dart';
import '../animations/pulse_animation.dart';

class CardStack extends StatelessWidget {
  final List<Section> sections;
  final List<int> order;
  final PulseAnimation pulseAnimation;
  final VoidCallback onRotateUp;
  final VoidCallback onRotateDown;
  final bool isDarkTheme;

  const CardStack({
    super.key,
    required this.sections,
    required this.order,
    required this.pulseAnimation,
    required this.onRotateUp,
    required this.onRotateDown,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double cardBaseHeight = 200.h;
    final double activeCardHeight = cardBaseHeight * 1.5;
    final double inactiveCardHeight = cardBaseHeight;
    final double cardBaseWidth = 300.w;
    final double centerLeft = (ScreenUtil().screenWidth - cardBaseWidth) / 2;
    final double centerY = screenHeight / 2 - activeCardHeight / 2;

    final List<double> positionValues = [
      centerY - inactiveCardHeight * (1 - AnimationConstants.overlapFraction),
      centerY,
      centerY + activeCardHeight - inactiveCardHeight * AnimationConstants.overlapFraction,
    ];

    final List<double> heightValues = [
      inactiveCardHeight,
      activeCardHeight,
      inactiveCardHeight,
    ];

    final List<Map<String, dynamic>> cardData = [];
    for (int i = 0; i < 3; i++) {
      cardData.add({
        'sectionIndex': i,
        'positionIndex': order[i],
      });
    }
    cardData.sort((a, b) {
      final aIsCenter = a['positionIndex'] == 1 ? 1 : 0;
      final bIsCenter = b['positionIndex'] == 1 ? 1 : 0;
      return aIsCenter.compareTo(bIsCenter);
    });

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -200) {
            onRotateDown();
          } else if (details.primaryVelocity! > 200) {
            onRotateUp();
          }
        }
      },
      child: Stack(
        children: cardData.map((data) {
          final int sectionIndex = data['sectionIndex'];
          final int positionIndex = data['positionIndex'];
          return SectionCard(
            key: ValueKey(sections[sectionIndex].title),
            section: sections[sectionIndex],
            position: positionValues[positionIndex],
            left: centerLeft,
            height: heightValues[positionIndex],
            scale: UIConstants.scaleValues[positionIndex],
            blur: UIConstants.blurValues[positionIndex],
            opacity: UIConstants.opacityValues[positionIndex],
            isActive: positionIndex == 1,
            pulseAnimation: pulseAnimation,
            onTap: () {
              final bool isActive = UIConstants.scaleValues[positionIndex] == UIConstants.largeScale;
              if (isActive) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => sections[sectionIndex].destination),
                );
              } else {
                final double currentTop = positionValues[positionIndex];
                if (currentTop < positionValues[1]) {
                  onRotateUp();
                } else {
                  onRotateDown();
                }
              }
            },
            isDarkTheme: isDarkTheme,
          );
        }).toList(),
      ),
    );
  }
}