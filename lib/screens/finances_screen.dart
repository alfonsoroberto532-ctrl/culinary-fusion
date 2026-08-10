import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/expense.dart';
import '../repositories/finance_repository.dart';
import '../widgets/stat_card.dart';
import '../widgets/empty_state.dart';
import 'expense_form_sheet.dart';

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  final _repo = FinanceRepository();
  final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  final _dateFmt = DateFormat('dd/MM/yyyy');

  FinancialSummary _summary = FinancialSummary();
  List<Expense> _expenses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final summary = await _repo.getSummary();
    final expenses = await _repo.getExpenses();
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _expenses = expenses;
      _loading = false;
    });
  }

  Future<void> _deleteExpense(Expense e) async {
    await _repo.deleteExpense(e.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finanzas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saved = await showExpenseFormSheet(context);
          if (saved == true) _load();
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  const Text('Este Mes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      StatCard(
                        label: 'Ingresos del Mes',
                        value: _currency.format(_summary.totalIncomePeriod),
                        icon: Icons.arrow_downward_rounded,
                        color: AppColors.emeraldTertiary,
                      ),
                      StatCard(
                        label: 'Gastos del Mes',
                        value: _currency.format(_summary.totalExpensesPeriod),
                        icon: Icons.arrow_upward_rounded,
                        color: AppColors.statusOccupied,
                      ),
                      StatCard(
                        label: 'Ganancia Neta',
                        value: _currency.format(_summary.netProfitPeriod),
                        icon: Icons.savings_rounded,
                        color: AppColors.tealPrimary,
                      ),
                      StatCard(
                        label: 'Por Cobrar',
                        value: _currency.format(_summary.pendingToCollect),
                        icon: Icons.hourglass_bottom_rounded,
                        color: AppColors.amberSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text('Gastos Recientes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 10),
                  if (_expenses.isEmpty)
                    const EmptyState(
                      icon: Icons.receipt_long_rounded,
                      title: 'Sin gastos registrados',
                      message: 'Agrega tu primer gasto con el botón +',
                    )
                  else
                    ..._expenses.map((e) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.statusOccupied.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.receipt_rounded, color: AppColors.statusOccupied, size: 18),
                            ),
                            title: Text(e.description),
                            subtitle: Text('${e.categoryName} · ${_dateFmt.format(DateTime.fromMillisecondsSinceEpoch(e.date))}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(_currency.format(e.amount), style: const TextStyle(fontWeight: FontWeight.w700)),
                                InkWell(
                                  onTap: () => _deleteExpense(e),
                                  child: const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.slateOnSurfaceVariant),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                ],
              ),
      ),
    );
  }
}
