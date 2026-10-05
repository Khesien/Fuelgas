import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color brandOrange = Color(0xFFFF6B00);
  static const Color brandOrangeLight = Color(0xFFFF8833);
  static const Color brandOrangeDark = Color(0xFFD95B00);
  static const Color brandAmber = Color(0xFFFFB703);
  static const Color brandCyan = Color(0xFF00F0FF);
  static const Color brandGreen = Color(0xFF22C55E);

  // Backgrounds - Modern Vibrant Dark Theme
  static const Color bgPrimary = Color(0xFF0B0F19);
  static const Color bgSecondary = Color(0xFF131B2E);
  static const Color bgCard = Color(0xFF172036);
  static const Color bgCardElevated = Color(0xFF1E2945);

  // Border & Glows
  static const Color borderColor = Color(0x1FFFFFFF); // 12% white
  static const Color borderLight = Color(0x33FFFFFF);
  static const Color borderOrange = Color(0x4DFF6B00);

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDark = Color(0xFF0F172A);

  // Status Colors
  static const Color statusPending = Color(0xFFFFB703);
  static const Color statusConfirmed = Color(0xFF00F0FF);
  static const Color statusPreparing = Color(0xFFA855F7);
  static const Color statusDelivery = Color(0xFFFF8833);
  static const Color statusDelivered = Color(0xFF4ADE80);
  static const Color statusCancelled = Color(0xFFF87171);

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
