import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class DepensiaLogoWidget extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showTagline;

  const DepensiaLogoWidget({
    super.key,
    this.size = 120,
    this.showText = true,
    this.showTagline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/Dépensia_logo.png', height: size),
        if (showText) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Dépensia",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.yellowEnergy,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
        if (showTagline) ...[
          const SizedBox(height: 4),
          const Text(
            "Gérez • Analysez • Atteignez vos objectifs",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

