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
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryGreen, Color(0xFF004D28)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset('assets/images/Dépensia_logo.png'),
        ),
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

class _WalletPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Wallet Body (White)
    final walletPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final walletPath = Path()
      ..moveTo(w * 0.15, h * 0.25)
      ..lineTo(w * 0.85, h * 0.25)
      ..cubicTo(w * 0.95, h * 0.25, w * 0.95, h * 0.85, w * 0.85, h * 0.85)
      ..lineTo(w * 0.15, h * 0.85)
      ..cubicTo(w * 0.05, h * 0.85, w * 0.05, h * 0.25, w * 0.15, h * 0.25)
      ..close();

    canvas.drawPath(walletPath, walletPaint);

    // 2. Wallet Top Flap Curve
    final flapPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final flapPath = Path()
      ..moveTo(w * 0.2, h * 0.35)
      ..cubicTo(w * 0.4, h * 0.15, w * 0.6, h * 0.15, w * 0.8, h * 0.35);

    canvas.drawPath(flapPath, flapPaint);

    // 3. Cameroon Red Swoosh Band across bottom
    final redPaint = Paint()
      ..color = AppColors.accentRed
      ..style = PaintingStyle.fill;

    final redPath = Path()
      ..moveTo(w * 0.05, h * 0.55)
      ..cubicTo(w * 0.3, h * 0.4, w * 0.7, h * 0.5, w * 0.95, h * 0.45)
      ..lineTo(w * 0.95, h * 0.65)
      ..cubicTo(w * 0.7, h * 0.7, w * 0.3, h * 0.6, w * 0.05, h * 0.75)
      ..close();

    canvas.drawPath(redPath, redPaint);

    // 4. Yellow Star on the Red Swoosh ⭐
    final starPaint = Paint()
      ..color = AppColors.yellowEnergy
      ..style = PaintingStyle.fill;

    final starCenter = Offset(w * 0.45, h * 0.56);
    final starRadius = w * 0.08;
    final starPath = Path();

    for (int i = 0; i < 5; i++) {
      final double x1 = starCenter.dx + starRadius * cos((18 + i * 72) * pi / 180);
      final double y1 = starCenter.dy - starRadius * sin((18 + i * 72) * pi / 180);
      final double x2 = starCenter.dx + (starRadius * 0.4) * cos((54 + i * 72) * pi / 180);
      final double y2 = starCenter.dy - (starRadius * 0.4) * sin((54 + i * 72) * pi / 180);

      if (i == 0) {
        starPath.moveTo(x1, y1);
      } else {
        starPath.lineTo(x1, y1);
      }
      starPath.lineTo(x2, y2);
    }
    starPath.close();
    canvas.drawPath(starPath, starPaint);

    // 5. Ascending Yellow Bars (Graph) at the bottom right
    final barPaint = Paint()
      ..color = AppColors.yellowEnergy
      ..style = PaintingStyle.fill;

    final barWidth = w * 0.06;
    final barSpacing = w * 0.03;
    final double startX = w * 0.55;

    final barHeights = [h * 0.12, h * 0.20, h * 0.28];

    for (int i = 0; i < barHeights.length; i++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          startX + i * (barWidth + barSpacing),
          h * 0.85 - barHeights[i],
          barWidth,
          barHeights[i],
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

double cos(double radians) => SystemMath.cos(radians);
double sin(double radians) => SystemMath.sin(radians);

class SystemMath {
  static double cos(double rad) => double.parse(rad.toString()) == 0 ? 1 : MathHelper.cos(rad);
  static double sin(double rad) => MathHelper.sin(rad);
}

class MathHelper {
  static double cos(double rad) => _cos(rad);
  static double sin(double rad) => _sin(rad);

  static double _cos(double x) {
    x = x % (2 * 3.141592653589793);
    double res = 1.0;
    double term = 1.0;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      res += term;
    }
    return res;
  }

  static double _sin(double x) {
    x = x % (2 * 3.141592653589793);
    double res = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      res += term;
    }
    return res;
  }
}

const double pi = 3.141592653589793;
