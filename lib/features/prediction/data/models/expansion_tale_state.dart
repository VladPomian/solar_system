import 'package:flutter/material.dart';

class ExpansionTileState extends State<ExpansionTile> {
  bool _isExpanded = false;

  bool get isExpanded => _isExpanded;

  void expand() {
    setState(() {
      _isExpanded = true;
    });
  }

  void collapse() {
    setState(() {
      _isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) => widget;
}