import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'driver_earnings_screen.dart';
import 'driver_jobs_screen.dart';
import 'provider_admin_inventory_screen.dart';
import 'provider_profile_screen.dart';

class ProviderMainNav extends StatefulWidget {
  const ProviderMainNav({super.key});

  @override
  State<ProviderMainNav> createState() => _ProviderMainNavState();
}

class _ProviderMainNavState extends State<ProviderMainNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DriverJobsScreen(),
    DriverEarningsScreen(),
    ProviderAdminInventoryScreen(),
    ProviderProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgSecondary,
          border: Border(top: BorderSide(color: AppColors.borderColor)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (idx) => setState(() => _currentIndex = idx),
          backgroundColor: AppColors.bgSecondary,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.brandCyan,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.navigation_outlined),
              activeIcon: Icon(Icons.navigation),
              label: 'Jobs Radar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Earnings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Depot Stock',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.badge_outlined),
              activeIcon: Icon(Icons.badge),
              label: 'Partner Info',
            ),
          ],
        ),
      ),
    );
  }
}
