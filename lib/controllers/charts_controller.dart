import 'package:flutter/material.dart';
import 'package:cryptopulse/models/portfolio_item_model.dart';
import 'package:cryptopulse/models/candle_data_model.dart';
import 'package:cryptopulse/services/api_service.dart';
import 'package:cryptopulse/utils/database_helper.dart';

class ChartsController extends ChangeNotifier {
  final int userId;
  final ApiService apiService;
  final DatabaseHelper dbHelper;

  List<PortfolioItem> _portfolio = [];
  Map<String, List<CandleData>> _chartData = {};
  bool _loading = false;
  String? _error;

  List<PortfolioItem> get portfolio => _portfolio;
  Map<String, List<CandleData>> get chartData => _chartData;
  bool get loading => _loading;
  String? get error => _error;

  ChartsController({
    required this.userId,
    ApiService? apiService,
    DatabaseHelper? dbHelper,
  })  : apiService = apiService ?? ApiService(),
        dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<void> fetchPortfolioAndCharts() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final items = await dbHelper.getPortfolio(userId);
      _portfolio = items;
      _chartData = {};
      for (final item in items) {
        try {
          final apiData = await apiService.fetchCandleChartData(item.id);
          await dbHelper.cacheChartData(item.id, apiData);
          _chartData[item.id] = apiData;
        } catch (e) {
          final cachedData = await dbHelper.getChartDataFromCache(item.id);
          if (cachedData.isNotEmpty) {
            _chartData[item.id] = cachedData;
          } else {
            _chartData[item.id] = [];
          }
        }
      }
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }
} 