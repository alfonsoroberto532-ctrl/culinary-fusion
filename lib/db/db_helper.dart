import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/configuracion.dart';
import '../models/costo_fijo.dart';
import '../models/estadia.dart';
import '../models/habitacion.dart';
import '../models/insumo.dart';

class DBHelper {
  DBHelper._internal();
  static final DBHelper instance = DBHelper._internal();

  static Database? _db;
  static const int _dbVersion = 1;

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'casa_renta.db');
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habitaciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        capacidad_maxima INTEGER NOT NULL,
        precio_base_noche REAL NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE insumos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        costo_compra REAL NOT NULL,
        cantidad_rinde REAL NOT NULL,
        tipo_consumo TEXT NOT NULL,
        cantidad_consumo_estandar REAL NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE historial_precios_insumo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        insumo_id INTEGER NOT NULL,
        precio_anterior REAL NOT NULL,
        fecha_cambio TEXT NOT NULL,
        FOREIGN KEY (insumo_id) REFERENCES insumos (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE costos_fijos_mensuales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        monto_mensual REAL NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE estadias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habitacion_id INTEGER NOT NULL,
        fecha_entrada TEXT NOT NULL,
        fecha_salida TEXT NOT NULL,
        numero_huespedes INTEGER NOT NULL,
        nacionalidad TEXT NOT NULL,
        precio_cobrado REAL NOT NULL,
        moneda_cobro TEXT NOT NULL,
        tasa_cambio_usada REAL,
        estado_pago TEXT NOT NULL DEFAULT 'pendiente',
        estado_estadia TEXT NOT NULL DEFAULT 'activa',
        notas TEXT,
        FOREIGN KEY (habitacion_id) REFERENCES habitaciones (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_estadias_habitacion ON estadias (habitacion_id)');
    await db.execute('CREATE INDEX idx_estadias_fecha_entrada ON estadias (fecha_entrada)');

    await db.execute('''
      CREATE TABLE configuracion (
        id INTEGER PRIMARY KEY,
        tasa_cambio_usd_a_cup REAL NOT NULL,
        tasa_cambio_eur_a_cup REAL NOT NULL,
        moneda_base TEXT NOT NULL
      )
    ''');

    await db.insert('configuracion', Configuracion.porDefecto().toMap());
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Reservado para futuras migraciones, ej.:
    // if (oldVersion < 2) { await db.execute('ALTER TABLE estadias ADD COLUMN ...'); }
  }

  // ── Habitaciones ────────────────────────────────────────────────────────
  Future<int> crearHabitacion(Habitacion h) async {
    final db = await database;
    return db.insert('habitaciones', h.toMap()..remove('id'));
  }

  Future<List<Habitacion>> obtenerHabitaciones({bool soloActivas = true}) async {
    final db = await database;
    final rows = await db.query(
      'habitaciones',
      where: soloActivas ? 'activo = 1' : null,
      orderBy: 'nombre ASC',
    );
    return rows.map((r) => Habitacion.fromMap(r)).toList();
  }

  Future<int> actualizarHabitacion(Habitacion h) async {
    final db = await database;
    return db.update('habitaciones', h.toMap(), where: 'id = ?', whereArgs: [h.id]);
  }

  Future<int> desactivarHabitacion(int id) async {
    final db = await database;
    return db.update('habitaciones', {'activo': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> reactivarHabitacion(int id) async {
    final db = await database;
    return db.update('habitaciones', {'activo': 1}, where: 'id = ?', whereArgs: [id]);
  }

  // ── Insumos ─────────────────────────────────────────────────────────────
  Future<int> crearInsumo(Insumo i) async {
    final db = await database;
    return db.insert('insumos', i.toMap()..remove('id'));
  }

  Future<List<Insumo>> obtenerInsumos({bool soloActivos = true}) async {
    final db = await database;
    final rows = await db.query(
      'insumos',
      where: soloActivos ? 'activo = 1' : null,
      orderBy: 'nombre ASC',
    );
    return rows.map((r) => Insumo.fromMap(r)).toList();
  }

  Future<int> actualizarInsumo(Insumo nuevo) async {
    final db = await database;
    final actualRows = await db.query('insumos', where: 'id = ?', whereArgs: [nuevo.id]);
    if (actualRows.isNotEmpty) {
      final actual = Insumo.fromMap(actualRows.first);
      if (actual.costoCompra != nuevo.costoCompra) {
        await db.insert(
          'historial_precios_insumo',
          HistorialPrecioInsumo(
            insumoId: nuevo.id!,
            precioAnterior: actual.costoCompra,
            fechaCambio: DateTime.now(),
          ).toMap()..remove('id'),
        );
      }
    }
    return db.update('insumos', nuevo.toMap(), where: 'id = ?', whereArgs: [nuevo.id]);
  }

  Future<int> desactivarInsumo(int id) async {
    final db = await database;
    return db.update('insumos', {'activo': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> reactivarInsumo(int id) async {
    final db = await database;
    return db.update('insumos', {'activo': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<HistorialPrecioInsumo>> obtenerHistorialPrecios(int insumoId) async {
    final db = await database;
    final rows = await db.query(
      'historial_precios_insumo',
      where: 'insumo_id = ?',
      whereArgs: [insumoId],
      orderBy: 'fecha_cambio DESC',
    );
    return rows.map((r) => HistorialPrecioInsumo.fromMap(r)).toList();
  }

  // ── Costos fijos ────────────────────────────────────────────────────────
  Future<int> crearCostoFijo(CostoFijo c) async {
    final db = await database;
    return db.insert('costos_fijos_mensuales', c.toMap()..remove('id'));
  }

  Future<List<CostoFijo>> obtenerCostosFijos({bool soloActivos = true}) async {
    final db = await database;
    final rows = await db.query(
      'costos_fijos_mensuales',
      where: soloActivos ? 'activo = 1' : null,
      orderBy: 'nombre ASC',
    );
    return rows.map((r) => CostoFijo.fromMap(r)).toList();
  }

  Future<int> actualizarCostoFijo(CostoFijo c) async {
    final db = await database;
    return db.update('costos_fijos_mensuales', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  Future<int> desactivarCostoFijo(int id) async {
    final db = await database;
    return db.update('costos_fijos_mensuales', {'activo': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> reactivarCostoFijo(int id) async {
    final db = await database;
    return db.update('costos_fijos_mensuales', {'activo': 1}, where: 'id = ?', whereArgs: [id]);
  }

  // ── Estadías ────────────────────────────────────────────────────────────
  Future<int> crearEstadia(Estadia e) async {
    final db = await database;
    return db.insert('estadias', e.toMap()..remove('id'));
  }

  Future<List<Estadia>> obtenerEstadias({DateTime? desde, DateTime? hasta}) async {
    final db = await database;
    List<Map<String, dynamic>> rows;
    if (desde != null && hasta != null) {
      rows = await db.query(
        'estadias',
        where: 'fecha_entrada >= ? AND fecha_entrada <= ?',
        whereArgs: [desde.toIso8601String(), hasta.toIso8601String()],
        orderBy: 'fecha_entrada DESC',
      );
    } else {
      rows = await db.query('estadias', orderBy: 'fecha_entrada DESC');
    }
    return rows.map((r) => Estadia.fromMap(r)).toList();
  }

  Future<int> actualizarEstadia(Estadia e) async {
    final db = await database;
    return db.update('estadias', e.toMap(), where: 'id = ?', whereArgs: [e.id]);
  }

  Future<int> eliminarEstadia(int id) async {
    final db = await database;
    return db.delete('estadias', where: 'id = ?', whereArgs: [id]);
  }

  /// true si otra estadía no cancelada se solapa con el rango dado en la
  /// misma habitación. Excluye [excluirEstadiaId] (útil al editar).
  Future<bool> existeSolapamiento({
    required int habitacionId,
    required DateTime entrada,
    required DateTime salida,
    int? excluirEstadiaId,
  }) async {
    final db = await database;
    final where = StringBuffer(
      'habitacion_id = ? AND estado_estadia != ? AND fecha_entrada < ? AND fecha_salida > ?',
    );
    final args = <Object?>[
      habitacionId,
      EstadoEstadia.cancelada.name,
      salida.toIso8601String(),
      entrada.toIso8601String(),
    ];
    if (excluirEstadiaId != null) {
      where.write(' AND id != ?');
      args.add(excluirEstadiaId);
    }
    final rows = await db.query('estadias', where: where.toString(), whereArgs: args);
    return rows.isNotEmpty;
  }

  // ── Configuración ───────────────────────────────────────────────────────
  Future<Configuracion> obtenerConfiguracion() async {
    final db = await database;
    final rows = await db.query('configuracion', where: 'id = ?', whereArgs: [1]);
    if (rows.isEmpty) return Configuracion.porDefecto();
    return Configuracion.fromMap(rows.first);
  }

  Future<void> guardarConfiguracion(Configuracion config) async {
    final db = await database;
    final map = config.toMap();
    map['id'] = 1;
    await db.insert('configuracion', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}