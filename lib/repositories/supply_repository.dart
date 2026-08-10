import '../db/db_helper.dart';
import '../models/supply.dart';

class SupplyRepository {
  final _dbHelper = DBHelper.instance;

  Future<List<SupplyItem>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query('supply_items', orderBy: 'name ASC');
    return rows.map((r) => SupplyItem.fromMap(r)).toList();
  }

  Future<List<SupplyItem>> getLowStock() async {
    final items = await getAll();
    return items.where((i) => i.isLowStock).toList();
  }

  Future<SupplyItem?> getById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('supply_items', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return SupplyItem.fromMap(rows.first);
  }

  Future<int> insert(SupplyItem item) async {
    final db = await _dbHelper.database;
    final id = await db.insert('supply_items', item.toMap()..remove('id'));
    await _dbHelper.logAudit('INVENTORY', id, 'CREATE', 'Suministro "${item.name}" creado');
    return id;
  }

  Future<void> update(SupplyItem item) async {
    final db = await _dbHelper.database;
    await db.update('supply_items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    await db.delete('supply_items', where: 'id = ?', whereArgs: [id]);
  }

  /// Registra un movimiento de inventario y ajusta el stock actual del ítem.
  Future<void> registerMovement(InventoryMovement movement) async {
    final db = await _dbHelper.database;
    final item = await getById(movement.supplyItemId);
    if (item == null) return;

    double delta;
    switch (movement.movementType) {
      case InventoryMovementType.purchase:
        delta = movement.quantity;
        break;
      case InventoryMovementType.consumption:
      case InventoryMovementType.waste:
        delta = -movement.quantity;
        break;
      case InventoryMovementType.adjustment:
        delta = movement.quantity; // puede ser positivo o negativo
        break;
      default:
        delta = 0;
    }

    final newStock = item.currentStock + delta;
    await db.insert('inventory_movements', movement.toMap()..remove('id'));

    final updated = item.copyWith(
      currentStock: newStock < 0 ? 0 : newStock,
      lastPurchasePrice: movement.movementType == InventoryMovementType.purchase
          ? item.lastPurchasePrice
          : item.lastPurchasePrice,
      lastPurchaseDate: movement.movementType == InventoryMovementType.purchase
          ? movement.date
          : item.lastPurchaseDate,
    );
    await update(updated);
    await _dbHelper.logAudit(
      'INVENTORY',
      item.id!,
      'UPDATE',
      '${movement.movementType} de ${movement.quantity} ${item.unit} en "${item.name}"',
    );
  }

  Future<List<InventoryMovement>> getMovements(int supplyItemId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'inventory_movements',
      where: 'supplyItemId = ?',
      whereArgs: [supplyItemId],
      orderBy: 'date DESC',
    );
    return rows.map((r) => InventoryMovement.fromMap(r)).toList();
  }
}
