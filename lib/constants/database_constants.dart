class DatabaseConstants {
  // Database
  static const String databaseName = 'cryptopulse.db';
  static const int databaseVersion = 2;
  
  // Tables
  static const String usersTable = 'users';
  static const String cryptocurrenciesTable = 'cryptocurrencies';
  static const String portfolioTable = 'portfolio';
  static const String priceHistoryTable = 'price_history';
  
  // Columns - Users
  static const String userId = 'id';
  static const String userEmail = 'email';
  static const String userPasswordHash = 'password_hash';
  static const String userCreatedAt = 'created_at';
  
  // Columns - Cryptocurrencies
  static const String cryptoId = 'id';
  static const String cryptoSymbol = 'symbol';
  static const String cryptoName = 'name';
  static const String cryptoImage = 'image';
  
  // Columns - Portfolio
  static const String portfolioUserId = 'user_id';
  static const String portfolioCryptoId = 'cryptocurrency_id';
  static const String portfolioQuantity = 'quantity';
  
  // Columns - Price History
  static const String priceHistoryCryptoId = 'cryptocurrency_id';
  static const String priceHistoryDate = 'date';
  static const String priceHistoryOpen = 'open';
  static const String priceHistoryHigh = 'high';
  static const String priceHistoryLow = 'low';
  static const String priceHistoryClose = 'close';
  
  // Data Types
  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String textType = 'TEXT NOT NULL';
  static const String realType = 'REAL NOT NULL';
  static const String integerType = 'INTEGER NOT NULL';
  static const String textUniqueType = 'TEXT NOT NULL UNIQUE';
} 