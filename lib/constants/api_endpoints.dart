class ApiEndpoints {
  // Base URLs
  static const String coinGeckoBaseUrl = 'https://api.coingecko.com/api/v3';
  static const String cryptoCompareBaseUrl = 'https://min-api.cryptocompare.com/data/v2';
  
  // CoinGecko Endpoints
  static const String topCryptocurrencies = '/coins/markets';
  static const String coinDetails = '/coins';
  static const String ohlcData = '/coins/{id}/ohlc';
  
  // CryptoCompare Endpoints
  static const String cryptoNews = '/news/?lang=EN';
  
  // Query Parameters
  static const String vsCurrency = 'usd';
  static const String order = 'market_cap_desc';
  static const String perPage = '100';
  static const String sparkline = 'false';
  static const String priceChangePercentage = '24h';
} 