import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/barber_data_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/tax_report_modal.dart';

class BarberTaxTab extends StatefulWidget {
  const BarberTaxTab({super.key});

  @override
  State<BarberTaxTab> createState() => _BarberTaxTabState();
}

class _BarberTaxTabState extends State<BarberTaxTab> {
  final BarberDataService _dataService = BarberDataService();
  final AuthService _authService = AuthService();

  int _selectedYear = 2026;
  double _reserveRate = 0.25; // 25% tax reserve recommendation

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _dataService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  void _showCpaReport() {
    final taxData = _dataService.calculateTaxSummary(
      targetYear: _selectedYear,
      reservePercentage: _reserveRate,
    );
    final barberUser = _authService.currentUser;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaxReportModal(
        taxData: taxData,
        barberUser: barberUser as dynamic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taxData = _dataService.calculateTaxSummary(
      targetYear: _selectedYear,
      reservePercentage: _reserveRate,
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Tax Center & Estimates'),
        elevation: 0,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedYear,
              dropdownColor: AppTheme.surface,
              icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
              style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 14),
              items: [2026, 2025].map((y) {
                return DropdownMenuItem<int>(
                  value: y,
                  child: Text('Tax Year $y'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedYear = val);
              },
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Legal Disclaimer Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppTheme.warning, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tax Estimator Tool — These calculations are estimated for planning purposes for US independent barbers. Consult a certified CPA for official filing.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Financial Summary Overview Grid
              const Text(
                'Financial Overview',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _TaxMetricCard(
                      title: 'Gross Income',
                      value: '\$${taxData.totalGrossIncome.toStringAsFixed(0)}',
                      subtitle: 'Services + Tips',
                      color: AppTheme.success,
                      icon: Icons.trending_up_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TaxMetricCard(
                      title: 'Deductible Expenses',
                      value: '\$${taxData.totalDeductibleExpenses.toStringAsFixed(0)}',
                      subtitle: '${taxData.expensesByCategory.length} categories',
                      color: AppTheme.error,
                      icon: Icons.receipt_long_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _TaxMetricCard(
                      title: 'Tracked Tips',
                      value: '\$${taxData.totalTips.toStringAsFixed(0)}',
                      subtitle: 'Included in gross',
                      color: AppTheme.warning,
                      icon: Icons.savings_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TaxMetricCard(
                      title: 'Estimated Net Profit',
                      value: '\$${taxData.netSelfEmploymentIncome.toStringAsFixed(0)}',
                      subtitle: 'Schedule C Net',
                      color: AppTheme.primary,
                      icon: Icons.account_balance_wallet_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 3. US Self-Employment & Income Tax Estimates
              const Text(
                'Estimated Tax Obligations',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  children: [
                    _TaxDetailRow(
                      label: 'Self-Employment Tax (SE Tax 15.3%)',
                      amount: taxData.estimatedSelfEmploymentTax,
                      note: 'Social Security (12.4%) + Medicare (2.9%)',
                      color: AppTheme.primary,
                    ),
                    const Divider(color: AppTheme.borderColor, height: 20),
                    _TaxDetailRow(
                      label: 'Estimated Income Tax (~12%)',
                      amount: taxData.estimatedIncomeTax,
                      note: 'Federal & State income tax estimate',
                      color: AppTheme.tertiary,
                    ),
                    const Divider(color: AppTheme.borderColor, height: 20),
                    _TaxDetailRow(
                      label: 'Total Est. Annual Tax Liability',
                      amount: taxData.totalEstimatedTaxLiability,
                      note: 'Estimated combined tax load for $_selectedYear',
                      color: AppTheme.warning,
                      isTotal: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. Quarterly Estimated Tax Payment Schedule
              const Text(
                'IRS Quarterly Estimated Payments',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'US self-employed individuals make 4 quarterly estimated tax payments:',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _QuarterlyCard(
                      quarter: 'Q1',
                      dueDate: 'Apr 15',
                      amount: taxData.quarterlyEstimatedPayment,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuarterlyCard(
                      quarter: 'Q2',
                      dueDate: 'Jun 15',
                      amount: taxData.quarterlyEstimatedPayment,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuarterlyCard(
                      quarter: 'Q3',
                      dueDate: 'Sep 15',
                      amount: taxData.quarterlyEstimatedPayment,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuarterlyCard(
                      quarter: 'Q4',
                      dueDate: 'Jan 15',
                      amount: taxData.quarterlyEstimatedPayment,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 5. Recommended Tax Reserve Calculator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recommended Tax Reserve Cushion',
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(_reserveRate * 100).toInt()}% Reserve Rate',
                            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We recommend reserving \$${taxData.recommendedTaxReserveAmount.toStringAsFixed(0)} in a separate tax savings account to avoid tax day surprises.',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _reserveRate,
                      min: 0.15,
                      max: 0.35,
                      divisions: 4,
                      activeColor: AppTheme.primary,
                      onChanged: (val) => setState(() => _reserveRate = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 6. Annualized Projection Widget
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.insights_rounded, color: AppTheme.tertiary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Full Year 2026 Projection',
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Projected Annual Gross Revenue:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        Text('\$${taxData.annualizedProjectedIncome.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Projected Full Year Tax Liability:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        Text('\$${taxData.annualizedProjectedTax.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.warning, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 7. Export CPA Report Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _showCpaReport,
                  icon: const Icon(Icons.print_rounded, color: Colors.white),
                  label: const Text(
                    'Generate CPA / Tax Preparer Summary Report',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaxMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _TaxMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _TaxDetailRow extends StatelessWidget {
  final String label;
  final double amount;
  final String note;
  final Color color;
  final bool isTotal;

  const _TaxDetailRow({
    required this.label,
    required this.amount,
    required this.note,
    required this.color,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: isTotal ? 15 : 13,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            Text(
              '\$${amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: color,
                fontSize: isTotal ? 18 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(note, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
      ],
    );
  }
}

class _QuarterlyCard extends StatelessWidget {
  final String quarter;
  final String dueDate;
  final double amount;

  const _QuarterlyCard({
    required this.quarter,
    required this.dueDate,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Text(quarter, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 2),
          Text(dueDate, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
          const SizedBox(height: 6),
          Text(
            '\$${amount.toStringAsFixed(0)}',
            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
