import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/expense.dart';

/// Acceso central a la base de datos SQLite offline-first de VaraNova Hostal.
/// Sigue el mismo patrón de singleton usado en VaraNova POS y GestorV.
class DBHelper {
  DBHelper._internal();
  static final DBHelper instance = DBHelper._internal();

  static Database? _db;
  static const int _dbVersion = 1;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'varanova_hostal.db');
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE rooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        capacity INTEGER NOT NULL DEFAULT 2,
        pricePerNight REAL NOT NULL DEFAULT 30.0,
        currency TEXT NOT NULL DEFAULT 'USD',
        status TEXT NOT NULL DEFAULT 'AVAILABLE',
        roomType TEXT NOT NULL DEFAULT 'DOUBLE',
        isEntireProperty INTEGER NOT NULL DEFAULT 0,
        features TEXT NOT NULL DEFAULT '',
        notes TEXT NOT NULL DEFAULT '',
        photoUri TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE guests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL DEFAULT '',
        nationality TEXT NOT NULL DEFAULT '',
        documentId TEXT NOT NULL DEFAULT '',
        notes TEXT NOT NULL DEFAULT '',
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reservations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        guestId INTEGER NOT NULL,
        roomId INTEGER NOT NULL,
        checkInDate INTEGER NOT NULL,
        checkOutDate INTEGER NOT NULL,
        checkInTime TEXT NOT NULL DEFAULT '14:00',
        checkOutTime TEXT NOT NULL DEFAULT '11:00',
        guestCount INTEGER NOT NULL DEFAULT 1,
        pricePerNight REAL NOT NULL DEFAULT 0.0,
        totalPrice REAL NOT NULL DEFAULT 0.0,
        advancePayment REAL NOT NULL DEFAULT 0.0,
        currency TEXT NOT NULL DEFAULT 'USD',
        status TEXT NOT NULL DEFAULT 'CONFIRMED',
        notes TEXT NOT NULL DEFAULT '',
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (guestId) REFERENCES guests(id) ON DELETE CASCADE,
        FOREIGN KEY (roomId) REFERENCES rooms(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_reservations_room ON reservations(roomId)');
    await db.execute('CREATE INDEX idx_reservations_guest ON reservations(guestId)');

    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reservationId INTEGER NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL DEFAULT 'USD',
        exchangeRateToPrimary REAL NOT NULL DEFAULT 1.0,
        date INTEGER NOT NULL,
        paymentType TEXT NOT NULL DEFAULT 'Adelanto',
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (reservationId) REFERENCES reservations(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_payments_reservation ON payments(reservationId)');

    await db.execute('''
      CREATE TABLE expense_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        iconName TEXT NOT NULL DEFAULT 'receipt',
        isSystem INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date INTEGER NOT NULL,
        categoryName TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL DEFAULT 'USD',
        exchangeRateToPrimary REAL NOT NULL DEFAULT 1.0,
        roomId INTEGER,
        reservationId INTEGER,
        supplier TEXT,
        notes TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE supply_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'Limpieza',
        unit TEXT NOT NULL DEFAULT 'Unidad',
        currentStock REAL NOT NULL DEFAULT 0.0,
        minStock REAL NOT NULL DEFAULT 5.0,
        lastPurchasePrice REAL NOT NULL DEFAULT 0.0,
        currency TEXT NOT NULL DEFAULT 'USD',
        supplier TEXT,
        lastPurchaseDate INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE inventory_movements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supplyItemId INTEGER NOT NULL,
        movementType TEXT NOT NULL,
        quantity REAL NOT NULL,
        date INTEGER NOT NULL,
        roomId INTEGER,
        reservationId INTEGER,
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (supplyItemId) REFERENCES supply_items(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_movements_supply ON inventory_movements(supplyItemId)');

    await db.execute('''
      CREATE TABLE cleaning_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        roomId INTEGER NOT NULL,
        date INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'COMPLETED',
        productsUsed TEXT NOT NULL DEFAULT '',
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (roomId) REFERENCES rooms(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_cleaning_room ON cleaning_records(roomId)');

    await db.execute('''
      CREATE TABLE maintenance_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        roomId INTEGER NOT NULL,
        issue TEXT NOT NULL,
        priority TEXT NOT NULL DEFAULT 'MEDIUM',
        status TEXT NOT NULL DEFAULT 'PENDING',
        cost REAL NOT NULL DEFAULT 0.0,
        currency TEXT NOT NULL DEFAULT 'USD',
        technician TEXT,
        reportedDate INTEGER NOT NULL,
        resolvedDate INTEGER,
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (roomId) REFERENCES rooms(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_maintenance_room ON maintenance_records(roomId)');

    await db.execute('''
      CREATE TABLE exchange_rates (
        currencyCode TEXT PRIMARY KEY,
        rateToPrimary REAL NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entityType TEXT NOT NULL,
        entityId INTEGER NOT NULL,
        action TEXT NOT NULL,
        details TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');

    await _seed(db);
  }

  Future<void> _seed(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Categorías de gastos por defecto
    final batch = db.batch();
    for (final name in ExpenseCategory.defaultCategories) {
      batch.insert('expense_categories', {
        'name': name,
        'iconName': 'receipt',
        'isSystem': 1,
      });
    }

    // Tasas de cambio base
    batch.insert('exchange_rates', {'currencyCode': 'USD', 'rateToPrimary': 1.0, 'lastUpdated': now});
    batch.insert('exchange_rates', {'currencyCode': 'CUP', 'rateToPrimary': 380.0, 'lastUpdated': now});
    batch.insert('exchange_rates', {'currencyCode': 'EUR', 'rateToPrimary': 0.92, 'lastUpdated': now});

    // Habitaciones de ejemplo para empezar a trabajar de inmediato
    batch.insert('rooms', {
      'name': 'Habitación 1',
      'description': 'Habitación doble con vista al patio',
      'capacity': 2,
      'pricePerNight': 30.0,
      'currency': 'USD',
      'status': 'AVAILABLE',
      'roomType': 'DOUBLE',
      'isEntireProperty': 0,
      'features': 'Aire Acondicionado, Baño Privado, Wi-Fi',
      'notes': '',
    });
    batch.insert('rooms', {
      'name': 'Habitación 2',
      'description': 'Habitación individual',
      'capacity': 1,
      'pricePerNight': 20.0,
      'currency': 'USD',
      'status': 'AVAILABLE',
      'roomType': 'SINGLE',
      'isEntireProperty': 0,
      'features': 'Ventilador, Baño Compartido',
      'notes': '',
    });

    await batch.commit(noResult: true);
  }

  Future<void> logAudit(String entityType, int entityId, String action, String details) async {
    final db = await database;
    await db.insert('audit_logs', {
      'entityType': entityType,
      'entityId': entityId,
      'action': action,
      'details': details,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
