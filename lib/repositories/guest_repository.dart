import '../db/db_helper.dart';
import '../models/guest.dart';

class GuestRepository {
  final _dbHelper = DBHelper.instance;

  Future<List<Guest>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query('guests', orderBy: 'name ASC');
    return rows.map((r) => Guest.fromMap(r)).toList();
  }

  Future<Guest?> getById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('guests', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Guest.fromMap(rows.first);
  }

  Future<List<Guest>> search(String query) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'guests',
      where: 'name LIKE ? OR phone LIKE ? OR documentId LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return rows.map((r) => Guest.fromMap(r)).toList();
  }

  Future<int> insert(Guest guest) async {
    final db = await _dbHelper.database;
    final map = guest.toMap()..remove('id');
    final id = await db.insert('guests', map);
    await _dbHelper.logAudit('GUEST', id, 'CREATE', 'Huésped "${guest.name}" creado');
    return id;
  }

  Future<void> update(Guest guest) async {
    final db = await _dbHelper.database;
    await db.update('guests', guest.toMap(), where: 'id = ?', whereArgs: [guest.id]);
    await _dbHelper.logAudit('GUEST', guest.id!, 'UPDATE', 'Huésped "${guest.name}" actualizado');
  }

  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    await db.delete('guests', where: 'id = ?', whereArgs: [id]);
    await _dbHelper.logAudit('GUEST', id, 'DELETE', 'Huésped eliminado');
  }

  Future<int> reservationsCount(int guestId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as c FROM reservations WHERE guestId = ?',
      [guestId],
    );
    return (result.first['c'] as int?) ?? 0;
  }
}
