import 'package:flutter/material.dart';
import '../../models/appointment_model.dart';
import '../../models/finance_model.dart';
import '../../services/barber_data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/add_expense_modal.dart';
import '../../widgets/receipt_viewer_modal.dart';

class BarberExpensesScreen extends StatefulWidget {
  const BarberExpensesScreen({super.key});

  @override
  State<BarberExpensesScreen> createState() => _BarberExpensesScreenState();
}

class _BarberExpensesScreenState extends State<BarberExpensesScreen> {
  final BarberDataService _dataService = BarberDataService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedPeriod = 'MONTH'; // 'DAY', 'WEEK', 'MONTH', 'YEAR'
  ExpenseCategory? _selectedCategoryFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _dataService.removeListener(_onDataChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  bool _isDateInPeriod(DateTime date, String period) {
    final now = DateTime.now();
    if (period == 'DAY') {
      return date.year == now.year && date.month == now.month && date.day == now.day;
    } else if (period == 'WEEK') {
      final weekAgo = now.subtract(const Duration(days: 7));
      return date.isAfter(weekAgo);
    } else if (period == 'MONTH') {
      return date.year == now.year && date.month == now.month;
    } else if (period == 'YEAR') {
      return date.year == now.year;
    }
    return true;
  }

  List<ExpenseModel> get _filteredExpenses {
    return _dataService.expenses.where((exp) {
      final matchesPeriod = _isDateInPeriod(exp.date, _selectedPeriod);
      final matchesCategory = _selectedCategoryFilter == null || exp.category == _selectedCategoryFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          exp.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (exp.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesPeriod && matchesCategory && matchesSearch;
    }).toList();
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
          'Are you sure you want to delete the expense "${expense.title}" of \$${expense.amount.toStringAsFixed(2)}?',
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

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredExpenses;
    final totalSpent = filteredList.fold(0.0, (sum, e) => sum + e.amount);
    final receiptsCount = filteredList.where((e) => e.receiptPhoto != null && e.receiptPhoto!.isNotEmpty).length;

    // Highest expense category calculation
    final Map<ExpenseCategory, double> catTotals = {};
    for (var exp in filteredList) {
      catTotals[exp.category] = (catTotals[exp.category] ?? 0.0) + exp.amount;
    }

    ExpenseCategory? topCat;
    double topCatAmount = 0.0;
    catTotals.forEach((cat, amt) {
      if (amt > topCatAmount) {
        topCatAmount = amt;
        topCat = cat;
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.receipt_long_rounded, color: AppTheme.primary, size: 24),
            SizedBox(width: 10),
            Text(
              'Expense Tracker',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => _openAddExpenseModal(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('New Expense', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    title: 'Total Expenses',
                    value: '\$${totalSpent.toStringAsFixed(2)}',
                    subtitle: 'In period ($_selectedPeriod)',
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppTheme.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard(
                    title: 'Top Category',
                    value: topCat != null ? topCat!.displayName : 'N/A',
                    subtitle: topCat != null ? '\$${topCatAmount.toStringAsFixed(2)}' : 'No data',
                    icon: topCat?.icon ?? Icons.category_outlined,
                    color: topCat?.color ?? AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard(
                    title: 'Receipts Attached',
                    value: '$receiptsCount / ${filteredList.length}',
                    subtitle: 'Digitized receipts',
                    icon: Icons.receipt_outlined,
                    color: AppTheme.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Category Breakdown Progress Section
            if (totalSpent > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expense Breakdown by Category',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...ExpenseCategory.values.map((cat) {
                      final catAmt = catTotals[cat] ?? 0.0;
                      if (catAmt == 0) return const SizedBox.shrink();
                      final pct = (catAmt / totalSpent);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(cat.icon, size: 16, color: cat.color),
                                    const SizedBox(width: 6),
                                    Text(
                                      cat.displayName,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '\$${catAmt.toStringAsFixed(2)} (${(pct * 100).toStringAsFixed(1)}%)',
                                  style: TextStyle(
                                    color: cat.color,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: AppTheme.surface,
                                valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Period & Filters Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  // Period Selector Chips & Search Input Row
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
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'Search expenses by title or note...',
                              hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              icon: Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 18),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Period Switcher
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: ['DAY', 'WEEK', 'MONTH', 'YEAR'].map((p) {
                            final isSel = _selectedPeriod == p;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPeriod = p;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSel ? AppTheme.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  p,
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
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Category Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All Categories'),
                          selected: _selectedCategoryFilter == null,
                          selectedColor: AppTheme.primary,
                          backgroundColor: AppTheme.surface,
                          labelStyle: TextStyle(
                            color: _selectedCategoryFilter == null ? Colors.white : AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (sel) {
                            setState(() {
                              _selectedCategoryFilter = null;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ...ExpenseCategory.values.map((cat) {
                          final isSelected = _selectedCategoryFilter == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              avatar: Icon(cat.icon, size: 14, color: isSelected ? Colors.white : cat.color),
                              label: Text(cat.displayName),
                              selected: isSelected,
                              selectedColor: cat.color,
                              backgroundColor: AppTheme.surface,
                              side: BorderSide(color: isSelected ? cat.color : AppTheme.borderColor),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textPrimary,
                                fontSize: 12,
                              ),
                              onSelected: (sel) {
                                setState(() {
                                  _selectedCategoryFilter = sel ? cat : null;
                                });
                              },
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

            // Expenses List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expense History (${filteredList.length})',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Filter: $_selectedPeriod',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // List of Expense Cards
            if (filteredList.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, color: AppTheme.textSecondary, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'No recorded expenses found for this period.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredList.length,
                separatorBuilder: (ctx, idx) => const SizedBox(height: 10),
                itemBuilder: (ctx, idx) {
                  final exp = filteredList[idx];
                  final cat = exp.category;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Row(
                      children: [
                        // Category Icon Badge
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cat.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(cat.icon, color: cat.color, size: 22),
                        ),
                        const SizedBox(width: 14),

                        // Title, Date & Category text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exp.title,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: cat.color.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      cat.displayName,
                                      style: TextStyle(
                                        color: cat.color,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${exp.date.day}/${exp.date.month}/${exp.date.year}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '• ${exp.paymentMethod.displayName}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              if (exp.notes != null && exp.notes!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  exp.notes!,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary.withValues(alpha: 0.8),
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Amount & Actions
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '-\$${exp.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppTheme.error,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (exp.receiptPhoto != null && exp.receiptPhoto!.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.receipt_long_rounded, color: AppTheme.secondary, size: 20),
                                    tooltip: 'View Attached Receipt',
                                    onPressed: () => _openReceiptViewer(exp),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(4),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppTheme.textSecondary, size: 20),
                                  tooltip: 'Edit Expense',
                                  onPressed: () => _openAddExpenseModal(exp),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 20),
                                  tooltip: 'Delete Expense',
                                  onPressed: () => _confirmDeleteExpense(exp),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
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
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddExpenseModal(),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Record Expense',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color == AppTheme.error ? AppTheme.error : AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
