import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'custom_button.dart';

class ClientDetailSheet extends StatefulWidget {
  final CustomerUser customer;
  final List<AppointmentModel> customerApts;
  final double totalSpent;

  const ClientDetailSheet({
    super.key,
    required this.customer,
    required this.customerApts,
    required this.totalSpent,
  });

  @override
  State<ClientDetailSheet> createState() => _ClientDetailSheetState();
}

class _ClientDetailSheetState extends State<ClientDetailSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _notesController;
  final AuthService _authService = AuthService();

  bool _isSavingNotes = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _notesController = TextEditingController(text: widget.customer.privateNotes);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveNotes() {
    setState(() => _isSavingNotes = true);
    _authService.updateCustomerPrivateNotes(widget.customer.internalId, _notesController.text.trim());
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isSavingNotes = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Private notes saved!'),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    });
  }

  void _addSamplePhoto() {
    final samplePhotos = [
      'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500',
      'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500',
      'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=500',
      'https://images.unsplash.com/photo-1517832606589-71574620396d?w=500',
    ];
    final photo = samplePhotos[widget.customer.galleryPhotos.length % samplePhotos.length];
    _authService.addCustomerGalleryPhoto(widget.customer.internalId, photo);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reference photo added to client gallery!'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  String _calculateFavoriteService() {
    if (widget.customerApts.isEmpty) return 'None';
    final Map<String, int> counts = {};
    for (var apt in widget.customerApts) {
      counts[apt.serviceName] = (counts[apt.serviceName] ?? 0) + 1;
    }
    var topService = counts.keys.first;
    var maxCount = counts[topService]!;
    counts.forEach((key, value) {
      if (value > maxCount) {
        maxCount = value;
        topService = key;
      }
    });
    return topService;
  }

  AppointmentModel? _getMostRecentCompletedVisit() {
    final completed = widget.customerApts.where((a) => a.status == AppointmentStatus.completed).toList();
    if (completed.isEmpty) return null;
    completed.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return completed.first;
  }

  AppointmentModel? _getNextUpcomingAppointment() {
    final now = DateTime.now();
    final upcoming = widget.customerApts
        .where((a) => a.status != AppointmentStatus.canceled && a.dateTime.isAfter(now))
        .toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.dateTime.compareTo(a.dateTime));
    return upcoming.first;
  }

  @override
  Widget build(BuildContext context) {
    final completedVisits = widget.customerApts.where((a) => a.status == AppointmentStatus.completed).toList();
    final favoriteService = _calculateFavoriteService();
    final lastVisit = _getMostRecentCompletedVisit();
    final nextAppt = _getNextUpcomingAppointment();

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 12),

          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.tertiary.withValues(alpha: 0.2),
                child: Text(
                  widget.customer.firstName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: AppTheme.tertiary, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.customer.fullName,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.customer.phone} • ${widget.customer.email}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
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

          const SizedBox(height: 12),

          // Tab Bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textMuted,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Private Notes 🔒'),
              Tab(text: 'Photo Reference 📷'),
              Tab(text: 'Appointment History'),
            ],
          ),

          const Divider(color: AppTheme.borderColor, height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Overview & CRM Metrics
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Metric Cards Grid
                      Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              title: 'Total Visits',
                              value: '${completedVisits.length}',
                              icon: Icons.event_available_rounded,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricCard(
                              title: 'Total Spent',
                              value: '\$${widget.totalSpent.toStringAsFixed(0)}',
                              icon: Icons.attach_money_rounded,
                              color: AppTheme.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              title: 'Favorite Service',
                              value: favoriteService,
                              icon: Icons.star_rounded,
                              color: AppTheme.warning,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricCard(
                              title: 'Client Since',
                              value: '${widget.customer.createdAt.month}/${widget.customer.createdAt.year}',
                              icon: Icons.history_rounded,
                              color: AppTheme.tertiary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Visit Timestamps
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
                                const Row(
                                  children: [
                                    Icon(Icons.history_toggle_off_rounded, color: AppTheme.secondary, size: 18),
                                    SizedBox(width: 8),
                                    Text('Last Visit:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                  ],
                                ),
                                Text(
                                  lastVisit != null
                                      ? '${lastVisit.dateTime.month}/${lastVisit.dateTime.day}/${lastVisit.dateTime.year}'
                                      : 'No visits yet',
                                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const Divider(color: AppTheme.borderColor, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 18),
                                    SizedBox(width: 8),
                                    Text('Next Appointment:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                  ],
                                ),
                                Text(
                                  nextAppt != null
                                      ? '${nextAppt.dateTime.month}/${nextAppt.dateTime.day} @ ${nextAppt.formattedTime}'
                                      : 'None scheduled',
                                  style: TextStyle(
                                    color: nextAppt != null ? AppTheme.primary : AppTheme.textMuted,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // TAB 2: Private Notes & Formula (Barber Only)
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.tertiary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.tertiary.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lock_rounded, color: AppTheme.tertiary, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Private Barber Notes — Confidential and visible exclusively to you. The client cannot see these notes.',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _notesController,
                        maxLines: 6,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Add private haircut formula, hair type, guard sizes, coffee preference, scalp conditions...',
                          alignLabelWithHint: true,
                          fillColor: AppTheme.surface,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppTheme.borderColor),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      CustomButton(
                        text: _isSavingNotes ? 'Saving...' : 'Save Private Notes',
                        icon: Icons.save_rounded,
                        onPressed: _saveNotes,
                      ),
                    ],
                  ),
                ),

                // TAB 3: Professional Photo Reference Gallery (Barber Only)
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.photo_camera_rounded, color: AppTheme.primary, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Professional Photo Reference — Haircut photos taken for barber reference only. Never visible to the client.',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Client Haircut Photos (${widget.customer.galleryPhotos.length})',
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            onPressed: _addSamplePhoto,
                            icon: const Icon(Icons.add_a_photo_rounded, size: 16, color: AppTheme.primary),
                            label: const Text('+ Add Photo', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      if (widget.customer.galleryPhotos.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: const Center(
                            child: Column(
                              children: [
                                Icon(Icons.no_photography_rounded, size: 40, color: AppTheme.textMuted),
                                SizedBox(height: 8),
                                Text(
                                  'No reference photos uploaded yet.',
                                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: widget.customer.galleryPhotos.length,
                          itemBuilder: (context, index) {
                            final url = widget.customer.galleryPhotos[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => Container(
                                  color: AppTheme.surface,
                                  child: const Icon(Icons.content_cut_rounded, color: AppTheme.primary),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                // TAB 4: Appointment History
                widget.customerApts.isEmpty
                    ? const Center(
                        child: Text('No appointment history recorded.', style: TextStyle(color: AppTheme.textMuted)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: widget.customerApts.length,
                        itemBuilder: (context, index) {
                          final apt = widget.customerApts[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${apt.dateTime.month}/${apt.dateTime.day}/${apt.dateTime.year} • ${apt.formattedTime}',
                                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '\$${apt.totalPriceReceived.toStringAsFixed(0)}',
                                      style: const TextStyle(color: AppTheme.success, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Service: ${apt.serviceName} (${apt.durationMinutes} min)',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
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
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
