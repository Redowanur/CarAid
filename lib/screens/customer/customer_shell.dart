import 'package:flutter/material.dart';

import '../../widgets/app_nav_bar.dart';
import 'activity_tab.dart';
import 'home_tab.dart';
import 'mechanics_tab.dart';
import 'profile_tab.dart';

class CustomerShell extends StatefulWidget {
  final int initialTab;

  const CustomerShell({super.key, this.initialTab = 0});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialTab.clamp(0, 3);
  }

  static const _items = [
    NavItemData(Icons.home_outlined, Icons.home_rounded, 'Home'),
    NavItemData(Icons.handyman_outlined, Icons.handyman_rounded, 'Mechanics'),
    NavItemData(Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Jobs'),
    NavItemData(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  late final List<Widget> _pages = [
    HomeTab(onOpenMechanics: () => _openTab(1)),
    const MechanicsTab(),
    const ActivityTab(),
    const ProfileTab(),
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
