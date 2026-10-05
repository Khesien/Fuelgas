import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final Color? backgroundColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 20,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'U';

    if (imageUrl != null && imageUrl!.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? AppColors.brandOrange.withOpacity(0.2),
        child: ClipOval(
          child: Image.network(
            imageUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallback(initials),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColors.brandOrange.withOpacity(0.2),
      child: _buildFallback(initials),
    );
  }

  Widget _buildFallback(String initials) {
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.75,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class ProviderLogoWidget extends StatelessWidget {
  final String? logoUrl;
  final String companyName;
  final double size;

  const ProviderLogoWidget({
    super.key,
    this.logoUrl,
    required this.companyName,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final initials = companyName.isNotEmpty
        ? companyName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'GP';

    if (logoUrl != null && logoUrl!.startsWith('http')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.brandOrange.withOpacity(0.15),
          borderRadius: BorderRadius.circular(size * 0.25),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.25),
          child: Image.network(
            logoUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallback(initials),
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.brandOrange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: _buildFallback(initials),
    );
  }

  Widget _buildFallback(String initials) {
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: AppColors.brandOrange,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
