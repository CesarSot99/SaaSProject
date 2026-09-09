class TaxCalculationResult {
  final int year;
  final double grossServicesRevenue;
  final double totalTips;
  final double totalGrossIncome; // Services + Tips
  final double totalDeductibleExpenses;
  final double netSelfEmploymentIncome; // Total Gross - Expenses
  final double estimatedSelfEmploymentTax; // ~15.3% of 92.35% net profit
  final double estimatedIncomeTax; // ~12% effective income tax
  final double totalEstimatedTaxLiability;
  final double quarterlyEstimatedPayment; // Total Tax / 4
  final double reservePercentage; // e.g. 0.25 (25%)
  final double recommendedTaxReserveAmount; // Net Income * reservePercentage
  final double annualizedProjectedIncome;
  final double annualizedProjectedTax;
  final Map<String, double> expensesByCategory;

  TaxCalculationResult({
    required this.year,
    required this.grossServicesRevenue,
    required this.totalTips,
    required this.totalGrossIncome,
    required this.totalDeductibleExpenses,
    required this.netSelfEmploymentIncome,
    required this.estimatedSelfEmploymentTax,
    required this.estimatedIncomeTax,
    required this.totalEstimatedTaxLiability,
    required this.quarterlyEstimatedPayment,
    required this.reservePercentage,
    required this.recommendedTaxReserveAmount,
    required this.annualizedProjectedIncome,
    required this.annualizedProjectedTax,
    required this.expensesByCategory,
  });
}

class QuarterlyTaxDate {
  final String quarterName;
  final String dueDate;
  final double estimatedAmount;
  final bool isPastDue;

  QuarterlyTaxDate({
    required this.quarterName,
    required this.dueDate,
    required this.estimatedAmount,
    required this.isPastDue,
  });
}
