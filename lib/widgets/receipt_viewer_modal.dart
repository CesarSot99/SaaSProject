import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../models/finance_model.dart';
import '../theme/app_theme.dart';

class ReceiptViewerModal extends StatelessWidget {
  final ExpenseModel expense;

  const ReceiptViewerModal({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final cat = expense.category;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${cat.displayName} • \$${expense.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: cat.color,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(color: AppTheme.borderColor, height: 1),

            // Receipt Photo Display
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (expense.receiptPhoto != null && expense.receiptPhoto!.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 380),
                        width: double.infinity,
                        color: Colors.black,
                        child: Image.network(
                          expense.receiptPhoto!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              alignment: Alignment.center,
                              color: AppTheme.surface,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image_rounded, color: AppTheme.textSecondary, size: 48),
                                  SizedBox(height: 8),
                                  Text(
                                    'Could not load receipt image',
                                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: const Column(
                          children: [
                            Icon(Icons.receipt_long_outlined, color: AppTheme.textSecondary, size: 56),
                            SizedBox(height: 12),
                            Text(
                              'No receipt photo attached',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                      ),

                    // Details Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetaItem(
                                Icons.calendar_today_rounded,
                                'Date',
                                '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                              ),
                              _buildMetaItem(
                                Icons.payment_rounded,
                                'Payment Method',
                                expense.paymentMethod.displayName,
                              ),
                              _buildMetaItem(
                                Icons.monetization_on_outlined,
                                'Total Amount',
                                '\$${expense.amount.toStringAsFixed(2)}',
                                textColor: AppTheme.error,
                              ),
                            ],
                          ),
                          if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.borderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Additional Notes:',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    expense.notes!,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String label, String value, {Color? textColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: textColor ?? AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
