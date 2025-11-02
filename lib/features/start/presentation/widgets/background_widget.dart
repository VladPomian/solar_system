import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  final bool isDarkTheme;

  const BackgroundWidget({super.key, required this.isDarkTheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            isDarkTheme 
              ? 'assets/background/back.jpg'
              : 'assets/background/neutron_star.png'
          ),
          fit: BoxFit.cover,
        ),
        color: isDarkTheme 
          ? Colors.black.withOpacity(0.3)
          : Colors.white.withOpacity(0.1),
      ),
    );
  }
}