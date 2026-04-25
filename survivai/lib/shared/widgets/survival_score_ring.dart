import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/models/user_model.dart';

class SurvivalScoreRing extends StatefulWidget {
  final int days;
  final SurvivalBand band;
  final double size;

  const SurvivalScoreRing({
    super.key,
    required this.days,
    required this.band,
    this.size = 180,
  });

  @override
  State<SurvivalScoreRing> createState() => _SurvivalScoreRingState();
}

class _SurvivalScoreRingState extends State<SurvivalScoreRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _bandColor {
    switch (widget.band) {
      case SurvivalBand.green:
        return AppColors.survivalGreen;
      case SurvivalBand.amber:
        return AppColors.survivalAmber;
      case SurvivalBand.red:
        return AppColors.survivalRed;
    }
  }

  double get _progress {
    if (widget.days >= 30) return 1.0;
    return widget.days / 30.0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (_, __) => CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _RingPainter(
                progress: _progress * _animation.value,
                color: _bandColor,
                backgroundColor: _bandColor.withOpacity(0.12),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.days}',
                style: AppTypography.headlineXl.copyWith(
                  color: _bandColor,
                  fontSize: widget.size * 0.24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'DAYS',
                style: AppTypography.labelCaps.copyWith(
                  color: _bandColor.withOpacity(0.7),
                  fontSize: widget.size * 0.065,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _RingPainter({required this.progress, required this.color, required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.08;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      2 * 3.14159 * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
