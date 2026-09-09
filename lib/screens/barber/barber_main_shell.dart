import 'package:flutter/material.dart';
import '../../widgets/animated_pill_nav_bar.dart';
import 'tabs/barber_appointments_tab.dart';
import 'tabs/barber_clients_tab.dart';
import 'tabs/barber_finances_tab.dart';
import 'tabs/barber_home_tab.dart';
import 'tabs/barber_more_tab.dart';
import 'tabs/barber_services_tab.dart';

class BarberMainShell extends StatefulWidget {
  const BarberMainShell({super.key});

  @override
  State<BarberMainShell> createState() => _BarberMainShellState();
}

class _BarberMainShellState extends State<BarberMainShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    BarberHomeTab(),
    BarberAppointmentsTab(),
    BarberServicesTab(),
    BarberClientsTab(),
    BarberFinancesTab(),
    BarberMoreTab(),
  ];

  static const List<AnimatedNavItem> _navItems = [
    AnimatedNavItem(icon: Icons.home_rounded, label: 'Home'),
    AnimatedNavItem(icon: Icons.calendar_month_rounded, label: 'Appointments'),
    AnimatedNavItem(icon: Icons.content_cut_rounded, label: 'Services'),
    AnimatedNavItem(icon: Icons.people_alt_rounded, label: 'Clients'),
    AnimatedNavItem(icon: Icons.account_balance_wallet_rounded, label: 'Finances'),
    AnimatedNavItem(icon: Icons.grid_view_rounded, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: AnimatedPillNavBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
