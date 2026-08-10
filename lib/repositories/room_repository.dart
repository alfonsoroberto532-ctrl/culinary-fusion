import '../db/db_helper.dart';
import '../models/room.dart';

class RoomRepository {
  final _dbHelper = DBHelper.instance;

  Future<List<Room>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query('rooms', orderBy: 'name ASC');
    return rows.map((r) => Room.fromMap(r)).toList();
  }

  Future<Room?> getById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('rooms', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Room.fromMap(rows.first);
  }

  Future<int> insert(Room room) async {
    final db = await _dbHelper.database;
    final map = room.toMap()..remove('id');
    final id = await db.insert('rooms', map);
    await _dbHelper.logAudit('ROOM', id, 'CREATE', 'Habitación "${room.name}" creada');
    return id;
  }

  Future<void> update(Room room) async {
    final db = await _dbHelper.database;
    await db.update('rooms', room.toMap(), where: 'id = ?', whereArgs: [room.id]);
    await _dbHelper.logAudit('ROOM', room.id!, 'UPDATE', 'Habitación "${room.name}" actualizada');
  }

  Future<void> updateStatus(int roomId, String status) async {
    final db = await _dbHelper.database;
    await db.update('rooms', {'status': status}, where: 'id = ?', whereArgs: [roomId]);
    await _dbHelper.logAudit('ROOM', roomId, 'UPDATE', 'Estado cambiado a $status');
  }

  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    await db.delete('rooms', where: 'id = ?', whereArgs: [id]);
    await _dbHelper.logAudit('ROOM', id, 'DELETE', 'Habitación eliminada');
  }

  Future<Map<String, int>> countByStatus() async {
    final rooms = await getAll();
    final map = <String, int>{
      RoomStatus.available: 0,
      RoomStatus.reserved: 0,
      RoomStatus.occupied: 0,
      RoomStatus.cleaningPending: 0,
      RoomStatus.cleaning: 0,
      RoomStatus.maintenance: 0,
    };
    for (final r in rooms) {
      map[r.status] = (map[r.status] ?? 0) + 1;
    }
    return map;
  }
}
