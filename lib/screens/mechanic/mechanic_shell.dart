import 'package:flutter/material.dart';

import '../../widgets/app_nav_bar.dart';
import 'earnings_tab.dart';
import 'mechanic_home_tab.dart';
import 'mechanic_profile_tab.dart';
import 'requests_tab.dart';

class MechanicShell extends StatefulWidget {
  const MechanicShell({super.key});

  @override
  State<MechanicShell> createState() => _MechanicShellState();
}

class _MechanicShellState extends State<MechanicShell> {
  int _index = 0;

  static const _items = [
    NavItemData(Icons.space_dashboard_outlined, Icons.space_dashboard_rounded,
        'Dashboard'),
    NavItemData(Icons.markunread_mailbox_outlined, Icons.markunread_mailbox_rounded,
        'Requests'),
    NavItemData(Icons.account_balance_wallet_outlined,
        Icons.account_balance_wallet_rounded, 'Earnings'),
    NavItemData(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  late final List<Widget> _pages = [
    MechanicHomeTab(onOpenRequests: () => _openTab(1)),
    const RequestsTab(),
    const EarningsTab(),
    const MechanicProfileTab(),
  ];

  void _openTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        items: _items,
        onTap: _openTab,
      ),
    );
  }
}
