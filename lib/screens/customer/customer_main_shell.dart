import 'package:flutter/material.dart';
import '../../widgets/animated_pill_nav_bar.dart';
import 'tabs/customer_appointments_tab.dart';
import 'tabs/customer_book_tab.dart';
import 'tabs/customer_history_tab.dart';
import 'tabs/customer_home_tab.dart';
import 'tabs/customer_profile_tab.dart';

class CustomerMainShell extends StatefulWidget {
  final int initialTabIndex;

  const CustomerMainShell({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<CustomerMainShell> createState() => _CustomerMainShellState();
}

class _CustomerMainShellState extends State<CustomerMainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  static const List<AnimatedNavItem> _navItems = [
    AnimatedNavItem(icon: Icons.home_rounded, label: 'Home'),
    AnimatedNavItem(icon: Icons.calendar_month_rounded, label: 'Book'),
    AnimatedNavItem(icon: Icons.bookmark_added_rounded, label: 'Appointments'),
    AnimatedNavItem(icon: Icons.history_rounded, label: 'History'),
    AnimatedNavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      CustomerHomeTab(onNavigateToTab: _navigateToTab),
      CustomerBookTab(onBookingSuccess: () => _navigateToTab(2)),
      const CustomerAppointmentsTab(),
      const CustomerHistoryTab(),
      const CustomerProfileTab(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: AnimatedPillNavBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: _navigateToTab,
      ),
    );
  }
}
