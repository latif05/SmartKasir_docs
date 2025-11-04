import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDB {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'smartkasir_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onOpen: (db) async {
        await _createTables(db);
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        store_name TEXT,
        store_address TEXT,
        store_phone TEXT,
        store_email TEXT,
        account_name TEXT,
        account_email TEXT,
        receipt_format TEXT,
        default_min_stock INTEGER DEFAULT 0,
        enable_offline_mode INTEGER DEFAULT 0,
        enable_low_stock_notification INTEGER DEFAULT 1,
        enable_auto_sync INTEGER DEFAULT 1,
        updated_at TEXT
      );
    ''');
  }

  static Future<int> insertCategory(Map<String, dynamic> data) async {
    final d = await db;
    return await d.insert('categories', data);
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final d = await db;
    return await d.query('categories', orderBy: 'id DESC');
  }

  static Map<String, dynamic> _defaultSettingsRow() {
    final now = DateTime.now().toIso8601String();
    return {
      'store_name': 'Toko SmartKasir',
      'store_address': 'Alamat toko belum diatur',
      'store_phone': '08xxxxxxxxxx',
      'store_email': 'admin@smartkasir.com',
      'account_name': 'Admin SmartKasir',
      'account_email': 'admin@smartkasir.com',
      'receipt_format': 'Struk dengan Header dan Footer',
      'default_min_stock': 10,
      'enable_offline_mode': 0,
      'enable_low_stock_notification': 1,
      'enable_auto_sync': 1,
      'updated_at': now,
    };
  }

  static Future<Map<String, dynamic>> getSettings() async {
    final d = await db;
    final rows = await d.query('settings', orderBy: 'id DESC', limit: 1);
    if (rows.isNotEmpty) return rows.first;

    final defaults = _defaultSettingsRow();
    final id = await d.insert('settings', defaults);
    return {...defaults, 'id': id};
  }

  static Future<Map<String, dynamic>> saveSettings(
      Map<String, dynamic> data) async {
    final d = await db;
    final now = DateTime.now().toIso8601String();
    final payload = Map<String, dynamic>.from(data)..['updated_at'] = now;

    if (payload['id'] != null) {
      final id = payload['id'] as int;
      payload.remove('id');
      await d.update('settings', payload, where: 'id = ?', whereArgs: [id]);
      return {...payload, 'id': id};
    } else {
      final id = await d.insert('settings', payload);
      return {...payload, 'id': id};
    }
  }

  static Future<void> resetDatabase() async {
    final d = await db;
    final tables = [
      'categories',
      'products',
      'transactions',
      'transaction_items',
    ];
    for (final table in tables) {
      try {
        await d.delete(table);
      } catch (_) {
        // table might not exist yet; ignore silently
      }
    }
  }

  static Future<void> clearAllData() async {
    final d = await db;
    final tables = [
      'categories',
      'products',
      'transactions',
      'transaction_items',
      'settings',
    ];
    for (final table in tables) {
      try {
        await d.delete(table);
      } catch (_) {
        // table might not exist yet; ignore silently
      }
    }
  }
}
