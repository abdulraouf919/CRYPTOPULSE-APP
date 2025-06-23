import 'package:cryptopulse/models/candle_data_model.dart';
import 'package:cryptopulse/models/cryptocurrency_model.dart';
import 'package:cryptopulse/models/portfolio_item_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cryptopulse.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Check if the image column already exists before adding it
      try {
        await db.execute("ALTER TABLE cryptocurrencies ADD COLUMN image TEXT");
      } catch (e) {
        // Column already exists, ignore the error
        print('Image column already exists, skipping...');
      }
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const textUniqueType = 'TEXT NOT NULL UNIQUE';

    await db.execute('''
CREATE TABLE users ( 
  id $idType, 
  email $textUniqueType,
  password_hash $textType,
  created_at TEXT NOT NULL
  )
''');

    await db.execute('''
CREATE TABLE cryptocurrencies (
  id $textType,
  symbol $textType,
  name $textType,
  image $textType,
  PRIMARY KEY (id)
)
''');

    await db.execute('''
CREATE TABLE portfolio (
  user_id $integerType,
  cryptocurrency_id $textType,
  quantity $realType,
  FOREIGN KEY (user_id) REFERENCES users (id),
  FOREIGN KEY (cryptocurrency_id) REFERENCES cryptocurrencies (id),
  PRIMARY KEY (user_id, cryptocurrency_id)
)
''');

    await db.execute('''
CREATE TABLE price_history (
  cryptocurrency_id TEXT NOT NULL,
  date INTEGER NOT NULL,
  open REAL NOT NULL,
  high REAL NOT NULL,
  low REAL NOT NULL,
  close REAL NOT NULL,
  FOREIGN KEY (cryptocurrency_id) REFERENCES cryptocurrencies (id),
  PRIMARY KEY (cryptocurrency_id, date)
)
''');

    // Insert a default user for testing
    await db.execute('''
    INSERT INTO users (email, password_hash, created_at) VALUES (?, ?, ?)
    ''', ['test@test.com', 'password', DateTime.now().toIso8601String()]);
  }

  Future<void> addOrUpdatePortfolioItem(int userId, Cryptocurrency crypto, double quantity) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      // First, ensure the cryptocurrency exists in the cryptocurrencies table.
      await txn.rawInsert('''
        INSERT OR IGNORE INTO cryptocurrencies (id, symbol, name, image) VALUES (?, ?, ?, ?)
      ''', [crypto.id, crypto.symbol, crypto.name, crypto.image]);

      // Now, add or update the portfolio item.
      final existing = await txn.query(
        'portfolio',
        where: 'user_id = ? AND cryptocurrency_id = ?',
        whereArgs: [userId, crypto.id],
      );

      if (existing.isNotEmpty) {
        // Update existing quantity
        double newQuantity = (existing.first['quantity'] as num) + quantity;
        if (newQuantity <= 0) {
          await txn.delete(
            'portfolio',
            where: 'user_id = ? AND cryptocurrency_id = ?',
            whereArgs: [userId, crypto.id],
          );
        } else {
          await txn.update(
            'portfolio',
            {'quantity': newQuantity},
            where: 'user_id = ? AND cryptocurrency_id = ?',
            whereArgs: [userId, crypto.id],
          );
        }
      } else {
        // Insert new item
        if (quantity > 0) {
          await txn.insert('portfolio', {
            'user_id': userId,
            'cryptocurrency_id': crypto.id,
            'quantity': quantity,
          });
        }
      }
    });
  }

  Future<List<PortfolioItem>> getPortfolio(int userId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT
        p.quantity,
        c.id,
        c.symbol,
        c.name,
        c.image
      FROM portfolio p
      JOIN cryptocurrencies c ON p.cryptocurrency_id = c.id
      WHERE p.user_id = ?
    ''', [userId]);

    return result.map((json) => PortfolioItem(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      imageUrl: json['image'] as String? ?? '',
    )).toList();
  }

  Future<void> cacheChartData(String cryptoId, List<CandleData> chartData) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // Clear old data for this crypto
      await txn.delete('price_history', where: 'cryptocurrency_id = ?', whereArgs: [cryptoId]);
      // Insert new data
      for (final data in chartData) {
        await txn.insert('price_history', {
          'cryptocurrency_id': cryptoId,
          'date': data.date.millisecondsSinceEpoch,
          'open': data.open,
          'high': data.high,
          'low': data.low,
          'close': data.close,
        });
      }
    });
  }

  Future<List<CandleData>> getChartDataFromCache(String cryptoId) async {
    final db = await instance.database;
    final result = await db.query(
      'price_history',
      where: 'cryptocurrency_id = ?',
      whereArgs: [cryptoId],
      orderBy: 'date ASC',
    );

    if (result.isNotEmpty) {
      return result.map((json) => CandleData(
        date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
        open: json['open'] as double,
        high: json['high'] as double,
        low: json['low'] as double,
        close: json['close'] as double,
      )).toList();
    }
    return [];
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
} 