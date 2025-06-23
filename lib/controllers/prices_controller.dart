import 'package:flutter/material.dart';
import 'package:cryptopulse/models/cryptocurrency_model.dart';
import 'package:cryptopulse/services/api_service.dart';

class PricesController extends ChangeNotifier {
  final ApiService apiService;

  List<Cryptocurrency> _cryptos = [];
  bool _loading = false;
  String? _error;

  List<Cryptocurrency> get cryptos => _cryptos;
  bool get loading => _loading;
  String? get error => _error;

  PricesController({ApiService? apiService})
      : apiService = apiService ?? ApiService();

  Future<void> fetchCryptos() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _cryptos = await apiService.fetchTopCryptocurrencies();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }
} 