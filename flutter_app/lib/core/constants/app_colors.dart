import 'package:flutter/material.dart';

class AppColors {
  // FuelGas Royal Blue Brand Colors
  static const Color primaryBlue = Color(0xFF0F56D2);
  static const Color primaryBlueDark = Color(0xFF0A3E99);
  static const Color primaryBlueLight = Color(0xFF2563EB);
  static const Color bannerNavyDark = Color(0xFF0A2252);
  static const Color bannerNavyLight = Color(0xFF123B7B);

  // Logo & Accent Flame Colors
  static const Color flameYellow = Color(0xFFFBBF24);
  static const Color flameAmber = Color(0xFFF59E0B);
  static const Color flameRed = Color(0xFFEF4444);
  static const Color flameBlue = Color(0xFF0F56D2);

  // Aliases for compatibility
  static const Color brandOrange = Color(0xFF0F56D2); // Primary action is now Royal Blue
  static const Color brandOrangeLight = Color(0xFF3B82F6);
  static const Color brandOrangeDark = Color(0xFF0A3E99);
  static const Color brandAmber = Color(0xFFF59E0B);
  static const Color brandCyan = Color(0xFF0284C7);
  static const Color brandGreen = Color(0xFF10B981);

  // Light Theme Backgrounds
  static const Color bgPrimary = Color(0xFFF8FAFC);
  static const Color bgSurface = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFFFFFFF);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgCardElevated = Color(0xFFFFFFFF);
  static const Color bgHeader = Color(0xFF0F56D2);

  // Quick Action Tile Backgrounds
  static const Color tileBlueBg = Color(0xFFEFF6FF);
  static const Color tileGreenBg = Color(0xFFF0FDF4);
  static const Color tileOrangeBg = Color(0xFFFFF7ED);
  static const Color tilePurpleBg = Color(0xFFF5F3FF);

  // Quick Action Tile Icon Colors
  static const Color tileBlueIcon = Color(0xFF0F56D2);
  static const Color tileGreenIcon = Color(0xFF10B981);
  static const Color tileOrangeIcon = Color(0xFFF97316);
  static const Color tilePurpleIcon = Color(0xFF8B5CF6);

  // Borders & Dividers
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderInput = Color(0xFFCBD5E1);
  static const Color borderOrange = Color(0xFF0F56D2);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status & Badges
  static const Color statusOpen = Color(0xFF10B981);
  static const Color statusOpenBg = Color(0xFFECFDF5);
  static const Color statusDelivered = Color(0xFF10B981);
  static const Color statusDeliveredBg = Color(0xFFECFDF5);
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusPendingBg = Color(0xFFFFFBEB);
  static const Color statusConfirmed = Color(0xFF0F56D2);
  static const Color statusPreparing = Color(0xFF8B5CF6);
  static const Color statusDelivery = Color(0xFF0284C7);
  static const Color statusCancelled = Color(0xFFEF4444);
  static const Color danger = Color(0xFFEF4444);
  static const Color starRating = Color(0xFFF59E0B);

  // Helpers
  static Color statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return statusConfirmed;
      case 'preparing':
        return statusPreparing;
      case 'out_for_delivery':
        return statusDelivery;
      case 'delivered':
        return statusDelivered;
      case 'cancelled':
        return statusCancelled;
      default:
        return statusPending;
    }
  }
}
