import 'package:flutter/material.dart';

class Section {
  final IconData icon;
  final String title;
  final String description;
  final String descriptionSecond;
  final Widget destination;

  Section({
    required this.icon,
    required this.title,
    required this.description,
    required this.descriptionSecond,
    required this.destination,
  });
}