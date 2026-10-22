import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/supabase/supabase_service.dart';
import '../../providers/app_state_provider.dart';
import '../customer/customer_main_nav.dart';
import '../provider/provider_main_nav.dart';
import 'fuel_gas_logo.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignUp = false;
  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Role: 'customer' | 'driver' | 'provider_admin'
  String _selectedRole = 'customer';

  final _formKey = GlobalKey<FormState>();
  final _emailPhoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // Driver fields
  final _vehicleTypeCtrl = TextEditingController(text: 'Delivery Van');
  final _vehiclePlateCtrl = TextEditingController();
  final _driverLicenseCtrl = TextEditingController();

  // Provider fields
  final _companyNameCtrl = TextEditingController();
  final _businessLicenseCtrl = TextEditingController();

  @override
  void dispose() {
    _emailPhoneCtrl.dispose();
    _passwordCtrl.dispose();
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _vehicleTypeCtrl.dispose();
    _vehiclePlateCtrl.dispose();
    _driverLicenseCtrl.dispose();
    _companyNameCtrl.dispose();
    _businessLicenseCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final state = Provider.of<AppStateProvider>(context, listen: false);
    final supabase = SupabaseService();

    if (!supabase.isReady) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Database backend is not connected yet. Please provide your Supabase URL and Anon Key.';
      });
      return;
    }

    try {
      final email = _emailPhoneCtrl.text.trim();
      final password = _passwordCtrl.text;

      if (_isSignUp) {
        // ── SIGN UP ─────────────────────────────────────────────────────────
        final authRes = await supabase.client!.auth.signUp(
          email: email,
          password: password,
        );

        if (authRes.user == null) {
          throw Exception('Sign up failed. Please try again.');
        }

        final userId = authRes.user!.id;
        final fullName = _fullNameCtrl.text.trim();
        final phone = _phoneCtrl.text.trim();

        // 1. Insert Profile
        try {
          await supabase.client!.from('profiles').insert({
            'user_id': userId,
            'full_name': fullName,
            'email': email,
            'phone': phone,
            'role': _selectedRole,
            'referral_code':
                'FG${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
            'referral_earnings': 0.0,
          });
        } catch (e) {
          // Fallback to 'users' table if schema uses 'users'
          try {
            await supabase.client!.from('users').insert({
              'user_id': userId,
              'full_name': fullName,
              'email': email,
              'phone': phone,
              'referral_code':
                  'FG${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
              'referral_earnings': 0.0,
            });
          } catch (_) {}
        }

        // 2. Insert Driver row if registering as Driver
        if (_selectedRole == 'driver') {
          await supabase.client!.from('drivers').insert({
            'driver_id': 'drv_${userId.substring(0, 8)}',
            'user_id': userId,
            'full_name': fullName,
            'phone': phone,
            'email': email,
            'vehicle_type': _vehicleTypeCtrl.text.trim().isNotEmpty
                ? _vehicleTypeCtrl.text.trim()
                : 'Delivery Van',
            'vehicle_number': _vehiclePlateCtrl.text.trim().isNotEmpty
                ? _vehiclePlateCtrl.text.trim()
                : 'B 101 ABC',
            'license_no': _driverLicenseCtrl.text.trim().isNotEmpty
                ? _driverLicenseCtrl.text.trim()
                : 'DL-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
            'rating_avg': 5.0,
            'completed_orders': 0,
            'status': 'online',
            'current_lat': -24.6580,
            'current_lng': 25.9120,
            'verification_status': 'approved',
          });
        }

        // 3. Insert Gas Provider row if registering as Provider
        if (_selectedRole == 'provider_admin') {
          final compName = _companyNameCtrl.text.trim().isNotEmpty
              ? _companyNameCtrl.text.trim()
              : fullName;
          final slug = compName
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-z0-9]'), '-');

          try {
            await supabase.client!.from('gas_providers').insert({
              'provider_id': 'prov_${userId.substring(0, 8)}',
              'company_name': compName,
              'slug': slug,
              'logo_url': 'assets/images/cylinder.jpg',
              'description': 'Certified LPG Gas Depot',
              'rating': 5.0,
              'review_count': 0,
              'districts_served': ['Gaborone, Botswana', 'Gaborone Central', 'Gaborone West'],
              'compliance_status': 'approved',
              'license_number': _businessLicenseCtrl.text.trim().isNotEmpty
                  ? _businessLicenseCtrl.text.trim()
                  : 'LPG-BW-${DateTime.now().year}-01',
              'contact_phone': phone,
              'contact_email': email,
              'base_delivery_fee': 25.0,
              'est_delivery_mins': 30,
            });
          } catch (_) {
            try {
              await supabase.client!.from('providers').insert({
                'provider_id': 'prov_${userId.substring(0, 8)}',
                'company_name': compName,
                'slug': slug,
                'logo_url': 'assets/images/cylinder.jpg',
                'description': 'Certified LPG Gas Depot',
                'rating': 5.0,
                'review_count': 0,
                'districts_served': ['Gaborone, Botswana', 'Gaborone Central', 'Gaborone West'],
                'compliance_status': 'approved',
                'license_number': _businessLicenseCtrl.text.trim().isNotEmpty
                    ? _businessLicenseCtrl.text.trim()
                    : 'LPG-BW-${DateTime.now().year}-01',
                'contact_phone': phone,
                'contact_email': email,
                'base_delivery_fee': 25.0,
                'est_delivery_mins': 30,
              });
            } catch (_) {}
          }
        }

        await state.loadUserData(userId);
        _routeAfterAuth(state);
      } else {
        // ── SIGN IN ─────────────────────────────────────────────────────────
        final authRes = await supabase.client!.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (authRes.user != null) {
          await state.loadUserData(authRes.user!.id);
          _routeAfterAuth(state);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _cleanErrorMessage(e.toString());
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final supabase = SupabaseService();
    if (!supabase.isReady) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Database backend is not connected yet. Please provide your Supabase URL and Anon Key.';
      });
      return;
    }

    try {
      final success = await supabase.client!.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.gasdelivery://login-callback',
      );

      if (!success) {
        setState(() {
          _errorMessage = 'Could not start Google Sign-In.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _cleanErrorMessage(e.toString());
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _routeAfterAuth(AppStateProvider state) {
    if (!mounted) return;
    if (state.activeRole == UserRole.driver ||
        state.activeRole == UserRole.providerAdmin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProviderMainNav()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CustomerMainNav()),
      );
    }
  }

  String _cleanErrorMessage(String raw) {
    if (raw.contains('Invalid login credentials')) {
      return 'Incorrect email or password. Please check and try again.';
    }
    if (raw.contains('User already registered')) {
      return 'An account with this email already exists. Please log in.';
    }
    if (raw.contains('Password should be at least')) {
      return 'Password should be at least 6 characters.';
    }
    return raw.replaceFirst('Exception: ', '').replaceFirst('AuthApiException: ', '');
  }

  @override
  Widget build(BuildContext context) {
    final supabase = SupabaseService();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),

                  // Top FuelGas Flame Logo + Brand Header
                  const Center(
                    child: FuelGasLogo(
                      iconSize: 68,
                      fontSize: 30,
                      showTagline: true,
                      textColor: AppColors.primaryBlue,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Headline & Subtitle
                  Text(
                    _isSignUp ? 'Create Account' : 'Welcome Back',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isSignUp
                        ? 'Register as Customer, Driver, or Gas Provider'
                        : 'Login to your account',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Supabase connection warning banner if keys not set
                  if (!supabase.isReady) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppColors.primaryBlue, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Awaiting Supabase URL & Anon Key to connect to live database.',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.primaryBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── ROLE SELECTOR (SIGN UP ONLY) ──────────────────────────
                  if (_isSignUp) ...[
                    Text(
                      'I WANT TO REGISTER AS:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildRoleOption('customer', 'Customer', Icons.person_outline),
                        const SizedBox(width: 8),
                        _buildRoleOption('driver', 'Driver', Icons.local_shipping_outlined),
                        const SizedBox(width: 8),
                        _buildRoleOption('provider_admin', 'Provider', Icons.storefront_outlined),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Full Name Field
                    TextFormField(
                      controller: _fullNameCtrl,
                      validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'Please enter your name' : null,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline_rounded,
                            color: AppColors.textMuted, size: 20),
                        hintText: _selectedRole == 'provider_admin'
                            ? 'Manager / Contact Name'
                            : 'Full Name',
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Phone Number Field
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'Please enter your phone number' : null,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone_outlined,
                            color: AppColors.textMuted, size: 20),
                        hintText: 'Phone Number (e.g. +267 77 123 456)',
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Driver-specific fields
                    if (_selectedRole == 'driver') ...[
                      TextFormField(
                        controller: _vehicleTypeCtrl,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.directions_car_outlined,
                              color: AppColors.textMuted, size: 20),
                          hintText: 'Vehicle Type (e.g. Delivery Van, Bakkie)',
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _vehiclePlateCtrl,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.numbers_outlined,
                              color: AppColors.textMuted, size: 20),
                          hintText: 'Vehicle License Plate (e.g. B 101 ABC)',
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _driverLicenseCtrl,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.badge_outlined,
                              color: AppColors.textMuted, size: 20),
                          hintText: "Driver's License Number",
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Provider-specific fields
                    if (_selectedRole == 'provider_admin') ...[
                      TextFormField(
                        controller: _companyNameCtrl,
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? 'Please enter your company/depot name'
                            : null,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.business_outlined,
                              color: AppColors.textMuted, size: 20),
                          hintText: 'Gas Company / Depot Name',
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _businessLicenseCtrl,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.verified_outlined,
                              color: AppColors.textMuted, size: 20),
                          hintText: 'LPG / Energy License Number',
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],

                  // Email or Phone Number Field
                  TextFormField(
                    controller: _emailPhoneCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please enter your email';
                      if (!val.contains('@')) return 'Please enter a valid email';
                      return null;
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.mail_outline_rounded,
                          color: AppColors.textMuted, size: 20),
                      hintText: 'Email address',
                      fillColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Password Field
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Please enter a password';
                      if (val.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline_rounded,
                          color: AppColors.textMuted, size: 20),
                      hintText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      fillColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Remember Me & Forgot Password Row
                  if (!_isSignUp) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppColors.primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _rememberMe = val ?? true;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remember me',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password reset instructions will be sent to your email.'),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Primary Action Button (Log In / Sign Up)
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleEmailAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _isSignUp
                                  ? (_selectedRole == 'driver'
                                      ? 'Register as Driver'
                                      : _selectedRole == 'provider_admin'
                                          ? 'Register Gas Depot'
                                          : 'Sign Up')
                                  : 'Log In',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // "or" divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AppColors.borderColor, thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: Text(
                          'or',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AppColors.borderColor, thickness: 1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Continue with Google Button (Full OAuth integration)
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _handleGoogleAuth,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildGoogleGLogo(),
                          const SizedBox(width: 12),
                          Text(
                            _isSignUp ? 'Sign up with Google' : 'Continue with Google',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Sign up / Log in footer toggle
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                          _errorMessage = null;
                        });
                      },
                      child: RichText(
                        text: TextSpan(
                          text: _isSignUp
                              ? 'Already have an account? '
                              : "Don't have an account? ",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: _isSignUp ? 'Log In' : 'Sign Up',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(String role, String label, IconData icon) {
    final isSelected = _selectedRole == role;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedRole = role),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.tileBlueBg : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : AppColors.borderColor,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primaryBlue : AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleGLogo() {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Center(
        child: Text(
          'G',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: const Color(0xFF4285F4),
          ),
        ),
      ),
    );
  }
}
