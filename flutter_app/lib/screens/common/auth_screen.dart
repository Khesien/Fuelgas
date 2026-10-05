import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/supabase/supabase_service.dart';
import '../../providers/app_state_provider.dart';
import '../common/glass_container.dart';

/// Login & Registration screen.
/// Uses Supabase Auth for real authentication — no demo accounts.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Login fields
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();

  // Register fields
  final _regFullNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPhoneCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regConfirmCtrl = TextEditingController();
  String _regRole = 'customer';

  bool _isLoading = false;
  bool _obscureLogin = true;
  bool _obscureReg = true;
  bool _obscureRegConfirm = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regFullNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPhoneCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final supabase = SupabaseService();
    if (!supabase.isReady) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Supabase is not configured. Add your SUPABASE_URL and SUPABASE_ANON_KEY to connect.';
      });
      return;
    }

    try {
      final response = await supabase.client!.auth.signInWithPassword(
        email: _loginEmailCtrl.text.trim(),
        password: _loginPasswordCtrl.text,
      );

      if (response.user != null && mounted) {
        final state = Provider.of<AppStateProvider>(context, listen: false);

        // Check if this user is a driver or customer
        final driverRow = await supabase.client!
            .from('drivers')
            .select('driver_id')
            .eq('user_id', response.user!.id)
            .maybeSingle();

        if (driverRow != null) {
          state.setActiveRole(UserRole.driver);
          await state.loadDriverData(driverRow['driver_id']);
        } else {
          state.setActiveRole(UserRole.customer);
          await state.loadUserData(response.user!.id);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _friendlyError(e.toString());
        });
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;
    if (_regPasswordCtrl.text != _regConfirmCtrl.text) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final supabase = SupabaseService();
    if (!supabase.isReady) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Supabase is not configured. Add your SUPABASE_URL and SUPABASE_ANON_KEY to connect.';
      });
      return;
    }

    try {
      final response = await supabase.client!.auth.signUp(
        email: _regEmailCtrl.text.trim(),
        password: _regPasswordCtrl.text,
      );

      if (response.user != null) {
        // Insert user profile row
        await supabase.client!.from('users').insert({
          'user_id': response.user!.id,
          'full_name': _regFullNameCtrl.text.trim(),
          'email': _regEmailCtrl.text.trim(),
          'phone': _regPhoneCtrl.text.trim(),
          'referral_code':
              'GAS${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          'referral_earnings': 0.0,
          'created_at': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          final state =
              Provider.of<AppStateProvider>(context, listen: false);
          state.setActiveRole(
              _regRole == 'driver' ? UserRole.driver : UserRole.customer);
          await state.loadUserData(response.user!.id);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created! Check your email to verify.'),
              backgroundColor: AppColors.brandGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = _friendlyError(e.toString()));
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('Invalid login credentials')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (raw.contains('User already registered')) {
      return 'An account with this email already exists.';
    }
    if (raw.contains('Email not confirmed')) {
      return 'Please verify your email before logging in.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo / Brand
              _buildBrandHeader(),
              const SizedBox(height: 40),

              // Tab bar: Login / Register
              _buildTabBar(),
              const SizedBox(height: 24),

              // Error message
              if (_errorMessage != null) _buildErrorBanner(),
              if (_errorMessage != null) const SizedBox(height: 16),

              // Forms
              SizedBox(
                height: _tabController.index == 0 ? 320 : 500,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLoginForm(),
                    _buildRegisterForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.brandOrange, AppColors.brandOrangeDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandOrange.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.local_fire_department,
              color: Colors.white, size: 38),
        ),
        const SizedBox(height: 16),
        const Text(
          'GasExpress',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'LPG Delivery Platform',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return GlassContainer(
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        onTap: (_) => setState(() => _errorMessage = null),
        indicator: BoxDecoration(
          color: AppColors.brandOrange,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        tabs: const [
          Tab(text: 'Sign In'),
          Tab(text: 'Create Account'),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.12),
        border: Border.all(color: AppColors.danger.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                  color: AppColors.danger, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _inputField(
            controller: _loginEmailCtrl,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 14),
          _inputField(
            controller: _loginPasswordCtrl,
            label: 'Password',
            icon: Icons.lock_outline,
            obscure: _obscureLogin,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureLogin ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscureLogin = !_obscureLogin),
            ),
            validator: (v) =>
                v == null || v.length < 6 ? 'Minimum 6 characters' : null,
          ),
          const SizedBox(height: 24),
          _primaryButton(
            label: 'Sign In',
            onTap: _handleLogin,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _inputField(
            controller: _regFullNameCtrl,
            label: 'Full Name',
            icon: Icons.person_outline,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter your full name' : null,
          ),
          const SizedBox(height: 12),
          _inputField(
            controller: _regEmailCtrl,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 12),
          _inputField(
            controller: _regPhoneCtrl,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter your phone number' : null,
          ),
          const SizedBox(height: 12),
          // Role selector
          GlassContainer(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.badge_outlined,
                    color: AppColors.textMuted, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _regRole,
                      dropdownColor: const Color(0xFF1A1F2E),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14),
                      onChanged: (v) =>
                          setState(() => _regRole = v ?? 'customer'),
                      items: const [
                        DropdownMenuItem(
                            value: 'customer', child: Text('Customer')),
                        DropdownMenuItem(
                            value: 'driver', child: Text('Driver / Provider')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _inputField(
            controller: _regPasswordCtrl,
            label: 'Password',
            icon: Icons.lock_outline,
            obscure: _obscureReg,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureReg ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscureReg = !_obscureReg),
            ),
            validator: (v) =>
                v == null || v.length < 6 ? 'Minimum 6 characters' : null,
          ),
          const SizedBox(height: 12),
          _inputField(
            controller: _regConfirmCtrl,
            label: 'Confirm Password',
            icon: Icons.lock_outline,
            obscure: _obscureRegConfirm,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRegConfirm ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscureRegConfirm = !_obscureRegConfirm),
            ),
            validator: (v) =>
                v == null || v.length < 6 ? 'Minimum 6 characters' : null,
          ),
          const SizedBox(height: 20),
          _primaryButton(
            label: 'Create Account',
            onTap: _handleRegister,
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandOrange,
          disabledBackgroundColor: AppColors.brandOrange.withOpacity(0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter your email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }
}
