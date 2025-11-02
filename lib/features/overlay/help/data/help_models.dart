import 'package:flutter/material.dart';

class HelpLargeItem {
  final IconData icon;
  final String label;
  final List<Color> gradient;

  const HelpLargeItem(this.icon, this.label, this.gradient);
}

class HelpSmallItem {
  final IconData icon;
  final String label;
  final Color color;

  const HelpSmallItem(this.icon, this.label, this.color);
}

class HelpQuestionItem {
  final String question;
  final String answer;

  const HelpQuestionItem(this.question, this.answer);
}