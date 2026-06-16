import 'package:kasir_offline/data/models/product.dart';
import 'package:kasir_offline/data/models/transaction.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static String productTable = 'products';
  static String trxTable = 'transactions';

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kasir.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT,
        price INTEGER
      );
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total INTEGER NOT NULL,
        date TEXT NOT NULL
      );
    ''');
  }

  // CREATE
  Future<int> insertProduct(Product product) async {
    final db = await instance.database;
    return await db.insert(productTable, product.toJson());
  }

  //READ
  Future<List<Product>> getProducts() async {
    final db = await instance.database;
    final result = await db.query(productTable, orderBy: 'id DESC');
    return result.map((e) => Product.fromJson(e)).toList();
  }

  // UPDATE
  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    return db.update(
      productTable,
      product.toJson(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // DELETE
  Future<int> deleteProduct(String id) async {
    final db = await instance.database;
    return db.delete(productTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertTransaction(SaleTransaction trx) async {
    final db = await instance.database;
    return await db.insert(trxTable, trx.toMap());
  }

  // LAPORAN HARIAN
  Future<Map<String, dynamic>> getDailyReport(String date) async {
    final db = await instance.database;

    final result = await db.rawQuery(
      '''
    SELECT
      COUNT(id) as total_transaksi,
      COALESCE(SUM(total), 0) as total_omzet
    FROM transactions
    WHERE date LIKE ?
  ''',
      ['$date%'],
    );

    return {
      'total_transaksi': result.first['total_transaksi'],
      'total_omzet': result.first['total_omzet'],
    };
  }
}
