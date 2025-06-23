import 'package:flutter/material.dart';
import 'package:cryptopulse/models/portfolio_item_model.dart';
import 'package:cryptopulse/models/cryptocurrency_model.dart';
import 'package:cryptopulse/services/api_service.dart';
import 'package:cryptopulse/utils/database_helper.dart';

class WalletController extends ChangeNotifier {
  final int userId;
  final DatabaseHelper dbHelper;
  final ApiService apiService;

  List<PortfolioItem> _portfolio = [];
  bool _loading = false;
  String? _error;

  List<PortfolioItem> get portfolio => _portfolio;
  bool get loading => _loading;
  String? get error => _error;

  WalletController({
    required this.userId,
    DatabaseHelper? dbHelper,
    ApiService? apiService,
  })  : dbHelper = dbHelper ?? DatabaseHelper.instance,
        apiService = apiService ?? ApiService();

  Future<void> loadPortfolio() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final items = await dbHelper.getPortfolio(userId);
      if (items.isEmpty) {
        _portfolio = [];
      } else {
        final ids = items.map((item) => item.id).toList();
        try {
          final priceData = await apiService.fetchPricesForIds(ids);
          for (var item in items) {
            final data = priceData[item.id];
            if (data != null) {
              item.currentPrice = data.currentPrice;
              item.imageUrl = data.image;
            }
          }
        } catch (e) {
          // If API fails, just use local data (no updated prices/images)
        }
        _portfolio = items;
      }
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> updateQuantity(PortfolioItem item, double newQuantity) async {
    try {
      await dbHelper.addOrUpdatePortfolioItem(
        userId,
        Cryptocurrency(
          id: item.id,
          name: item.name,
          symbol: item.symbol,
          currentPrice: item.currentPrice,
          priceChange24h: 0,
          priceChangePercentage24h: 0,
          image: item.imageUrl,
        ),
        newQuantity - item.quantity,
      );
      await loadPortfolio();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
} 