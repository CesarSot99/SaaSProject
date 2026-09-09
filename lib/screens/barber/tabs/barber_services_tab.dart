import 'package:flutter/material.dart';
import '../../../models/service_model.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/barber_data_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/add_service_modal.dart';
import '../../../widgets/edit_service_modal.dart';

class BarberServicesTab extends StatefulWidget {
  const BarberServicesTab({super.key});

  @override
  State<BarberServicesTab> createState() => _BarberServicesTabState();
}

class _BarberServicesTabState extends State<BarberServicesTab> {
  final BarberDataService _dataService = BarberDataService();
  final AuthService _authService = AuthService();
  String _selectedCategoryFilter = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onDataChanged);
    _authService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _dataService.removeListener(_onDataChanged);
    _authService.removeListener(_onDataChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;
    final barberUser = currentUser is BarberUser ? currentUser : null;
    final businessType = barberUser?.businessType ?? BusinessType.barberShop;
    final categories = businessType.serviceCategories;
    final providerId = barberUser?.internalId ?? 'UID-BARB-7X92K';

    List<BarberServiceItem> services = _dataService.getServicesForBarber(providerId, businessType);

    // Apply category filter
    if (_selectedCategoryFilter != 'All') {
      services = services.where((s) => s.category == _selectedCategoryFilter).toList();
    }

    // Apply search filter
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      services = services.where((s) {
        return s.name.toLowerCase().contains(query) ||
            s.description.toLowerCase().contains(query);
      }).toList();
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Services & Pricing Catalog'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primary),
            tooltip: 'Add Service',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AddServiceModal(),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Add Header
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.surface,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search service or price...',
                            hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                            prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary, size: 20),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close, size: 16),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: AppTheme.background,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.borderColor),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const AddServiceModal(),
                          );
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Category Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((cat) {
                        final isSelected = cat == _selectedCategoryFilter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategoryFilter = cat;
                                });
                              }
                            },
                            selectedColor: AppTheme.primary,
                            backgroundColor: AppTheme.background,
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
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Services List
            Expanded(
              child: services.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.content_cut_rounded, size: 48, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          const Text(
                            'No services found',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Try clearing your search or add a new service.',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final srv = services[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryLight,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              businessType.icon,
                                              color: AppTheme.primary,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  srv.name,
                                                  style: const TextStyle(
                                                    color: AppTheme.textPrimary,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.accentLight,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    srv.category,
                                                    style: const TextStyle(
                                                      color: AppTheme.accentDark,
                                                      fontSize: 10.5,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '\$${srv.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: AppTheme.primary,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 20),
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor: Colors.transparent,
                                              builder: (context) => EditServiceModal(service: srv),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (srv.description.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    srv.description,
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                const Divider(color: AppTheme.borderColor, height: 1),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.timer_outlined, size: 14, color: AppTheme.textMuted),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${srv.durationMinutes} minutes duration',
                                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          srv.isActive ? 'Active' : 'Inactive',
                                          style: TextStyle(
                                            color: srv.isActive ? AppTheme.success : AppTheme.textMuted,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Switch(
                                          value: srv.isActive,
                                          activeThumbColor: AppTheme.primary,
                                          onChanged: (_) => _dataService.toggleServiceStatus(srv.id),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
