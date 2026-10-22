import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class FuelGasLogo extends StatelessWidget {
  final double iconSize;
  final double? fontSize;
  final bool showText;
  final bool showTagline;
  final Color textColor;
  final Color taglineColor;
  final CrossAxisAlignment alignment;

  const FuelGasLogo({
    super.key,
    this.iconSize = 48,
    this.fontSize,
    this.showText = true,
    this.showTagline = false,
    this.textColor = AppColors.primaryBlue,
    this.taglineColor = AppColors.textSecondary,
    this.alignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final double textScale = fontSize ?? (iconSize * 0.55);

    if (!showText) {
      return Image.asset(
        'assets/images/logo.png',
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFallbackFlame(iconSize),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildFallbackFlame(iconSize),
        ),
        SizedBox(height: iconSize * 0.12),
        RichText(
          textAlign: alignment == CrossAxisAlignment.center
              ? TextAlign.center
              : TextAlign.start,
          text: TextSpan(
            text: 'Fuel',
            style: GoogleFonts.plusJakartaSans(
              fontSize: textScale,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(
                text: 'Gas',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: textScale,
                  fontWeight: FontWeight.w800,
                  color: textColor == Colors.white
                      ? Colors.white
                      : (textColor == AppColors.primaryBlue
                          ? AppColors.primaryBlueDark
                          : textColor),
                ),
              ),
            ],
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            'Safe Gas. Warm Homes.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: taglineColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFallbackFlame(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF0F56D2), Color(0xFFFBBF24)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Icon(
        Icons.local_fire_department_rounded,
        size: size * 0.65,
        color: Colors.white,
      ),
    );
  }
}
