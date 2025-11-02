import 'package:flutter/material.dart';
import 'package:flutter_ar/core/constants/app_constants.dart';
import 'chart_widgets.dart';
import 'controls_widget.dart';
import 'dart:math';

class CategoryView extends StatefulWidget {
  final String category;
  final Map<String, List<MapEntry<DateTime, double>>>? data;

  const CategoryView({required this.category, this.data, super.key});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> with AutomaticKeepAliveClientMixin<CategoryView> {
  late List<DateTime> _dates;
  late List<double> _values;
  int _selectedMode = 0; // 0=line, 1=bar, 2=pie, 3=table
  bool _showOnlyExceed = false;
  late double threshold;

  @override
  void initState() {
    super.initState();
    threshold = AppConstants.thresholds[widget.category] ?? double.infinity;
    _loadData();
  }

  @override
  void didUpdateWidget(covariant CategoryView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data || widget.category != oldWidget.category) {
      threshold = AppConstants.thresholds[widget.category] ?? double.infinity;
      _loadData();
    }
  }

  void _loadData() {
    if (widget.data != null && widget.data!.containsKey(widget.category) && widget.data![widget.category]!.isNotEmpty) {
      final entries = widget.data![widget.category]!;
      _dates = entries.map((e) => e.key).toList();
      _values = entries.map((e) => e.value).toList();
    } else {
      _generateDummyData();
    }
  }

  void _generateDummyData() {
    final now = DateTime.now();
    _dates = List.generate(365, (i) => now.add(Duration(days: i)));
    final rnd = Random(now.millisecondsSinceEpoch);
    final base = AppConstants.baseValues[widget.category] ?? 1.0;
    _values = List.generate(365, (i) => base + rnd.nextDouble() * base * 1.6 + sin(i / 10) * base / 3);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final currentDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ControlsWidget(
            selectedMode: _selectedMode,
            showOnlyExceed: _showOnlyExceed,
            onModeChanged: (mode) => setState(() => _selectedMode = mode),
            onShowExceedChanged: _selectedMode == 3 ? (val) => setState(() => _showOnlyExceed = val) : null,
          ),
          const SizedBox(height: 8),
          ChartWidgets(
            mode: _selectedMode,
            dates: _dates,
            values: _values,
            threshold: threshold,
            showOnlyExceed: _showOnlyExceed,
            category: widget.category,
            isDarkTheme: currentDarkTheme,
          ),
        ],
      ),
    );
  }
}