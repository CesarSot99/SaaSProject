import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/barber_data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/broadcast_announcement_modal.dart';
import '../../widgets/create_promo_modal.dart';
import '../../widgets/inspection_banner_wrapper.dart';
import '../../widgets/suspend_account_modal.dart';
import '../barber/barber_main_shell.dart';
import '../customer/customer_main_shell.dart';
import '../role_selection_screen.dart';

class SuperAdminMainShell extends StatefulWidget {
  const SuperAdminMainShell({super.key});

  @override
  State<SuperAdminMainShell> createState() => _SuperAdminMainShellState();
}

class _SuperAdminMainShellState extends State<SuperAdminMainShell> {
  int _activeTabIndex = 0; // 0=Overview, 1=Users, 2=Subscriptions, 3=Finances, 4=Promos/Settings
  final BarberDataService _dataService = BarberDataService();
  final AuthService _authService = AuthService();

  String _userSearchQuery = '';
  String _userFilterRole = 'ALL'; // 'ALL', 'BARBER', 'CUSTOMER', 'SUSPENDED'

  void _openSuspendModal(BarberUser barber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SuspendAccountModal(barber: barber),
    );
  }

  void _openCreatePromoModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreatePromoModal(),
    );
  }

  void _openBroadcastModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BroadcastAnnouncementModal(),
    );
  }

  void _inspectBarberUser(BarberUser barber) {
    _authService.setCurrentUser(barber);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InspectionBannerWrapper(
          inspectedName: '${barber.fullName} (${barber.shopName})',
          userRoleTitle: barber.businessType.professionalTitle,
          onExit: () {
            _authService.restoreSuperAdmin();
            Navigator.pop(context);
          },
          child: const BarberMainShell(),
        ),
      ),
    );
  }

  void _inspectCustomerUser(CustomerUser customer) {
    _authService.setCurrentUser(customer);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InspectionBannerWrapper(
          inspectedName: customer.fullName,
          userRoleTitle: 'Client',
          onExit: () {
            _authService.restoreSuperAdmin();
            Navigator.pop(context);
          },
          child: const CustomerMainShell(),
        ),
      ),
    );
  }

  void _logoutAdmin() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.borderColor),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppTheme.error),
            SizedBox(width: 8),
            Text('Exit Super Admin', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of the Super Admin SaaS Platform Dashboard?',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _authService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Exit Portal'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _dataService,
      builder: (context, _) {
        final barbers = _dataService.allBarberUsers;
        final customers = _dataService.allCustomerUsers;
        final promos = _dataService.globalPromos;
        final announcements = _dataService.globalAnnouncements;

        final activeBarbers = barbers.where((b) => b.subscriptionStatus == SubscriptionStatus.active).toList();
        final suspendedBarbers = barbers.where((b) => b.subscriptionStatus == SubscriptionStatus.suspended).toList();
        final failedPaymentBarbers = barbers.where((b) => b.subscriptionStatus == SubscriptionStatus.pendingPayment).toList();

        // Calculate Platform MRR
        final mrr = barbers.fold(0.0, (sum, b) {
          final plan = _authService.availablePlans.firstWhere((p) => p.id == b.planId, orElse: () => _authService.availablePlans.first);
          return b.subscriptionStatus == SubscriptionStatus.active ? sum + plan.price : sum;
        });

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.surface,
            elevation: 0,
            title: const Row(
              children: [
                Icon(Icons.admin_panel_settings_rounded, color: AppTheme.tertiary, size: 24),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Super Admin SaaS Portal',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Platform Owner Private Control Center',
                      style: TextStyle(color: AppTheme.tertiary, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
                tooltip: 'Exit Portal',
                onPressed: _logoutAdmin,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Top Segmented Sub-Tab Switcher
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppTheme.surface,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _AdminTabChip(
                          title: 'Overview',
                          icon: Icons.dashboard_rounded,
                          isSelected: _activeTabIndex == 0,
                          onTap: () => setState(() => _activeTabIndex = 0),
                        ),
                        const SizedBox(width: 6),
                        _AdminTabChip(
                          title: 'Users (${barbers.length + customers.length})',
                          icon: Icons.people_alt_rounded,
                          isSelected: _activeTabIndex == 1,
                          onTap: () => setState(() => _activeTabIndex = 1),
                        ),
                        const SizedBox(width: 6),
                        _AdminTabChip(
                          title: 'Subscriptions',
                          icon: Icons.card_membership_rounded,
                          isSelected: _activeTabIndex == 2,
                          badgeCount: failedPaymentBarbers.isNotEmpty ? failedPaymentBarbers.length : null,
                          onTap: () => setState(() => _activeTabIndex = 2),
                        ),
                        const SizedBox(width: 6),
                        _AdminTabChip(
                          title: 'SaaS Finances',
                          icon: Icons.account_balance_wallet_rounded,
                          isSelected: _activeTabIndex == 3,
                          onTap: () => setState(() => _activeTabIndex = 3),
                        ),
                        const SizedBox(width: 6),
                        _AdminTabChip(
                          title: 'Promos & Settings',
                          icon: Icons.tune_rounded,
                          isSelected: _activeTabIndex == 4,
                          onTap: () => setState(() => _activeTabIndex = 4),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: IndexedStack(
                    index: _activeTabIndex,
                    children: [
                      // TAB 0: OVERVIEW
                      _buildOverviewTab(barbers, customers, activeBarbers, suspendedBarbers, mrr),

                      // TAB 1: USERS DIRECTORY & SUSPENSION
                      _buildUsersTab(barbers, customers, activeBarbers, suspendedBarbers),

                      // TAB 2: SUBSCRIPTIONS & FAILED PAYMENTS
                      _buildSubscriptionsTab(barbers, failedPaymentBarbers, mrr),

                      // TAB 3: SAAS FINANCES
                      _buildFinancesTab(barbers, mrr),

                      // TAB 4: PROMOS & ANNOUNCEMENTS SETTINGS
                      _buildSettingsTab(promos, announcements),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TAB 0: OVERVIEW BUILDER
  Widget _buildOverviewTab(
    List<BarberUser> barbers,
    List<CustomerUser> customers,
    List<BarberUser> activeBarbers,
    List<BarberUser> suspendedBarbers,
    double mrr,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero MRR Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.2),
                  AppTheme.tertiary.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.tertiary.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('PLATFORM MONTHLY RECURRING REVENUE (MRR)', style: TextStyle(color: AppTheme.tertiary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                    Icon(Icons.trending_up_rounded, color: AppTheme.success, size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                Text('\$${mrr.toStringAsFixed(2)} / mo', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 32, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('Active SaaS subscriptions from ${activeBarbers.length} professionals', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Overview KPI Grid
          Row(
            children: [
              Expanded(child: _KpiCard(title: 'Active Professionals', value: '${activeBarbers.length}', subtitle: 'out of ${barbers.length} total', icon: Icons.storefront_rounded, color: AppTheme.primary)),
              const SizedBox(width: 10),
              Expanded(child: _KpiCard(title: 'Registered Clients', value: '${customers.length}', subtitle: 'linked to shops', icon: Icons.people_rounded, color: AppTheme.success)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _KpiCard(title: 'Suspended Accounts', value: '${suspendedBarbers.length}', subtitle: 'action required', icon: Icons.block_rounded, color: AppTheme.error)),
              const SizedBox(width: 10),
              Expanded(child: _KpiCard(title: 'New Reg (Last 30D)', value: '+${barbers.length}', subtitle: '100% growth rate', icon: Icons.show_chart_rounded, color: AppTheme.tertiary)),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Management Actions Row
          const Text('QUICK MANAGEMENT ACTIONS', style: TextStyle(color: AppTheme.tertiary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openCreatePromoModal,
                  icon: const Icon(Icons.local_offer_rounded, size: 16),
                  label: const Text('Create Promo Code', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.tertiary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openBroadcastModal,
                  icon: const Icon(Icons.campaign_rounded, size: 16),
                  label: const Text('Broadcast Notice', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TAB 1: USERS TAB BUILDER
  Widget _buildUsersTab(
    List<BarberUser> barbers,
    List<CustomerUser> customers,
    List<BarberUser> activeBarbers,
    List<BarberUser> suspendedBarbers,
  ) {
    final filteredBarbers = barbers.where((b) {
      final matchesSearch = _userSearchQuery.isEmpty || b.fullName.toLowerCase().contains(_userSearchQuery.toLowerCase()) || b.shopName.toLowerCase().contains(_userSearchQuery.toLowerCase());
      final matchesRole = _userFilterRole == 'ALL' || (_userFilterRole == 'SUSPENDED' ? b.subscriptionStatus == SubscriptionStatus.suspended : b.subscriptionStatus == SubscriptionStatus.active);
      return matchesSearch && matchesRole;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Filter bar
          TextField(
            onChanged: (v) => setState(() => _userSearchQuery = v),
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search user name, shop or phone...',
              hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
            ),
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: 'All Professionals (${barbers.length})', isSelected: _userFilterRole == 'ALL', onTap: () => setState(() => _userFilterRole = 'ALL')),
                const SizedBox(width: 6),
                _FilterChip(label: 'Active (${activeBarbers.length})', isSelected: _userFilterRole == 'ACTIVE', onTap: () => setState(() => _userFilterRole = 'ACTIVE')),
                const SizedBox(width: 6),
                _FilterChip(label: 'Suspended (${suspendedBarbers.length})', isSelected: _userFilterRole == 'SUSPENDED', onTap: () => setState(() => _userFilterRole = 'SUSPENDED')),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Barbers Directory List
          const Text('PROFESSIONALS DIRECTORY', style: TextStyle(color: AppTheme.tertiary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
          const SizedBox(height: 8),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredBarbers.length,
            separatorBuilder: (ctx, idx) => const SizedBox(height: 10),
            itemBuilder: (ctx, idx) {
              final b = filteredBarbers[idx];
              final isSuspended = b.subscriptionStatus == SubscriptionStatus.suspended;

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSuspended ? AppTheme.error.withValues(alpha: 0.5) : AppTheme.borderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isSuspended ? AppTheme.error.withValues(alpha: 0.2) : AppTheme.primary.withValues(alpha: 0.2),
                          child: Icon(b.businessType == BusinessType.barberShop ? Icons.content_cut_rounded : Icons.face_retouching_natural_rounded, color: isSuspended ? AppTheme.error : AppTheme.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(b.fullName, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14.5)),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (isSuspended ? AppTheme.error : AppTheme.success).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      b.subscriptionStatus.displayName,
                                      style: TextStyle(color: isSuspended ? AppTheme.error : AppTheme.success, fontSize: 9.5, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('${b.shopName} • ${b.phone}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: AppTheme.borderColor, height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Plan: ${b.planId.toUpperCase()}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11.5)),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _inspectBarberUser(b),
                              icon: const Icon(Icons.remove_red_eye_rounded, size: 14),
                              label: const Text('Inspect', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.tertiary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                elevation: 0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isSuspended)
                              ElevatedButton.icon(
                                onPressed: () {
                                  _dataService.reactivateBarberAccount(b.internalId);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account "${b.shopName}" reactivated.'), backgroundColor: AppTheme.success));
                                },
                                icon: const Icon(Icons.check_circle_rounded, size: 14),
                                label: const Text('Reactivate', style: TextStyle(fontSize: 11)),
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                              )
                            else
                              OutlinedButton.icon(
                                onPressed: () => _openSuspendModal(b),
                                icon: const Icon(Icons.block_rounded, size: 14, color: AppTheme.error),
                                label: const Text('Suspend', style: TextStyle(color: AppTheme.error, fontSize: 11)),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.error), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
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

          const SizedBox(height: 24),

          // Clients Directory List
          const Text('REGISTERED CLIENTS DIRECTORY', style: TextStyle(color: AppTheme.tertiary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
          const SizedBox(height: 8),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: customers.length,
            separatorBuilder: (ctx, idx) => const SizedBox(height: 10),
            itemBuilder: (ctx, idx) {
              final c = customers[idx];

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppTheme.cardBg,
                      child: Icon(Icons.person_rounded, color: AppTheme.success, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.fullName, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('${c.email} • ${c.phone}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _inspectCustomerUser(c),
                      icon: const Icon(Icons.remove_red_eye_rounded, size: 14),
                      label: const Text('Inspect Client', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // TAB 2: SUBSCRIPTIONS & FAILED PAYMENTS BUILDER
  Widget _buildSubscriptionsTab(List<BarberUser> barbers, List<BarberUser> failedPayments, double mrr) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Failed Payments Alert Section
          if (failedPayments.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.warning.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 22),
                      const SizedBox(width: 8),
                      Text('FAILED PAYMENTS ALERT (${failedPayments.length})', style: const TextStyle(color: AppTheme.warning, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('The following accounts have pending/failed subscription billing charges:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 12),

                  ...failedPayments.map((b) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b.shopName, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('Owner: ${b.fullName} • ${b.phone}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              _dataService.retryFailedPayment(b.internalId);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment retried and subscription reactivated for ${b.shopName}!'), backgroundColor: AppTheme.success));
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 14),
                            label: const Text('Retry Charge', style: TextStyle(fontSize: 11)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
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

          // Active Subscription Plans Distribution
          const Text('SUBSCRIPTION PLANS DISTRIBUTION', style: TextStyle(color: AppTheme.tertiary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
          const SizedBox(height: 10),

          ..._authService.availablePlans.map((plan) {
            final subscriberCount = barbers.where((b) => b.planId == plan.id).length;
            final planTotalRev = subscriberCount * plan.price;

            return Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.workspace_premium_rounded, color: AppTheme.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                        Text('\$${plan.price.toStringAsFixed(0)} / mo • $subscriberCount subscribers', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5)),
                      ],
                    ),
                  ),
                  Text('\$${planTotalRev.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.success, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // TAB 3: FINANCES TAB BUILDER
  Widget _buildFinancesTab(List<BarberUser> barbers, double mrr) {
    final commissions = mrr * 0.05; // 5% SaaS commission rate
    final netEarnings = mrr - commissions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SAAS PLATFORM FINANCIAL HEALTH', style: TextStyle(color: AppTheme.tertiary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                const SizedBox(height: 12),

                _FinanceRow(label: 'Total Subscriptions MRR', value: mrr, color: AppTheme.primary),
                const SizedBox(height: 10),
                _FinanceRow(label: 'Stripe / Payment Gateway Fees', value: -commissions, color: AppTheme.error),
                const Divider(color: AppTheme.borderColor, height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Platform Net Revenue', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('\$${netEarnings.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.w900, fontSize: 20)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('PLATFORM TRANSACTION LOGS', style: TextStyle(color: AppTheme.tertiary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderColor)),
            child: const Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Monthly Subscription Renewal', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)), Text('+\$39.00', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold))]),
                SizedBox(height: 4),
                Align(alignment: Alignment.centerLeft, child: Text('Carlos Rodriguez (Elite Barber Shop) • Card ****4242', style: TextStyle(color: AppTheme.textMuted, fontSize: 11))),
                Divider(color: AppTheme.borderColor, height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Monthly Subscription Renewal', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)), Text('+\$39.00', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold))]),
                SizedBox(height: 4),
                Align(alignment: Alignment.centerLeft, child: Text('Elena Vasquez (Glamour Hair) • Card ****8811', style: TextStyle(color: AppTheme.textMuted, fontSize: 11))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 4: PROMOS & SETTINGS BUILDER
  Widget _buildSettingsTab(List<SaaSGlobalPromo> promos, List<SaaSAnnouncement> announcements) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Global Promos Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('GLOBAL PROMOTIONS', style: TextStyle(color: AppTheme.tertiary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
              TextButton.icon(
                onPressed: _openCreatePromoModal,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: AppTheme.primary),
                label: const Text('Add Promo', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ...promos.map((p) {
            return Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderColor)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppTheme.tertiary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.local_offer_rounded, color: AppTheme.tertiary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.code, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                        Text('${p.discountPercent.toStringAsFixed(0)}% OFF • Used ${p.timesUsed} times', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  Switch(
                    value: p.isActive,
                    activeThumbColor: AppTheme.tertiary,
                    onChanged: (_) => _dataService.togglePromoStatus(p.id),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Broadcasted Announcements Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('BROADCASTED ANNOUNCEMENTS', style: TextStyle(color: AppTheme.tertiary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
              TextButton.icon(
                onPressed: _openBroadcastModal,
                icon: const Icon(Icons.campaign_rounded, size: 16, color: AppTheme.primary),
                label: const Text('New Notice', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ...announcements.map((a) {
            return Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderColor)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(a.title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(a.targetAudience, style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(a.message, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AdminTabChip extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final int? badgeCount;
  final VoidCallback onTap;

  const _AdminTabChip({
    required this.title,
    required this.icon,
    required this.isSelected,
    this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.warning,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$badgeCount', style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _KpiCard({
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
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withValues(alpha: 0.2) : AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _FinanceRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _FinanceRow({
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
