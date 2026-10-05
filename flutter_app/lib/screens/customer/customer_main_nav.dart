import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state_provider.dart';
import 'customer_home_screen.dart';
import 'customer_profile_screen.dart';
import 'cylinder_selection_screen.dart';
import 'order_tracking_screen.dart';

class CustomerMainNav extends StatefulWidget {
  const CustomerMainNav({super.key});

  @override
  State<CustomerMainNav> createState() => _CustomerMainNavState();
}

class _CustomerMainNavState extends State<CustomerMainNav> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    final List<Widget> screens = [
      const CustomerHomeScreen(),
      const CylinderSelectionScreen(),
      state.activeTrackingOrder != null
          ? OrderTrackingScreen(order: state.activeTrackingOrder!)
          : const Center(
              child: Text(
                'No active orders right now.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
      const CustomerProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
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
          selectedItemColor: AppColors.brandOrange,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_fire_department_outlined),
              activeIcon: Icon(Icons.local_fire_department),
              label: 'Order Gas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.navigation_outlined),
              activeIcon: Icon(Icons.navigation),
              label: 'Track',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
