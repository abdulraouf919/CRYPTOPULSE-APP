import 'dart:convert';
import 'package:cryptopulse/models/candle_data_model.dart';
import 'package:cryptopulse/models/news_article_model.dart';
import 'package:http/http.dart' as http;
import '../models/cryptocurrency_model.dart';

class ApiService {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';

  Future<List<Cryptocurrency>> fetchTopCryptocurrencies() async {
    final url =
        '$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false';
    
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Cryptocurrency.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cryptocurrencies');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<Map<String, Cryptocurrency>> fetchPricesForIds(List<String> ids) async {
    if (ids.isEmpty) return {};
    
    final url = '$_baseUrl/coins/markets?vs_currency=usd&ids=${ids.join(',')}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Map<String, Cryptocurrency> cryptoMap = {};
        for (var item in data) {
          final crypto = Cryptocurrency.fromJson(item);
          cryptoMap[crypto.id] = crypto;
        }
        return cryptoMap;
      } else {
        throw Exception('Failed to load prices');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<List<CandleData>> fetchCandleChartData(String cryptoId) async {
    final url = '$_baseUrl/coins/$cryptoId/ohlc?vs_currency=usd&days=7';
    
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        return data.map((item) {
          return CandleData(
            date: DateTime.fromMillisecondsSinceEpoch(item[0]),
            open: (item[1] as num).toDouble(),
            high: (item[2] as num).toDouble(),
            low: (item[3] as num).toDouble(),
            close: (item[4] as num).toDouble(),
          );
        }).toList();

      } else {
        throw Exception('Failed to load chart data');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server for chart data: $e');
    }
  }

  Future<List<NewsArticle>> fetchCryptoNews() async {
    const newsUrl = 'https://min-api.cryptocompare.com/data/v2/news/?lang=EN';
    try {
      final response = await http.get(Uri.parse(newsUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List articles = data['Data'];
        // Limit to 5 articles to keep the UI clean
        return articles.take(5).map((item) => NewsArticle.fromJson(item)).toList();
      } else {
        print('Failed to load news: ${response.statusCode}');
        return []; // Return empty list on failure
      }
    } catch (e) {
      print('Error fetching news: $e');
      return []; // Return empty list on error
    }
  }

  Future<List<CandleData>> fetchCandleData(String cryptoId, {String days = '30'}) async {
    final url = '$_baseUrl/coins/$cryptoId/ohlc?vs_currency=usd&days=$days';
    
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        return data.map((item) {
          return CandleData(
            date: DateTime.fromMillisecondsSinceEpoch(item[0]),
            open: (item[1] as num).toDouble(),
            high: (item[2] as num).toDouble(),
            low: (item[3] as num).toDouble(),
            close: (item[4] as num).toDouble(),
          );
        }).toList();

      } else {
        throw Exception('Failed to load chart data');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server for chart data: $e');
    }
  }
} 