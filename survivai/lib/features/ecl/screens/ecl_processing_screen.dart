import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class EclProcessingScreen extends StatefulWidget {
  const EclProcessingScreen({super.key});

  @override
  State<EclProcessingScreen> createState() => _EclProcessingScreenState();
}

class _EclProcessingScreenState extends State<EclProcessingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _progressCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _progressAnim;
  int _currentStep = 0;
  final List<String> _steps = [
    'Connecting to TNG data...',
    'Analysing 90-day transaction history...',
    'Calling CTOS thin-file API...',
    'Running credit scoring model...',
    'Generating SHAP explainability...',
    'Decision ready!',
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..forward();
    _progressAnim = CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut);

    _advanceSteps();
  }

  void _advanceSteps() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(Duration(milliseconds: i == _steps.length - 1 ? 800 : 900));
      if (mounted) setState(() => _currentStep = i);
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) context.go('/ecl/result');
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing ring
              ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.secondary, width: 3),
                  ),
                  child: const Center(
                    child: Icon(Icons.psychology_rounded, color: AppColors.secondary, size: 60),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Text(
                'AI Credit Assessment',
                style: AppTypography.headlineMd.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Our model is analysing your financial profile using TNG behavioural data + CTOS signals.',
                style: AppTypography.bodyBase.copyWith(color: Colors.white.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Progress bar
              AnimatedBuilder(
                animation: _progressAnim,
                builder: (_, __) => Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _progressAnim.value,
                        backgroundColor: Colors.white.withOpacity(0.15),
                        valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_progressAnim.value * 100).toInt()}%',
                      style: AppTypography.bodyBold.copyWith(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Steps
              ...List.generate(_steps.length, (i) {
                final isDone = i < _currentStep;
                final isCurrent = i == _currentStep;
                return AnimatedOpacity(
                  opacity: i <= _currentStep ? 1.0 : 0.3,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isDone ? AppColors.survivalGreen : (isCurrent ? AppColors.secondary : Colors.white.withOpacity(0.2)),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDone ? Icons.check_rounded : Icons.circle,
                            color: isDone ? Colors.white : (isCurrent ? AppColors.primary : Colors.transparent),
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _steps[i],
                          style: AppTypography.bodyBase.copyWith(
                            color: isCurrent ? AppColors.secondary : Colors.white.withOpacity(0.8),
                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
