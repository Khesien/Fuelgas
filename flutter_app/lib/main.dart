import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/supabase/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_state_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/customer/customer_main_nav.dart';
import 'screens/provider/provider_main_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B0F19),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Supabase if credentials are configured
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
        home: const RoleRouterScreen(),
      ),
    );
  }
}

/// Routes dynamically based on the active role selected by user
class RoleRouterScreen extends StatelessWidget {
  const RoleRouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

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
