import 'package:flutter/material.dart';
import 'package:cryptopulse/models/portfolio_item_model.dart';
import 'package:cryptopulse/models/cryptocurrency_model.dart';
import 'package:cryptopulse/models/news_article_model.dart';
import 'package:cryptopulse/services/api_service.dart';
import 'package:cryptopulse/utils/database_helper.dart';

class HomeController extends ChangeNotifier {
  final int userId;
  final ApiService apiService;
  final DatabaseHelper dbHelper;

  PortfolioItem? _topHolding;
  List<Cryptocurrency> _topGainers = [];
  List<Cryptocurrency> _topLosers = [];
  List<NewsArticle> _news = [];
  bool _loading = false;
  String? _error;

  PortfolioItem? get topHolding => _topHolding;
  List<Cryptocurrency> get topGainers => _topGainers;
  List<Cryptocurrency> get topLosers => _topLosers;
  List<NewsArticle> get news => _news;
  bool get loading => _loading;
  String? get error => _error;

  HomeController({
    required this.userId,
    ApiService? apiService,
    DatabaseHelper? dbHelper,
  })  : apiService = apiService ?? ApiService(),
        dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<void> fetchDashboardData() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        apiService.fetchTopCryptocurrencies(),
        dbHelper.getPortfolio(userId),
        apiService.fetchCryptoNews(),
      ]);
      final allCryptos = results[0] as List<Cryptocurrency>;
      final portfolioItems = results[1] as List<PortfolioItem>;
      final newsArticles = results[2] as List<NewsArticle>;

      PortfolioItem? topHoldingWithData;
      if (portfolioItems.isNotEmpty) {
        final portfolioIds = portfolioItems.map((item) => item.id).toList();
        final prices = await apiService.fetchPricesForIds(portfolioIds);
        for (var item in portfolioItems) {
          final priceData = prices[item.id];
          if (priceData != null) {
            item.currentPrice = priceData.currentPrice;
            item.imageUrl = priceData.image;
          }
        }
        portfolioItems.sort((a, b) => b.totalValue.compareTo(a.totalValue));
        topHoldingWithData = portfolioItems.first;
      }
      allCryptos.sort((a, b) => (b.priceChangePercentage24h ?? 0.0).compareTo(a.priceChangePercentage24h ?? 0.0));
      _topHolding = topHoldingWithData;
      _topGainers = allCryptos.take(3).toList();
      _topLosers = allCryptos.reversed.take(3).toList();
      _news = newsArticles;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }
} 