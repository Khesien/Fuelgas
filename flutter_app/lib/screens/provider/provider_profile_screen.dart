import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../common/app_avatar.dart';
import '../common/glass_container.dart';
import '../common/role_switch_sheet.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final driver = state.activeDriver;
    final provider = state.selectedProvider;

    if (driver == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Partner Profile',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          actions: [
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => const RoleSwitchSheet(),
                );
              },
              icon: const Icon(Icons.swap_horiz, color: AppColors.brandCyan),
            ),
          ],
        ),
        body: const Center(
          child: Text(
            'No driver profile loaded.\nPlease log in or register as a driver.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final companyName = provider?.companyName ?? 'GasExpress Partner';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Profile',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => const RoleSwitchSheet(),
              );
            },
            icon: const Icon(Icons.swap_horiz, color: AppColors.brandCyan),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    AppAvatar(
                      name: driver.fullName,
                      imageUrl: driver.photoUrl,
                      radius: 30,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Associated with $companyName',
                            style: const TextStyle(
                              color: AppColors.brandOrange,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${driver.vehicleType} (${driver.vehicleNumber})',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Verification & License Status
              const Text(
                'VERIFICATION & ACCREDITATION',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDocTile('Driver License No.', driver.licenseNo, true),
                    const Divider(color: AppColors.borderColor, height: 18),
                    _buildDocTile('LPG Transport Permit', driver.verificationStatus == 'approved' ? 'Verified ✓' : 'Pending Verification', driver.verificationStatus == 'approved'),
                    const Divider(color: AppColors.borderColor, height: 18),
                    _buildDocTile('Vehicle Roadworthiness', 'See depot admin for certificate', true),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Payout Wallet Destination
              const Text(
                'DIRECT PAYOUT SETTINGS',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet,
                        color: AppColors.brandCyan, size: 24),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mobile Wallet',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            driver.phone.isNotEmpty ? driver.phone : 'No payout number set',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Edit',
                          style: TextStyle(color: AppColors.brandOrange)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocTile(String title, String val, bool verified) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 2),
            Text(val,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        if (verified)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.brandGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Icon(Icons.check, color: AppColors.brandGreen, size: 12),
                SizedBox(width: 4),
                Text(
                  'VERIFIED',
                  style: TextStyle(
                      color: AppColors.brandGreen,
                      fontSize: 9,
                      fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
