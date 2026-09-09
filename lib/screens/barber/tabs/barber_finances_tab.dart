import 'package:flutter/material.dart';
import '../../../models/appointment_model.dart';
import '../../../models/finance_model.dart';
import '../../../services/barber_data_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/add_expense_modal.dart';
import '../../../widgets/notification_bell_button.dart';
import '../../../widgets/receipt_viewer_modal.dart';
import 'barber_reports_tab.dart';
import 'barber_tax_tab.dart';

class BarberFinancesTab extends StatefulWidget {
  const BarberFinancesTab({super.key});

  @override
  State<BarberFinancesTab> createState() => _BarberFinancesTabState();
}

class _BarberFinancesTabState extends State<BarberFinancesTab> {
  final BarberDataService _dataService = BarberDataService();

  // 0 = Resumen Financiero, 1 = Control de Gastos (Módulo 10)
  int _activeSubTab = 0;

  // Period Selector for Resumen & Gastos
  String _selectedPeriod = 'MONTH'; // 'DAY', 'WEEK', 'MONTH', 'YEAR'

  // Expenses Filters
  ExpenseCategory? _expenseCategoryFilter;
  final TextEditingController _expenseSearchController = TextEditingController();
  String _expenseSearchQuery = '';

  @override
  void dispose() {
    _expenseSearchController.dispose();
    super.dispose();
  }

  bool _isWithinPeriod(DateTime date, String period) {
    final now = DateTime.now();
    if (period == 'DAY' || period == 'DÍA') {
      return date.year == now.year && date.month == now.month && date.day == now.day;
    } else if (period == 'WEEK' || period == 'SEMANA') {
      final weekAgo = now.subtract(const Duration(days: 7));
      return date.isAfter(weekAgo);
    } else if (period == 'MONTH' || period == 'MES') {
      return date.year == now.year && date.month == now.month;
    } else if (period == 'YEAR' || period == 'AÑO') {
      return date.year == now.year;
    }
    return true;
  }

  void _openAddExpenseModal([ExpenseModel? expenseToEdit]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseModal(expenseToEdit: expenseToEdit),
    );
  }

  void _openReceiptViewer(ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) => ReceiptViewerModal(expense: expense),
    );
  }

  void _confirmDeleteExpense(ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.borderColor),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.error),
            SizedBox(width: 8),
            Text('Delete Expense', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete expense "${expense.title}" of \$${expense.amount.toStringAsFixed(2)}?',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              _dataService.deleteExpense(expense.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Expense deleted successfully'),
                  backgroundColor: AppTheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showShiftSummaryReport(BuildContext context) {
    final serviceRev = _dataService.getServiceRevenue(_selectedPeriod);
    final tipsRev = _dataService.getTips(_selectedPeriod);
    final totalRev = _dataService.getTotalRevenue(_selectedPeriod);
    final expenses = _dataService.getExpensesAmount(_selectedPeriod);
    final netProfit = _dataService.getNetProfit(_selectedPeriod);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.assessment_rounded, color: AppTheme.primary, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Shift End Financial Summary',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const Divider(color: AppTheme.borderColor, height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Service Revenue:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      Text('\$${serviceRev.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Tips Received:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      Text('\$${tipsRev.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.tertiary, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Gross Total Income:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      Text('\$${totalRev.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Deductible Expenses:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      Text('-\$${expenses.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const Divider(color: AppTheme.borderColor, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Estimated Net Profit:', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('\$${netProfit.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Shift summary report copied to clipboard!'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy Shift Summary'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _dataService,
      builder: (context, _) {
        final serviceRevenue = _dataService.getServiceRevenue(_selectedPeriod);
        final tipsRevenue = _dataService.getTips(_selectedPeriod);
        final totalRevenue = _dataService.getTotalRevenue(_selectedPeriod);
        final totalExpenses = _dataService.getExpensesAmount(_selectedPeriod);
        final netProfit = _dataService.getNetProfit(_selectedPeriod);

        final cashInPocket = _dataService.getCashInPocket(_selectedPeriod);
        final digitalPayments = _dataService.getDigitalPayments(_selectedPeriod);

        final avgTicket = _dataService.getAverageTicket(_selectedPeriod);
        final avgTipPct = _dataService.getAverageTipPercentage(_selectedPeriod);
        final completedCount = _dataService.getCompletedCount(_selectedPeriod);

        // Filtered Expenses for Módulo 10 tab
        final filteredExpensesList = _dataService.expenses.where((exp) {
          final matchesPeriod = _isWithinPeriod(exp.date, _selectedPeriod);
          final matchesCategory = _expenseCategoryFilter == null || exp.category == _expenseCategoryFilter;
          final matchesSearch = _expenseSearchQuery.isEmpty ||
              exp.title.toLowerCase().contains(_expenseSearchQuery.toLowerCase()) ||
              (exp.notes?.toLowerCase().contains(_expenseSearchQuery.toLowerCase()) ?? false);
          return matchesPeriod && matchesCategory && matchesSearch;
        }).toList();

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.surface,
            elevation: 0,
            titleSpacing: 12,
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_balance_wallet_rounded, color: AppTheme.primary, size: 20),
                SizedBox(width: 6),
                Text(
                  'Finances',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            centerTitle: false,
            actions: [
              const NotificationBellButton(),
              IconButton(
                constraints: const BoxConstraints(minWidth: 36),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                icon: const Icon(Icons.insert_chart_rounded, color: AppTheme.primary, size: 22),
                tooltip: 'Reports & Analytics',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BarberReportsTab()),
                  );
                },
              ),
              IconButton(
                constraints: const BoxConstraints(minWidth: 36),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                icon: const Icon(Icons.account_balance_rounded, color: AppTheme.warning, size: 22),
                tooltip: 'Tax Center & Estimations',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BarberTaxTab()),
                  );
                },
              ),
              IconButton(
                constraints: const BoxConstraints(minWidth: 36),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                icon: const Icon(Icons.summarize_rounded, color: AppTheme.primary, size: 22),
                tooltip: 'Shift End Summary',
                onPressed: () => _showShiftSummaryReport(context),
              ),
              IconButton(
                constraints: const BoxConstraints(minWidth: 36),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                icon: const Icon(Icons.add_circle_rounded, color: AppTheme.error, size: 24),
                tooltip: 'Add Expense',
                onPressed: () => _openAddExpenseModal(),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Segmented Navigation Switcher (Resumen vs Módulo Gastos)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _activeSubTab = 0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _activeSubTab == 0 ? AppTheme.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _activeSubTab == 0
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primary.withValues(alpha: 0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.analytics_rounded,
                                    size: 18,
                                    color: _activeSubTab == 0 ? Colors.white : AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Financial Overview',
                                    style: TextStyle(
                                      color: _activeSubTab == 0 ? Colors.white : AppTheme.textSecondary,
                                      fontWeight: _activeSubTab == 0 ? FontWeight.bold : FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _activeSubTab = 1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _activeSubTab == 1 ? AppTheme.accent : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _activeSubTab == 1
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.accent.withValues(alpha: 0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long_rounded,
                                    size: 18,
                                    color: _activeSubTab == 1 ? Colors.white : AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Expense Tracker',
                                    style: TextStyle(
                                      color: _activeSubTab == 1 ? Colors.white : AppTheme.textSecondary,
                                      fontWeight: _activeSubTab == 1 ? FontWeight.bold : FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // VIEW MODE 0: RESUMEN FINANCIERO
                  if (_activeSubTab == 0) ...[
                    // Period Selector
                    Row(
                      children: [
                        _PeriodTab(
                          title: 'Today',
                          isSelected: _selectedPeriod == 'DAY',
                          onTap: () => setState(() => _selectedPeriod = 'DAY'),
                        ),
                        const SizedBox(width: 6),
                        _PeriodTab(
                          title: 'Week',
                          isSelected: _selectedPeriod == 'WEEK',
                          onTap: () => setState(() => _selectedPeriod = 'WEEK'),
                        ),
                        const SizedBox(width: 6),
                        _PeriodTab(
                          title: 'Month',
                          isSelected: _selectedPeriod == 'MONTH',
                          onTap: () => setState(() => _selectedPeriod = 'MONTH'),
                        ),
                        const SizedBox(width: 6),
                        _PeriodTab(
                          title: 'Year',
                          isSelected: _selectedPeriod == 'YEAR',
                          onTap: () => setState(() => _selectedPeriod = 'YEAR'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Net Profit Banner Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.surface,
                            AppTheme.surfaceLight,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: netProfit >= 0 ? AppTheme.success : AppTheme.error,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (netProfit >= 0 ? AppTheme.success : AppTheme.error).withValues(alpha: 0.12),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'ESTIMATED NET PROFIT',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (netProfit >= 0 ? AppTheme.success : AppTheme.error).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _selectedPeriod == 'DAY' ? 'TODAY' : (_selectedPeriod == 'WEEK' ? 'THIS WEEK' : 'THIS MONTH'),
                                  style: TextStyle(
                                    color: netProfit >= 0 ? AppTheme.success : AppTheme.error,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${netProfit.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: netProfit >= 0 ? AppTheme.success : AppTheme.error,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Gross Revenue (\$${totalRevenue.toStringAsFixed(0)}) - Expenses (-\$${totalExpenses.toStringAsFixed(0)})',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Quick Gastos Section Shortcut Banner (Direct link to Módulo Gastos)
                    InkWell(
                      onTap: () => setState(() => _activeSubTab = 1),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.error.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.receipt_long_rounded, color: AppTheme.error, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Expense Tracker & Deductions',
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Deducted in this period: -\$${totalExpenses.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppTheme.error,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.error, size: 16),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Cash Drawer & Payment Method Reconciliation
                    const Text(
                      'CASH DRAWER & PAYMENT RECONCILIATION',
                      style: TextStyle(
                        color: AppTheme.tertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.payments_rounded, color: AppTheme.success, size: 16),
                                    SizedBox(width: 6),
                                    Text('Cash in Register', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '\$${cashInPocket.toStringAsFixed(2)}',
                                  style: const TextStyle(color: AppTheme.success, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const Text('Physical Payments', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 40, color: AppTheme.borderColor),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.credit_card_rounded, color: AppTheme.primary, size: 16),
                                      SizedBox(width: 6),
                                      Text('Card & Digital', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '\$${digitalPayments.toStringAsFixed(2)}',
                                    style: const TextStyle(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const Text('Bank Deposits', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Business Health Insights Row
                    Row(
                      children: [
                        Expanded(
                          child: _InsightTile(
                            title: 'Avg Ticket',
                            value: '\$${avgTicket.toStringAsFixed(2)}',
                            subtitle: 'per client',
                            icon: Icons.confirmation_number_outlined,
                            accentColor: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _InsightTile(
                            title: 'Tip Rate',
                            value: '${avgTipPct.toStringAsFixed(1)}%',
                            subtitle: 'of services',
                            icon: Icons.volunteer_activism_rounded,
                            accentColor: AppTheme.tertiary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _InsightTile(
                            title: 'Services',
                            value: '$completedCount',
                            subtitle: 'completed',
                            icon: Icons.content_cut_rounded,
                            accentColor: AppTheme.success,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Income Breakdown Row (Services vs Tips)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.content_cut_rounded, color: AppTheme.primary, size: 16),
                                    SizedBox(width: 6),
                                    Text('Services', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '\$${serviceRevenue.toStringAsFixed(2)}',
                                  style: const TextStyle(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.tertiary.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.volunteer_activism_rounded, color: AppTheme.tertiary, size: 16),
                                    SizedBox(width: 6),
                                    Text('Propinas', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '\$${tipsRevenue.toStringAsFixed(2)}',
                                  style: const TextStyle(color: AppTheme.tertiary, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Service Performance & Average Ticket Breakdown
                    const Text(
                      'PERFORMANCE BY SERVICE TYPE',
                      style: TextStyle(
                        color: AppTheme.tertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Builder(
                      builder: (context) {
                        final serviceStats = _dataService.getServiceTypeAnalytics(_selectedPeriod);
                        if (serviceStats.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: const Center(
                              child: Text('No service analytics available for this period.', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                            ),
                          );
                        }

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: Column(
                            children: serviceStats.entries.map((entry) {
                              final name = entry.key;
                              final count = entry.value['count'] as int;
                              final total = entry.value['totalRevenue'] as double;
                              final avg = entry.value['avgPrice'] as double;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                                        Text('$count cuts • Avg \$${avg.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11.5)),
                                      ],
                                    ),
                                    Text(
                                      '\$${total.toStringAsFixed(0)}',
                                      style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ],

                  // VIEW MODE 1: MÓDULO 10 — GASTOS EMBEBIDO
                  if (_activeSubTab == 1) ...[
                    // Period Selector & Category Filter Bar
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 42,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.borderColor),
                                  ),
                                  child: TextField(
                                    controller: _expenseSearchController,
                                    onChanged: (val) {
                                      setState(() {
                                        _expenseSearchQuery = val;
                                      });
                                    },
                                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                                    decoration: const InputDecoration(
                                      hintText: 'Search expenses by title or notes...',
                                      hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                      icon: Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 18),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: () => _openAddExpenseModal(),
                                icon: const Icon(Icons.add_rounded, size: 16),
                                label: const Text('New', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('Filter Period: ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: ['DAY', 'WEEK', 'MONTH', 'YEAR'].map((p) {
                                      final isSel = _selectedPeriod == p;
                                      final label = p == 'DAY' ? 'Today' : (p == 'WEEK' ? 'Week' : (p == 'MONTH' ? 'Month' : 'Year'));
                                      return GestureDetector(
                                        onTap: () => setState(() => _selectedPeriod = p),
                                        child: Container(
                                          margin: const EdgeInsets.only(right: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: isSel ? AppTheme.accent : AppTheme.surface,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: isSel ? AppTheme.accent : AppTheme.borderColor),
                                          ),
                                          child: Text(
                                            label,
                                            style: TextStyle(
                                              color: isSel ? Colors.white : AppTheme.textSecondary,
                                              fontSize: 11,
                                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Horizontal Category Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ChoiceChip(
                                  label: const Text('All'),
                                  selected: _expenseCategoryFilter == null,
                                  selectedColor: AppTheme.accent,
                                  backgroundColor: AppTheme.surface,
                                  labelStyle: TextStyle(
                                    color: _expenseCategoryFilter == null ? Colors.white : AppTheme.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onSelected: (sel) => setState(() => _expenseCategoryFilter = null),
                                ),
                                const SizedBox(width: 6),
                                ...ExpenseCategory.values.map((cat) {
                                  final isSel = _expenseCategoryFilter == cat;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ChoiceChip(
                                      avatar: Icon(cat.icon, size: 14, color: isSel ? Colors.white : cat.color),
                                      label: Text(cat.displayName),
                                      selected: isSel,
                                      selectedColor: cat.color,
                                      backgroundColor: AppTheme.surface,
                                      side: BorderSide(color: isSel ? cat.color : AppTheme.borderColor),
                                      labelStyle: TextStyle(
                                        color: isSel ? Colors.white : AppTheme.textPrimary,
                                        fontSize: 11,
                                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                      ),
                                      onSelected: (sel) => setState(() => _expenseCategoryFilter = sel ? cat : null),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Expenses KPI Overview Card
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Spent', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(
                                  '-\$${filteredExpensesList.fold(0.0, (s, e) => s + e.amount).toStringAsFixed(2)}',
                                  style: const TextStyle(color: AppTheme.error, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Saved Receipts', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(
                                  '${filteredExpensesList.where((e) => e.receiptPhoto != null && e.receiptPhoto!.isNotEmpty).length} receipts',
                                  style: const TextStyle(color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Category Progress Breakdown Visual bar
                    if (filteredExpensesList.isNotEmpty) ...[
                      Builder(
                        builder: (context) {
                          final totalExp = filteredExpensesList.fold(0.0, (s, e) => s + e.amount);
                          final Map<ExpenseCategory, double> catTotals = {};
                          for (var e in filteredExpensesList) {
                            catTotals[e.category] = (catTotals[e.category] ?? 0.0) + e.amount;
                          }

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Category Breakdown', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                ...ExpenseCategory.values.map((cat) {
                                  final amt = catTotals[cat] ?? 0.0;
                                  if (amt == 0) return const SizedBox.shrink();
                                  final pct = totalExp > 0 ? (amt / totalExp) : 0.0;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(cat.icon, size: 14, color: cat.color),
                                                const SizedBox(width: 4),
                                                Text(cat.displayName, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
                                              ],
                                            ),
                                            Text(
                                              '\$${amt.toStringAsFixed(2)} (${(pct * 100).toStringAsFixed(0)}%)',
                                              style: TextStyle(color: cat.color, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: pct,
                                            backgroundColor: AppTheme.surface,
                                            valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                                            minHeight: 5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Expenses List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recorded Expenses (${filteredExpensesList.length})',
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () => _openAddExpenseModal(),
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: AppTheme.accent),
                          label: const Text('Add Expense', style: TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (filteredExpensesList.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.receipt_long_outlined, color: AppTheme.textSecondary, size: 40),
                            SizedBox(height: 8),
                            Text('No expenses recorded in this category or period.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredExpensesList.length,
                        separatorBuilder: (ctx, idx) => const SizedBox(height: 8),
                        itemBuilder: (ctx, idx) {
                          final exp = filteredExpensesList[idx];
                          final cat = exp.category;

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Row: Icon, Title, Amount
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: cat.color.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(cat.icon, color: cat.color, size: 18),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        exp.title,
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '-\$${exp.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppTheme.error,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Divider(color: AppTheme.borderColor, height: 1),
                                const SizedBox(height: 8),

                                // Bottom Row: Details and Actions
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: cat.color.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              cat.displayName,
                                              style: TextStyle(color: cat.color, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Text(
                                            '${exp.date.month}/${exp.date.day}/${exp.date.year}',
                                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                          ),
                                          Text(
                                            '• ${exp.paymentMethod.displayName}',
                                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (exp.receiptPhoto != null && exp.receiptPhoto!.isNotEmpty)
                                          IconButton(
                                            icon: const Icon(Icons.receipt_long_rounded, color: AppTheme.primary, size: 18),
                                            tooltip: 'View Receipt',
                                            onPressed: () => _openReceiptViewer(exp),
                                            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                                            padding: EdgeInsets.zero,
                                          ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, color: AppTheme.textSecondary, size: 18),
                                          tooltip: 'Edit',
                                          onPressed: () => _openAddExpenseModal(exp),
                                          constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                                          padding: EdgeInsets.zero,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 18),
                                          tooltip: 'Delete',
                                          onPressed: () => _confirmDeleteExpense(exp),
                                          constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodTab({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.borderColor,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const _InsightTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
              Icon(icon, color: accentColor, size: 15),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}
