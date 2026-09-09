import 'package:flutter/material.dart';
import '../../../models/appointment_model.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/barber_data_service.dart';
import '../../../theme/app_theme.dart';

class CustomerHistoryTab extends StatelessWidget {
  const CustomerHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final dataService = BarberDataService();
    final customer = authService.currentUser as CustomerUser?;
    final customerId = customer?.internalId ?? 'UID-CUST-101';

    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        final completedApts = dataService.appointments
            .where((a) => a.customerId == customerId && a.status == AppointmentStatus.completed)
            .toList();

        final totalSpent = completedApts.fold(0.0, (sum, a) => sum + a.totalPriceReceived);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Service History'),
            centerTitle: false,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Services Received', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              '${completedApts.length} Services',
                              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Total Invested', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              '\$${totalSpent.toStringAsFixed(0)}',
                              style: const TextStyle(color: AppTheme.success, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'PAST SERVICES',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (completedApts.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'No completed service history yet.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: completedApts.length,
                      itemBuilder: (context, index) {
                        final apt = completedApts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppTheme.success.withValues(alpha: 0.15),
                                  child: const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        apt.serviceName,
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Date: ${apt.dateTime.month}/${apt.dateTime.day}/${apt.dateTime.year} • Duration: ${apt.durationMinutes} min',
                                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${apt.totalPriceReceived.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Completed',
                                      style: TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
