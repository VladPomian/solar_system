import 'package:flutter/material.dart';
import 'package:flutter_ar/core/constants/app_constants.dart';
import 'package:flutter_ar/core/services/amqp_service.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/prediction/data/models/prediction_data.dart';
import 'package:flutter_ar/features/prediction/data/repositories/prediction_repository.dart';
import 'package:flutter_ar/features/prediction/domain/prediction_service.dart';
import 'widgets/category_view.dart';

class PredictionPage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkTheme;
  final Function(FontSizeOption) onFontSizeChanged;
  final FontSizeOption fontSize;

  const PredictionPage({
    super.key,
    required this.onThemeChanged,
    required this.isDarkTheme,
    required this.onFontSizeChanged,
    required this.fontSize,
  });

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  late final PredictionService _predictionService;
  String _connectionStatus = 'Готов к работе';
  DateTime? _lastResponseDateTime;
  PredictionData? _data;
  final ExpansionTileController _cmeController = ExpansionTileController();
  final ExpansionTileController _flrController = ExpansionTileController();
  final ExpansionTileController _gstController = ExpansionTileController();

  @override
  void initState() {
    super.initState();
    _predictionService = PredictionService(
      amqpService: AmqpService(),
      repository: PredictionRepository(),
    );
    _initialize();
  }

  Future<void> _initialize() async {
    final data = await _predictionService.initialize(
      context,
      (status) {
        if (mounted) {
          setState(() => _connectionStatus = status);
        }
      },
      (date) {
        if (mounted) {
          setState(() => _lastResponseDateTime = date);
        }
      },
    );
    if (mounted) {
      setState(() => _data = data);
    }
  }

  Future<void> _refreshData() async {
    try {
      if (mounted) {
        setState(() => _connectionStatus = 'Отправка запроса...');
      }
      await _predictionService.sendRequest();
      final data = await _predictionService.repository.loadCachedData();
      if (mounted) {
        setState(() => _data = data);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _connectionStatus = 'Оффлайн-режим: использование кеша');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Нет соединения: $e. Используются кешированные данные.',
              style: TextStyle(
                fontSize: AppTheme.getBodyFontSize(),
                color: AppTheme.getTextColor(context),
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  void didUpdateWidget(PredictionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkTheme != widget.isDarkTheme || oldWidget.fontSize != widget.fontSize) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _predictionService.clearOnResponseCallback();
    _predictionService.amqpService.dispose();
    super.dispose();
  }

  Widget _buildCategoryTile(String category, ExpansionTileController controller) {
    return ExpansionTile(
      controller: controller,
      key: ValueKey(category),
      title: Text(
        AppConstants.categoryFullNames[category] ?? category,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.getTextColor(context),
          fontSize: AppTheme.getSubtitleFontSize(),
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          AppConstants.categoryExplanations[category] ?? '',
          style: TextStyle(
            color: AppTheme.getSecondaryTextColor(context),
            fontSize: AppTheme.getBodyFontSize(),
          ),
        ),
      ),
      initiallyExpanded: false,
      onExpansionChanged: (expanded) {
        if (expanded) {
          if (category != 'CME' && _cmeController.isExpanded) {
            _cmeController.collapse();
          }
          if (category != 'FLR' && _flrController.isExpanded) {
            _flrController.collapse();
          }
          if (category != 'GST' && _gstController.isExpanded) {
            _gstController.collapse();
          }
        }
        setState(() {});
      },
      children: [
        CategoryView(
          category: category,
          data: _data!.toMap(),
          key: ValueKey(category),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDateTime = _lastResponseDateTime != null
        ? '${_lastResponseDateTime!.toLocal().toString().split('.')[0]}'
        : '—';

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getBackgroundColor(context),
        title: Text(
          'Предсказания',
          style: TextStyle(
            fontSize: AppTheme.getHeadlineFontSize(),
            fontWeight: FontWeight.bold,
            color: AppTheme.getPrimaryColor(context),
          ),
        ),
        iconTheme: IconThemeData(color: AppTheme.getPrimaryColor(context)),
      ),
      body: _data == null
          ? Center(child: CircularProgressIndicator(color: AppTheme.getTextColor(context)))
          : Column(
              children: [
                if (!_cmeController.isExpanded &&
                    !_flrController.isExpanded &&
                    !_gstController.isExpanded)
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppTheme.getPrimaryColor(context),
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.getPrimaryColor(context).withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: AppTheme.getTextColor(context),
                          fontWeight: FontWeight.bold,
                          fontSize: AppTheme.getBodyFontSize(),
                          height: 1.5,
                        ),
                        children: const [
                          TextSpan(
                            text:
                                'Изучите предсказания солнечных и геомагнитных явлений, которые влияют на спутники, связь и энергосистемы. Разверните разделы ниже, чтобы просмотреть графики и таблицы с данными.',
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildCategoryTile('CME', _cmeController),
                      _buildCategoryTile('FLR', _flrController),
                      _buildCategoryTile('GST', _gstController),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.getBackgroundColor(context),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.getTextColor(context).withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Последний ответ:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getPrimaryColor(context),
                              fontSize: AppTheme.getBodyFontSize(),
                            ),
                          ),
                          Text(
                            formattedDateTime,
                            style: TextStyle(
                              color: AppTheme.getPrimaryColor(context),
                              fontSize: AppTheme.getCaptionFontSize(),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getShortStatus(),
                            style: TextStyle(
                              color: AppTheme.getPrimaryColor(context),
                              fontSize: AppTheme.getCaptionFontSize(),
                            ),
                          ),
                          Text(
                            _getDetailedStatus(),
                            style: TextStyle(
                              color: AppTheme.getPrimaryColor(context),
                              fontSize: AppTheme.getCaptionFontSize(),
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        child: ElevatedButton.icon(
                          onPressed: _refreshData,
                          icon: Icon(Icons.refresh, size: 20, color: AppTheme.getTextColor(context)),
                          label: Text(
                            'Обновить данные',
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: AppTheme.getBodyFontSize(),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.getPrimaryColor(context),
                            foregroundColor: AppTheme.getTextColor(context),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            textStyle: TextStyle(fontSize: AppTheme.getBodyFontSize()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _getShortStatus() {
    if (_connectionStatus.contains('Оффлайн')) {
      return 'Оффлайн';
    } else if (_connectionStatus.contains('Отправка')) {
      return 'Запрос';
    } else if (_connectionStatus.contains('Подключено')) {
      return 'Подключено';
    } else {
      return 'Готов';
    }
  }

  String _getDetailedStatus() {
    if (_connectionStatus.contains('Оффлайн')) {
      return 'Использование кеша';
    } else if (_connectionStatus.contains('Отправка')) {
      return 'Отправка запроса...';
    } else if (_connectionStatus.contains('Подключено')) {
      return 'AMQP подключён';
    } else {
      return _connectionStatus;
    }
  }
}