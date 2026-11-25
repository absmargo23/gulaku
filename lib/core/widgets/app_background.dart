import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

enum AppBackgroundVariant {
  normal,
  header,
  onboarding,
  alert,
  dark,
}

class AppBackground extends StatelessWidget {
  const AppBackground({
    required this.child,
    this.variant = AppBackgroundVariant.normal,
    super.key,
  });

  final Widget child;
  final AppBackgroundVariant variant;

  @override
  Widget build(BuildContext context) {
    final isDark =
        variant == AppBackgroundVariant.dark ||
        Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: _background(isDark)),
        if (variant == AppBackgroundVariant.header)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: ClipPath(
              clipper: const _HeaderWaveClipper(),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primary, AppColors.headerGradientEnd],
                  ),
                ),
              ),
            ),
          ),
        if (variant == AppBackgroundVariant.normal)
          Positioned.fill(
            child: CustomPaint(
              painter: _OrganicCurvesPainter(isDark: isDark),
            ),
          ),
        if (variant == AppBackgroundVariant.onboarding) ...[
          Positioned(
            top: 52,
            right: -42,
            child: _BlurredBlob(color: AppColors.primary.withValues(alpha: 0.07)),
          ),
          Positioned(
            top: 200,
            left: -60,
            child: _BlurredBlob(color: AppColors.onboardingBlue.withValues(alpha: 0.48)),
          ),
        ],
        if (variant == AppBackgroundVariant.dark)
          Positioned.fill(
            child: CustomPaint(
              painter: _GlowPainter(AppColors.darkAccent.withValues(alpha: 0.06)),
            ),
          ),
        child,
      ],
    );
  }

  Widget _background(bool isDark) {
    switch (variant) {
      case AppBackgroundVariant.normal:
        return _gradient(
          isDark ? AppColors.darkBackground : AppColors.background,
          isDark ? AppColors.darkSurface : AppColors.normalGradientEnd,
        );
      case AppBackgroundVariant.header:
        return ColoredBox(
          color: isDark ? AppColors.darkBackground : AppColors.background,
        );
      case AppBackgroundVariant.onboarding:
        return _gradient(
          isDark ? AppColors.darkBackground : AppColors.onboardingMint,
          isDark ? AppColors.darkSurface : AppColors.onboardingBlue,
        );
      case AppBackgroundVariant.alert:
        return _gradient(
          isDark ? AppColors.alertDarkBackground : AppColors.alertBackground,
          isDark ? AppColors.alertDarkGradientEnd : AppColors.alertGradientEnd,
        );
      case AppBackgroundVariant.dark:
        return _gradient(AppColors.darkBackground, AppColors.darkSurface);
    }
  }

  Widget _gradient(Color start, Color end) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [start, end],
        ),
      ),
    );
  }
}

class _BlurredBlob extends StatelessWidget {
  const _BlurredBlob({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: const SizedBox.square(dimension: 220),
      ),
    );
  }
}

class _HeaderWaveClipper extends CustomClipper<Path> {
  const _HeaderWaveClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - 28)
      ..cubicTo(
        size.width * 0.28,
        size.height + 5,
        size.width * 0.68,
        size.height - 48,
        size.width,
        size.height - 18,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _HeaderWaveClipper oldClipper) => false;
}

class _OrganicCurvesPainter extends CustomPainter {
  const _OrganicCurvesPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final color = isDark ? AppColors.darkAccent : AppColors.primary;
    final paint = Paint()..color = color.withValues(alpha: 0.05);
    final topCurve = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.28)
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.18,
        size.width * 0.82,
        size.height * 0.04,
        size.width,
        0,
      )
      ..close();
    final lowerCurve = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.78)
      ..cubicTo(
        size.width * 0.2,
        size.height * 0.86,
        size.width * 0.12,
        size.height * 0.97,
        0,
        size.height,
      )
      ..close();

    canvas
      ..drawPath(topCurve, paint)
      ..drawPath(lowerCurve, paint);
  }

  @override
  bool shouldRepaint(covariant _OrganicCurvesPainter oldDelegate) =>
      isDark != oldDelegate.isDark;
}

class _GlowPainter extends CustomPainter {
  const _GlowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width, 0),
      radius: size.shortestSide * 0.75,
    );
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(rect);
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) =>
      color != oldDelegate.color;
}
