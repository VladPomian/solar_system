import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ar/core/constants/app_constants.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';

class ChartWidgets extends StatelessWidget {
  final int mode;
  final List<DateTime> dates;
  final List<double> values;
  final double threshold;
  final bool showOnlyExceed;
  final String category;
  final bool isDarkTheme;

  const ChartWidgets({
    super.key,
    required this.mode,
    required this.dates,
    required this.values,
    required this.threshold,
    required this.showOnlyExceed,
    required this.category,
    required this.isDarkTheme,
  });

  Color get _textColor => isDarkTheme ? Colors.white : Colors.black;
  Color get _secondaryTextColor => isDarkTheme ? Colors.white70 : Colors.black54;
  Color get _primaryColor => isDarkTheme ? Colors.amber : Colors.cyan;

  Widget _buildLineChart() {
    final spots = List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i]));
    final minY = 0.0;
    final maxY = values.reduce(max) * 1.1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: (dates.length / 6).ceil().toDouble(),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= dates.length) return const Text('');
                        final date = dates[idx];
                        return Transform.rotate(
                          angle: pi / 4,
                          child: Text(
                            '${date.month}/${date.day}',
                            style: TextStyle(
                              fontSize: AppTheme.getCaptionFontSize(),
                              color: _textColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: (maxY - minY) / 5,
                      getTitlesWidget: (value, meta) {
                        final formattedValue = value >= 1000
                            ? '${(value / 1000).toStringAsFixed(1)}K'
                            : value.toStringAsFixed(1);
                        return Text(
                          formattedValue,
                          style: TextStyle(
                            fontSize: AppTheme.getCaptionFontSize(),
                            color: _textColor,
                          ),
                          textAlign: TextAlign.right,
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: _secondaryTextColor.withOpacity(0.3),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: _secondaryTextColor.withOpacity(0.3),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: _secondaryTextColor),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: _primaryColor.withOpacity(0.3),
                    ),
                    color: _primaryColor,
                    barWidth: 2,
                  ),
                  LineChartBarData(
                    spots: [
                      FlSpot(0, threshold),
                      FlSpot(spots.length.toDouble() - 1, threshold)
                    ],
                    isCurved: false,
                    color: Colors.red,
                    dotData: FlDotData(show: false),
                    dashArray: [5, 5],
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final idx = spot.x.toInt();
                        final date = dates[idx];
                        final val = spot.y;
                        final color = val >= threshold ? Colors.red : Colors.green;
                        return LineTooltipItem(
                          '${date.toIso8601String().split('T').first}: ${val.toStringAsFixed(2)}',
                          TextStyle(
                            color: color,
                            fontSize: AppTheme.getCaptionFontSize(),
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'График показывает значения ${AppConstants.categoryFullNames[category]} по дням. '
            'Синяя линия — данные, красная пунктирная линия — порог (${threshold.toStringAsFixed(1)}). '
            'Нажмите на график, чтобы увидеть дату и значение в точке.',
            style: TextStyle(
              color: _secondaryTextColor,
              fontSize: AppTheme.getBodyFontSize(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    const daysPerMonth = 30;
    final numMonths = (values.length / daysPerMonth).ceil();
    final monthlyMax = List.generate(numMonths, (m) {
      final start = m * daysPerMonth;
      final end = min(start + daysPerMonth, values.length);
      final monthValues = values.sublist(start, end);
      return monthValues.isNotEmpty ? monthValues.reduce(max) : 0.0;
    });
    final monthlyDates = List.generate(numMonths, (m) {
      final startIdx = m * daysPerMonth;
      return startIdx < dates.length ? dates[startIdx] : DateTime.now();
    });

    final barGroups = List.generate(numMonths, (i) => BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: monthlyMax[i],
              color: monthlyMax[i] >= threshold ? Colors.red : Colors.green,
              width: 16,
            ),
          ],
        ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= monthlyDates.length) return const Text('');
                        final date = monthlyDates[idx];
                        return Transform.rotate(
                          angle: pi / 4,
                          child: Text(
                            '${date.month}/${date.year % 100}',
                            style: TextStyle(
                              fontSize: AppTheme.getCaptionFontSize(),
                              color: _textColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: _secondaryTextColor),
                ),
                groupsSpace: 4,
                barGroups: barGroups,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final idx = group.x;
                      final date = monthlyDates[idx];
                      final val = rod.toY;
                      final color = val >= threshold ? Colors.red : Colors.green;
                      return BarTooltipItem(
                        'Месяц ${date.month}: max ${val.toStringAsFixed(2)}',
                        TextStyle(
                          color: color,
                          fontSize: AppTheme.getCaptionFontSize(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'График показывает максимальные значения ${AppConstants.categoryFullNames[category]} за каждый месяц. '
            'Зеленые столбцы — значения ниже порога (${threshold.toStringAsFixed(1)}), красные — выше. '
            'Нажмите на столбец, чтобы увидеть максимальное значение за месяц.',
            style: TextStyle(
              color: _secondaryTextColor,
              fontSize: AppTheme.getBodyFontSize(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    final exceed = values.where((v) => v >= threshold).length.toDouble();
    final normal = values.length - exceed;
    final total = values.length.toDouble();
    if (exceed == 0 && normal == 0) {
      return Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Нет данных',
          style: TextStyle(
            fontSize: AppTheme.getBodyFontSize(),
            color: _textColor,
          ),
        ),
      );
    }
    if (exceed == 0) {
      return Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Нет превышений',
          style: TextStyle(
            fontSize: AppTheme.getBodyFontSize(),
            color: Colors.green,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 260,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: exceed,
                    title: 'Превыш.\n${exceed.toInt()}\n${((exceed / total) * 100).toStringAsFixed(1)}%',
                    color: Colors.red,
                    radius: 80,
                    titleStyle: TextStyle(
                      color: _textColor,
                      fontSize: AppTheme.getCaptionFontSize(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: normal,
                    title: 'Норма\n${normal.toInt()}\n${((normal / total) * 100).toStringAsFixed(1)}%',
                    color: Colors.green,
                    radius: 80,
                    titleStyle: TextStyle(
                      color: _textColor,
                      fontSize: AppTheme.getCaptionFontSize(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                centerSpaceRadius: 40,
                sectionsSpace: 2,
                pieTouchData: PieTouchData(),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16.0,
            runSpacing: 8.0,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Норма: Дни со значениями ниже ${threshold.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: AppTheme.getCaptionFontSize(),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Превышение: Дни со значениями выше ${threshold.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: AppTheme.getCaptionFontSize(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTable() {
    final rows = List.generate(values.length, (i) => MapEntry(dates[i], values[i]));
    final filtered = showOnlyExceed ? rows.where((e) => e.value >= threshold).toList() : rows;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                _primaryColor.withOpacity(0.1),
              ),
              dataRowColor: MaterialStateProperty.resolveWith((states) => Colors.transparent),
              columns: [
                DataColumn(
                  label: Text(
                    'Дата',
                    style: TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: AppTheme.getBodyFontSize(),
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Значение',
                    style: TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: AppTheme.getBodyFontSize(),
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Статус',
                    style: TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: AppTheme.getBodyFontSize(),
                    ),
                  ),
                ),
              ],
              rows: filtered.map((e) => DataRow(
                    color: MaterialStateProperty.resolveWith((states) {
                      return e.value >= threshold
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1);
                    }),
                    cells: [
                      DataCell(
                        Text(
                          e.key.toIso8601String().split('T').first,
                          style: TextStyle(
                            color: _textColor,
                            fontSize: AppTheme.getCaptionFontSize(),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          e.value.toStringAsFixed(2),
                          style: TextStyle(
                            color: _textColor,
                            fontSize: AppTheme.getCaptionFontSize(),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          e.value >= threshold ? 'Превышение' : 'Норма',
                          style: TextStyle(
                            color: e.value >= threshold ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: AppTheme.getCaptionFontSize(),
                          ),
                        ),
                      ),
                    ],
                  )).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case 0:
        return _buildLineChart();
      case 1:
        return _buildBarChart();
      case 2:
        return _buildPieChart();
      case 3:
        return _buildTable();
      default:
        return _buildLineChart();
    }
  }
}