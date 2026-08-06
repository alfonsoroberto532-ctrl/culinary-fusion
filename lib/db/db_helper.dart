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

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'casa_renta.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habitaciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        capacidad_maxima INTEGER NOT NULL,
        precio_base_noche REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE insumos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        costo_compra REAL NOT NULL,
        cantidad_rinde REAL NOT NULL,
        tipo_consumo TEXT NOT NULL,
        cantidad_consumo_estandar REAL NOT NULL
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
        monto_mensual REAL NOT NULL
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
        notas TEXT,
        FOREIGN KEY (habitacion_id) REFERENCES habitaciones (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE configuracion (
        id INTEGER PRIMARY KEY,
        tasa_cambio_usd_a_cup REAL NOT NULL,
        tasa_cambio_eur_a_cup REAL NOT NULL,
        moneda_base TEXT NOT NULL
      )
    ''');

    final config = Configuracion.porDefecto();
    await db.insert('configuracion', config.toMap());
  }

  // ── Habitaciones ────────────────────────────────────────────────────────
  Future<int> crearHabitacion(Habitacion h) async {
    final db = await database;
    return db.insert('habitaciones', h.toMap()..remove('id'));
  }

  Future<List<Habitacion>> obtenerHabitaciones() async {
    final db = await database;
    final rows = await db.query('habitaciones', orderBy: 'nombre ASC');
    return rows.map((r) => Habitacion.fromMap(r)).toList();
  }

  Future<int> actualizarHabitacion(Habitacion h) async {
    final db = await database;
    return db.update('habitaciones', h.toMap(), where: 'id = ?', whereArgs: [h.id]);
  }

  Future<int> eliminarHabitacion(int id) async {
    final db = await database;
    return db.delete('habitaciones', where: 'id = ?', whereArgs: [id]);
  }

  // ── Insumos ─────────────────────────────────────────────────────────────
  Future<int> crearInsumo(Insumo i) async {
    final db = await database;
    return db.insert('insumos', i.toMap()..remove('id'));
  }

  Future<List<Insumo>> obtenerInsumos() async {
    final db = await database;
    final rows = await db.query('insumos', orderBy: 'nombre ASC');
    return rows.map((r) => Insumo.fromMap(r)).toList();
  }

  /// Actualiza un insumo. Si el costo de compra cambió respecto al valor
  /// guardado, primero deja un registro en el historial de precios.
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

  Future<int> eliminarInsumo(int id) async {
    final db = await database;
    return db.delete('insumos', where: 'id = ?', whereArgs: [id]);
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

  Future<List<CostoFijo>> obtenerCostosFijos() async {
    final db = await database;
    final rows = await db.query('costos_fijos_mensuales', orderBy: 'nombre ASC');
    return rows.map((r) => CostoFijo.fromMap(r)).toList();
  }

  Future<int> actualizarCostoFijo(CostoFijo c) async {
    final db = await database;
    return db.update('costos_fijos_mensuales', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  Future<int> eliminarCostoFijo(int id) async {
    final db = await database;
    return db.delete('costos_fijos_mensuales', where: 'id = ?', whereArgs: [id]);
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

  // ── Configuración ───────────────────────────────────────────────────────
  Future<Configuracion> obtenerConfiguracion() async {
    final db = await database;
    final rows = await db.query('configuracion', where: 'id = ?', whereArgs: [1]);
    if (rows.isEmpty) return Configuracion.porDefecto();
    return Configuracion.fromMap(rows.first);
  }

  Future<void> guardarConfiguracion(Configuracion config) async {
    final db = await database;
    await db.insert(
      'configuracion',
      config.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
