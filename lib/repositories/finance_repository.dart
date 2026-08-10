import 'package:sqflite/sqflite.dart';
import '../db/db_helper.dart';
import '../models/expense.dart';
import '../models/exchange_rate.dart';

class FinancialSummary {
  final double collectedToday;
  final double pendingToCollect;
  final double expensesToday;
  final double estimatedProfitToday;
  final double totalIncomePeriod;
  final double totalExpensesPeriod;
  final double netProfitPeriod;
  final String primaryCurrency;

  FinancialSummary({
    this.collectedToday = 0,
    this.pendingToCollect = 0,
    this.expensesToday = 0,
    this.estimatedProfitToday = 0,
    this.totalIncomePeriod = 0,
    this.totalExpensesPeriod = 0,
    this.netProfitPeriod = 0,
    this.primaryCurrency = 'USD',
  });
}

class DailyFinance {
  final DateTime day;
  final double income;
  final double expense;
  DailyFinance({required this.day, required this.income, required this.expense});
}

class CategoryTotal {
  final String category;
  final double total;
  CategoryTotal({required this.category, required this.total});
}

class FinanceRepository {
  final _dbHelper = DBHelper.instance;

  // ---- Categorías ----

  Future<List<ExpenseCategory>> getCategories() async {
    final db = await _dbHelper.database;
    final rows = await db.query('expense_categories', orderBy: 'name ASC');
    return rows.map((r) => ExpenseCategory.fromMap(r)).toList();
  }

  Future<int> addCategory(ExpenseCategory category) async {
    final db = await _dbHelper.database;
    return db.insert('expense_categories', category.toMap()..remove('id'));
  }

  // ---- Gastos ----

  Future<List<Expense>> getExpenses({int? from, int? to}) async {
    final db = await _dbHelper.database;
    String? where;
    List<Object?>? args;
    if (from != null && to != null) {
      where = 'date >= ? AND date <= ?';
      args = [from, to];
    }
    final rows = await db.query('expenses', where: where, whereArgs: args, orderBy: 'date DESC');
    return rows.map((r) => Expense.fromMap(r)).toList();
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await _dbHelper.database;
    final id = await db.insert('expenses', expense.toMap()..remove('id'));
    await _dbHelper.logAudit('EXPENSE', id, 'CREATE', '${expense.categoryName}: ${expense.amount}');
    return id;
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await _dbHelper.database;
    await db.update('expenses', expense.toMap(), where: 'id = ?', whereArgs: [expense.id]);
  }

  Future<void> deleteExpense(int id) async {
    final db = await _dbHelper.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // ---- Tasas de cambio ----

  Future<List<ExchangeRate>> getExchangeRates() async {
    final db = await _dbHelper.database;
    final rows = await db.query('exchange_rates', orderBy: 'currencyCode ASC');
    return rows.map((r) => ExchangeRate.fromMap(r)).toList();
  }

  Future<void> upsertExchangeRate(ExchangeRate rate) async {
    final db = await _dbHelper.database;
    await db.insert('exchange_rates', rate.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ---- Series diarias (para gráficas de Estadísticas) ----

  /// Devuelve una serie de los últimos [days] días con el ingreso (pagos) y
  /// gasto totales de cada día, en orden cronológico ascendente.
  Future<List<DailyFinance>> getDailySeries({int days = 7}) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final result = <DailyFinance>[];
    for (int i = days - 1; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final start = day.millisecondsSinceEpoch;
      final end = start + const Duration(days: 1).inMilliseconds;

      final incomeRes = await db.rawQuery(
        'SELECT COALESCE(SUM(amount), 0) as total FROM payments WHERE date >= ? AND date < ?',
        [start, end],
      );
      final expenseRes = await db.rawQuery(
        'SELECT COALESCE(SUM(amount), 0) as total FROM expenses WHERE date >= ? AND date < ?',
        [start, end],
      );
      result.add(DailyFinance(
        day: day,
        income: (incomeRes.first['total'] as num?)?.toDouble() ?? 0.0,
        expense: (expenseRes.first['total'] as num?)?.toDouble() ?? 0.0,
      ));
    }
    return result;
  }

  /// Total de gastos agrupados por categoría dentro de un rango de fechas.
  Future<List<CategoryTotal>> getExpensesByCategory({DateTime? from, DateTime? to}) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final start = (from ?? DateTime(now.year, now.month, 1)).millisecondsSinceEpoch;
    final end = (to ?? now).millisecondsSinceEpoch;
    final rows = await db.rawQuery('''
      SELECT categoryName, COALESCE(SUM(amount), 0) as total
      FROM expenses
      WHERE date >= ? AND date <= ?
      GROUP BY categoryName
      ORDER BY total DESC
    ''', [start, end]);
    return rows
        .map((r) => CategoryTotal(
              category: r['categoryName'] as String,
              total: (r['total'] as num?)?.toDouble() ?? 0.0,
            ))
        .toList();
  }

  // ---- Resumen financiero (equivalente a FinancialSummary del panel inteligente) ----

  Future<FinancialSummary> getSummary({DateTime? periodStart, DateTime? periodEnd}) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final todayEnd = todayStart + const Duration(days: 1).inMilliseconds;

    final start = (periodStart ?? DateTime(now.year, now.month, 1)).millisecondsSinceEpoch;
    final end = (periodEnd ?? now).millisecondsSinceEpoch;

    final collectedTodayRes = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM payments WHERE date >= ? AND date < ?',
      [todayStart, todayEnd],
    );
    final collectedToday = (collectedTodayRes.first['total'] as num?)?.toDouble() ?? 0.0;

    final pendingRes = await db.rawQuery('''
      SELECT COALESCE(SUM(r.totalPrice), 0) as totalDue,
             COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.reservationId = r.id), 0) as totalPaid
      FROM reservations r
      WHERE r.status IN ('CONFIRMED', 'CHECKED_IN')
    ''');
    final totalDue = (pendingRes.first['totalDue'] as num?)?.toDouble() ?? 0.0;
    final totalPaidAgg = await db.rawQuery('''
      SELECT COALESCE(SUM(p.amount), 0) as total
      FROM payments p
      JOIN reservations r ON r.id = p.reservationId
      WHERE r.status IN ('CONFIRMED', 'CHECKED_IN')
    ''');
    final totalPaid = (totalPaidAgg.first['total'] as num?)?.toDouble() ?? 0.0;
    final pendingToCollect = (totalDue - totalPaid) > 0 ? (totalDue - totalPaid) : 0.0;

    final expensesTodayRes = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM expenses WHERE date >= ? AND date < ?',
      [todayStart, todayEnd],
    );
    final expensesToday = (expensesTodayRes.first['total'] as num?)?.toDouble() ?? 0.0;

    final incomePeriodRes = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM payments WHERE date >= ? AND date <= ?',
      [start, end],
    );
    final totalIncomePeriod = (incomePeriodRes.first['total'] as num?)?.toDouble() ?? 0.0;

    final expensesPeriodRes = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM expenses WHERE date >= ? AND date <= ?',
      [start, end],
    );
    final totalExpensesPeriod = (expensesPeriodRes.first['total'] as num?)?.toDouble() ?? 0.0;

    return FinancialSummary(
      collectedToday: collectedToday,
      pendingToCollect: pendingToCollect,
      expensesToday: expensesToday,
      estimatedProfitToday: collectedToday - expensesToday,
      totalIncomePeriod: totalIncomePeriod,
      totalExpensesPeriod: totalExpensesPeriod,
      netProfitPeriod: totalIncomePeriod - totalExpensesPeriod,
    );
  }
}
