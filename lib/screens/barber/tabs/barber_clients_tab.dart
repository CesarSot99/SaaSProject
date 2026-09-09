import 'package:flutter/material.dart';
import '../../../models/appointment_model.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/barber_data_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/client_detail_sheet.dart';

class BarberClientsTab extends StatefulWidget {
  const BarberClientsTab({super.key});

  @override
  State<BarberClientsTab> createState() => _BarberClientsTabState();
}

class _BarberClientsTabState extends State<BarberClientsTab> {
  final AuthService _authService = AuthService();
  final BarberDataService _dataService = BarberDataService();

  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSegmentFilter = 'All'; // All, New, Frequent, Inactive

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getClientSegment(CustomerUser customer, List<AppointmentModel> customerApts) {
    final now = DateTime.now();
    final completed = customerApts.where((a) => a.status == AppointmentStatus.completed).toList();

    // New Client: Registered in last 30 days
    if (now.difference(customer.createdAt).inDays <= 30) {
      return 'New';
    }

    // Frequent Client: 3+ completed visits
    if (completed.length >= 3) {
      return 'Frequent';
    }

    // Inactive: No completed appointment in last 45 days
    if (completed.isNotEmpty) {
      completed.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      if (now.difference(completed.first.dateTime).inDays > 45) {
        return 'Inactive';
      }
    } else if (now.difference(customer.createdAt).inDays > 45) {
      return 'Inactive';
    }

    return 'Regular';
  }

  void _showClientProfile(
    BuildContext context,
    CustomerUser customer,
    List<AppointmentModel> customerApts,
    double totalSpent,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClientDetailSheet(
        customer: customer,
        customerApts: customerApts,
        totalSpent: totalSpent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final barberUser = _authService.currentUser;
    final barberId = barberUser?.internalId ?? 'UID-BARB-7X92K';

    return ListenableBuilder(
      listenable: Listenable.merge([_dataService, _authService]),
      builder: (context, _) {
        final customers = _authService.getCustomersForBarber(barberId);
        final appointments = _dataService.appointments;

        final filteredCustomers = customers.where((c) {
          final customerApts = appointments.where((a) => a.customerId == c.internalId).toList();
          final segment = _getClientSegment(c, customerApts);

          // Segment Filter
          if (_selectedSegmentFilter == 'New' && segment != 'New') return false;
          if (_selectedSegmentFilter == 'Frequent' && segment != 'Frequent') return false;
          if (_selectedSegmentFilter == 'Inactive' && segment != 'Inactive') return false;

          // Search Filter
          if (_searchQuery.isEmpty) return true;
          return c.fullName.toLowerCase().contains(_searchQuery) ||
              c.phone.toLowerCase().contains(_searchQuery) ||
              c.email.toLowerCase().contains(_searchQuery);
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Client CRM Directory'),
            centerTitle: false,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search by client name, phone or email...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.secondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: AppTheme.secondary),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // CRM Segment Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'All',
                        'New',
                        'Frequent',
                        'Inactive',
                      ].map((segment) {
                        final isSelected = segment == _selectedSegmentFilter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(segment),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedSegmentFilter = segment;
                                });
                              }
                            },
                            selectedColor: AppTheme.primary,
                            backgroundColor: AppTheme.surface,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Directory List
                  Expanded(
                    child: filteredCustomers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_search_rounded, size: 48, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                                const SizedBox(height: 12),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No clients found in segment "$_selectedSegmentFilter".'
                                      : 'No clients matching "$_searchQuery"',
                                  style: const TextStyle(color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredCustomers.length,
                            itemBuilder: (context, index) {
                              final customer = filteredCustomers[index];
                              final customerApts = appointments.where((a) => a.customerId == customer.internalId).toList();
                              final completedApts = customerApts.where((a) => a.status == AppointmentStatus.completed).toList();
                              final totalSpent = completedApts.fold(0.0, (sum, a) => sum + a.totalPriceReceived);
                              final segment = _getClientSegment(customer, customerApts);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () {
                                    _showClientProfile(context, customer, customerApts, totalSpent);
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: AppTheme.tertiary.withValues(alpha: 0.2),
                                          child: Text(
                                            customer.firstName.substring(0, 1).toUpperCase(),
                                            style: const TextStyle(color: AppTheme.tertiary, fontWeight: FontWeight.bold, fontSize: 18),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      customer.fullName,
                                                      style: const TextStyle(
                                                        color: AppTheme.textPrimary,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  _SegmentBadge(segment: segment),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${customer.phone} • ${customer.email}',
                                                style: const TextStyle(
                                                  color: AppTheme.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.primary.withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      '${completedApts.length} Visits',
                                                      style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.success.withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      'Spent: \$${totalSpent.toStringAsFixed(0)}',
                                                      style: const TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  if (customer.galleryPhotos.isNotEmpty) ...[
                                                    const SizedBox(width: 8),
                                                    const Icon(Icons.photo_library_rounded, size: 14, color: AppTheme.tertiary),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.secondary, size: 14),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
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

class _SegmentBadge extends StatelessWidget {
  final String segment;

  const _SegmentBadge({required this.segment});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (segment) {
      case 'New':
        bg = AppTheme.primaryLight;
        fg = AppTheme.primary;
        label = 'NEW';
        break;
      case 'Frequent':
        bg = AppTheme.tertiary.withValues(alpha: 0.15);
        fg = AppTheme.tertiary;
        label = 'VIP';
        break;
      case 'Inactive':
        bg = AppTheme.warning.withValues(alpha: 0.15);
        fg = AppTheme.warning;
        label = 'INACTIVE';
        break;
      default:
        bg = AppTheme.surface;
        fg = AppTheme.textMuted;
        label = 'CLIENT';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }
}
