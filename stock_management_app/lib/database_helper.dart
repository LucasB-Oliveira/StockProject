import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/product.dart';
import 'models/sale.dart'; // Importe o modelo Sale

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('products.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE products (
        name TEXT PRIMARY KEY,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        sold INTEGER NOT NULL
      )
    ''');

    await db.execute(''' 
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productName TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        total REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertProduct(Product product) async {
    final db = await instance.database;
    await db.insert('products', product.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Product>> getProducts() async {
    final db = await instance.database;
    final result = await db.query('products');
    return result.map((map) => Product.fromMap(map)).toList();
  }

  Future<void> updateProduct(Product product) async {
    final db = await instance.database;
    await db.update('products', product.toMap(), where: 'name = ?', whereArgs: [product.name]);
  }

  Future<void> deleteProduct(String name) async {
    final db = await instance.database;
    await db.delete('products', where: 'name = ?', whereArgs: [name]);
  }

  // Método para inserir uma venda
  Future<void> insertSale(Sale sale) async {
    final db = await instance.database;
    await db.insert('sales', sale.toMap());
  }

  // Método para recuperar o histórico de vendas
  Future<List<Sale>> getSalesHistory() async {
    final db = await instance.database;
    final result = await db.query('sales');
    return result.map((map) => Sale.fromMap(map)).toList();
  }

  // Método para limpar o histórico de vendas
  Future<void> clearSalesHistory() async {
    final db = await instance.database;
    await db.delete('sales');
  }
}
