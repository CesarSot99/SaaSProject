import 'package:flutter/material.dart';
import '../../../services/barber_data_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/notification_bell_button.dart';

class BarberReportsTab extends StatefulWidget {
  const BarberReportsTab({super.key});

  @override
  State<BarberReportsTab> createState() => _BarberReportsTabState();
}

class _BarberReportsTabState extends State<BarberReportsTab> {
  final BarberDataService _dataService = BarberDataService();

  String _selectedPeriod = 'MONTH'; // 'DAY', 'WEEK', 'MONTH', 'YEAR', 'CUSTOM'
  DateTimeRange? _customDateRange;

  Future<void> _selectCustomDateRange() async {
    final now = DateTime.now();
    final initialRange = _customDateRange ??
        DateTimeRange(
          start: now.subtract(const Duration(days: 14)),
          end: now,
        );

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            cardColor: const Color(0xFF1E293B),
            canvasColor: const Color(0xFF1E293B),
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              secondary: AppTheme.accent,
              onSecondary: Colors.white,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
              onSurfaceVariant: Color(0xFF94A3B8),
              error: AppTheme.error,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF1E293B),
              surfaceTintColor: Colors.transparent,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0F172A),
              foregroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.white),
              actionsIconTheme: IconThemeData(color: Colors.white),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: const Color(0xFF1E293B),
              surfaceTintColor: Colors.transparent,
              headerBackgroundColor: const Color(0xFF0F172A),
              headerForegroundColor: Colors.white,
              headerHelpStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w600),
              headerHeadlineStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              weekdayStyle: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                if (states.contains(WidgetState.disabled)) {
                  return const Color(0xFF64748B);
                }
                return Colors.white;
              }),
              dayStyle: const TextStyle(color: Colors.white),
              rangePickerHeaderBackgroundColor: const Color(0xFF0F172A),
              rangePickerHeaderForegroundColor: Colors.white,
              rangePickerHeaderHelpStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w600),
              rangePickerHeaderHeadlineStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              rangeSelectionBackgroundColor: AppTheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _selectedPeriod = 'CUSTOM';
        _customDateRange = pickedRange;
      });
    }
  }

  void _exportReportSummary() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Generating PDF & CSV Analytics Report...'),
          ],
        ),
        backgroundColor: AppTheme.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _dataService,
      builder: (context, _) {
        final data = _dataService.getReportsAndAnalytics(
          period: _selectedPeriod,
          customRange: _customDateRange,
        );

        final totalClients = data['totalClients'] as int;
        final newClients = data['newClients'] as int;
        final recurringClients = data['recurringClients'] as int;
        final inactiveClients = data['inactiveClients'] as int;

        final totalApts = data['totalAppointments'] as int;
        final completedApts = data['completedAppointments'] as int;
        final canceledApts = data['canceledAppointments'] as int;
        final noShowApts = data['noShowAppointments'] as int;
        final confirmationRate = data['confirmationRate'] as double;
        final hourlyCounts = data['hourlyCounts'] as Map<int, int>;

        final serviceRevenue = data['serviceRevenue'] as double;
        final tipsRevenue = data['tipsRevenue'] as double;
        final grossIncome = data['grossIncome'] as double;
        final expenses = data['expenses'] as double;
        final netProfit = data['netProfit'] as double;
        final avgTicket = data['avgTicket'] as double;

        final mostRequested = data['mostRequestedServices'] as List<dynamic>;
        final leastRequested = data['leastRequestedServices'] as List<dynamic>;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.surface,
            elevation: 0,
            titleSpacing: 16,
            title: const Row(
              children: [
                Icon(Icons.insert_chart_rounded, color: AppTheme.primary, size: 22),
                SizedBox(width: 8),
                Text(
                  'Reports & Analytics',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            centerTitle: false,
            actions: [
              const NotificationBellButton(),
              IconButton(
                icon: const Icon(Icons.file_download_rounded, color: AppTheme.tertiary),
                tooltip: 'Export Report',
                onPressed: _exportReportSummary,
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
                  // 1. Period Selection Filter Bar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _PeriodChip(
                          title: 'Today',
                          isSelected: _selectedPeriod == 'DAY',
                          onTap: () => setState(() => _selectedPeriod = 'DAY'),
                        ),
                        const SizedBox(width: 8),
                        _PeriodChip(
                          title: 'Week',
                          isSelected: _selectedPeriod == 'WEEK',
                          onTap: () => setState(() => _selectedPeriod = 'WEEK'),
                        ),
                        const SizedBox(width: 8),
                        _PeriodChip(
                          title: 'Month',
                          isSelected: _selectedPeriod == 'MONTH',
                          onTap: () => setState(() => _selectedPeriod = 'MONTH'),
                        ),
                        const SizedBox(width: 8),
                        _PeriodChip(
                          title: 'Year',
                          isSelected: _selectedPeriod == 'YEAR',
                          onTap: () => setState(() => _selectedPeriod = 'YEAR'),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _selectCustomDateRange,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedPeriod == 'CUSTOM'
                                  ? AppTheme.primary
                                  : AppTheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedPeriod == 'CUSTOM'
                                    ? AppTheme.primary
                                    : AppTheme.borderColor,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.date_range_rounded,
                                  size: 16,
                                  color: _selectedPeriod == 'CUSTOM'
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _selectedPeriod == 'CUSTOM' && _customDateRange != null
                                      ? '${_formatDate(_customDateRange!.start)} - ${_formatDate(_customDateRange!.end)}'
                                      : 'Custom Range',
                                  style: TextStyle(
                                    color: _selectedPeriod == 'CUSTOM'
                                        ? Colors.white
                                        : AppTheme.textSecondary,
                                    fontSize: 12.5,
                                    fontWeight: _selectedPeriod == 'CUSTOM'
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Executive KPI Overview Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withValues(alpha: 0.15),
                          AppTheme.accent.withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
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
                              'EXECUTIVE OVERVIEW',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _selectedPeriod,
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Est. Net Profit', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                const SizedBox(height: 2),
                                Text(
                                  '\$${netProfit.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: netProfit >= 0 ? AppTheme.success : AppTheme.error,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Gross Income', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                const SizedBox(height: 2),
                                Text(
                                  '\$${grossIncome.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. CLIENT ANALYTICS SECTION
                  _SectionTitle(
                    title: 'CLIENT ANALYTICS',
                    icon: Icons.people_alt_rounded,
                    accentColor: AppTheme.primary,
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total Clients',
                          value: '$totalClients',
                          subtitle: 'active database',
                          icon: Icons.groups_rounded,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          title: 'New Clients',
                          value: '+$newClients',
                          subtitle: 'acquired in period',
                          icon: Icons.person_add_alt_1_rounded,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Recurring Clients',
                          value: '$recurringClients',
                          subtitle: '${((recurringClients / (totalClients > 0 ? totalClients : 1)) * 100).toStringAsFixed(0)}% retention rate',
                          icon: Icons.repeat_rounded,
                          color: AppTheme.tertiary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          title: 'Inactive Clients',
                          value: '$inactiveClients',
                          subtitle: '>30 days no booking',
                          icon: Icons.person_off_rounded,
                          color: AppTheme.warning,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 4. APPOINTMENT ANALYTICS SECTION
                  _SectionTitle(
                    title: 'APPOINTMENTS & PEAK HOURS',
                    icon: Icons.calendar_today_rounded,
                    accentColor: AppTheme.accent,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _MetricMini(label: 'Total Booked', value: '$totalApts', color: AppTheme.accent),
                            _MetricMini(label: 'Completed', value: '$completedApts', color: AppTheme.success),
                            _MetricMini(label: 'Canceled', value: '$canceledApts', color: AppTheme.error),
                            _MetricMini(label: 'No Shows', value: '$noShowApts', color: AppTheme.warning),
                            _MetricMini(label: 'Confirm Rate', value: '${confirmationRate.toStringAsFixed(0)}%', color: AppTheme.primary),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Confirmation rate meter bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Appointment Confirmation Performance', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                Text('${confirmationRate.toStringAsFixed(1)}%', style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: (confirmationRate / 100).clamp(0.0, 1.0),
                                backgroundColor: AppTheme.background,
                                color: AppTheme.success,
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Busiest Hours Heatmap / Bar Distribution
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
                        const Text(
                          'Busiest Hours (Peak Time Distribution)',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Shows appointment density across working hours',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: hourlyCounts.entries.map((entry) {
                            final maxVal = hourlyCounts.values.fold(1, (max, v) => v > max ? v : max);
                            final heightPct = (entry.value / maxVal).clamp(0.15, 1.0);
                            final isPeak = entry.value == maxVal && entry.value > 0;

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${entry.value}',
                                  style: TextStyle(
                                    color: isPeak ? AppTheme.accent : AppTheme.textMuted,
                                    fontSize: 10,
                                    fontWeight: isPeak ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 18,
                                  height: 60 * heightPct,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isPeak
                                          ? [AppTheme.accent, AppTheme.primary]
                                          : [AppTheme.primary.withValues(alpha: 0.6), AppTheme.primary.withValues(alpha: 0.2)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${entry.key > 12 ? entry.key - 12 : entry.key}${entry.key >= 12 ? 'p' : 'a'}',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 5. FINANCIAL ANALYTICS SECTION
                  _SectionTitle(
                    title: 'FINANCIAL BREAKDOWN',
                    icon: Icons.account_balance_wallet_rounded,
                    accentColor: AppTheme.success,
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
                        _FinancialLine(label: 'Services Revenue', value: serviceRevenue, color: AppTheme.primary),
                        const SizedBox(height: 10),
                        _FinancialLine(label: 'Tips Received', value: tipsRevenue, color: AppTheme.tertiary),
                        const SizedBox(height: 10),
                        _FinancialLine(label: 'Deductible Expenses', value: -expenses, color: AppTheme.error),
                        const Divider(color: AppTheme.borderColor, height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Net Estimated Profit',
                              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14.5),
                            ),
                            Text(
                              '\$${netProfit.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: netProfit >= 0 ? AppTheme.success : AppTheme.error,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Average Ticket / Service:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              Text('\$${avgTicket.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 6. SERVICE ANALYTICS SECTION
                  _SectionTitle(
                    title: 'SERVICES PERFORMANCE',
                    icon: Icons.content_cut_rounded,
                    accentColor: AppTheme.tertiary,
                  ),
                  const SizedBox(height: 10),

                  // Most Requested Services
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
                            Icon(Icons.star_rounded, color: AppTheme.tertiary, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Most Requested Services',
                              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...mostRequested.map((item) {
                          final name = item['name'] as String;
                          final count = item['count'] as int;
                          final revenue = item['revenue'] as double;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.tertiary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.content_cut_rounded, color: AppTheme.tertiary, size: 16),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text('$count bookings completed', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${revenue.toStringAsFixed(2)}',
                                  style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 13.5),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Least Requested Services
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
                            Icon(Icons.trending_down_rounded, color: AppTheme.warning, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Least Requested Services',
                              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...leastRequested.map((item) {
                          final name = item['name'] as String;
                          final count = item['count'] as int;
                          final revenue = item['revenue'] as double;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(name, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                Text('$count booked (\$${revenue.toStringAsFixed(0)})', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.borderColor,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;

  const _SectionTitle({
    required this.title,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: accentColor, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: accentColor,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _MetricMini extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricMini({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _FinancialLine extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _FinancialLine({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        Text(
          '${value < 0 ? '-' : ''}\$${value.abs().toStringAsFixed(2)}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13.5),
        ),
      ],
    );
  }
}
