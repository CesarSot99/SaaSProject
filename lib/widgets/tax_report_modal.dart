import 'package:flutter/material.dart';
import '../models/tax_model.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import 'custom_button.dart';

class TaxReportModal extends StatelessWidget {
  final TaxCalculationResult taxData;
  final BarberUser? barberUser;

  const TaxReportModal({
    super.key,
    required this.taxData,
    this.barberUser,
  });

  @override
  Widget build(BuildContext context) {
    final barberName = barberUser?.fullName ?? 'Carlos Rodriguez';
    final shopName = barberUser?.shopName ?? 'Carlos Fade Studio';
    final taxYear = taxData.year;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
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
                  Icon(Icons.description_rounded, color: AppTheme.primary, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'CPA Tax Preparer Report',
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

          const Divider(color: AppTheme.borderColor, height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business Header Card
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
                        Text(
                          shopName,
                          style: const TextStyle(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Independent Contractor: $barberName',
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'IRS Form 1040 Schedule C Reference • Tax Year $taxYear',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Income Section
                  const Text('1. GROSS REVENUE & TIPS (Schedule C Line 1)', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _ReportRow(label: 'Gross Service Revenue', amount: taxData.grossServicesRevenue),
                  _ReportRow(label: 'Tracked Client Tips', amount: taxData.totalTips),
                  const Divider(color: AppTheme.borderColor),
                  _ReportRow(label: 'Total Gross Income', amount: taxData.totalGrossIncome, isBold: true, color: AppTheme.success),

                  const SizedBox(height: 20),

                  // Deductible Expenses Section
                  const Text('2. DEDUCTIBLE BUSINESS EXPENSES (Schedule C Part II)', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (taxData.expensesByCategory.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('No categorized expenses logged.', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    )
                  else
                    ...taxData.expensesByCategory.entries.map((e) => _ReportRow(label: e.key, amount: e.value)),
                  const Divider(color: AppTheme.borderColor),
                  _ReportRow(label: 'Total Business Deductions', amount: taxData.totalDeductibleExpenses, isBold: true, color: AppTheme.error),

                  const SizedBox(height: 20),

                  // Net Profit Section
                  const Text('3. NET SCHEDULE C PROFIT', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _ReportRow(label: 'Net Self-Employment Income', amount: taxData.netSelfEmploymentIncome, isBold: true, color: AppTheme.primary),

                  const SizedBox(height: 20),

                  // Tax Estimates Section
                  const Text('4. ESTIMATED TAX OBLIGATIONS', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _ReportRow(label: 'Est. Self-Employment Tax (15.3%)', amount: taxData.estimatedSelfEmploymentTax),
                  _ReportRow(label: 'Est. Federal/State Income Tax (~12%)', amount: taxData.estimatedIncomeTax),
                  const Divider(color: AppTheme.borderColor),
                  _ReportRow(label: 'Total Est. Annual Tax Liability', amount: taxData.totalEstimatedTaxLiability, isBold: true, color: AppTheme.warning),

                  const SizedBox(height: 24),

                  // Notice Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.gavel_rounded, color: AppTheme.warning, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Disclaimer: This report provides automated financial estimates for reference only. Please provide this document to your certified CPA or Tax Professional to prepare official IRS Form 1040 returns.',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          CustomButton(
            text: 'Print / Save CPA Tax Summary',
            icon: Icons.print_rounded,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tax report generated and ready for your CPA!'),
                  backgroundColor: AppTheme.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isBold;
  final Color? color;

  const _ReportRow({
    required this.label,
    required this.amount,
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? AppTheme.textPrimary : AppTheme.textSecondary,
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color ?? (isBold ? AppTheme.textPrimary : AppTheme.textPrimary),
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
