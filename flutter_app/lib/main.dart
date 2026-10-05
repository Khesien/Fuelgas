import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/supabase/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_state_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/common/auth_screen.dart';
import 'screens/customer/customer_main_nav.dart';
import 'screens/provider/provider_main_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // System UI styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B0F19),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Supabase (no-op if credentials not yet set)
  await SupabaseService().initialize();

  runApp(const GasDeliveryApp());
}

class GasDeliveryApp extends StatelessWidget {
  const GasDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AppRouter(),
      ),
    );
  }
}

/// Routes between AuthScreen ↔ Customer ↔ Provider/Driver
/// based on login state and role — no hardcoded routing.
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    // Show auth screen if no user is logged in
    if (!state.isLoggedIn) {
      return const AuthScreen();
    }

    // Route by role
    switch (state.activeRole) {
      case UserRole.customer:
        return const CustomerMainNav();
      case UserRole.driver:
      case UserRole.providerAdmin:
      case UserRole.superAdmin:
        return const ProviderMainNav();
    }
  }
}
