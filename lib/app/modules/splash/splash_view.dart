import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _logoOffset;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleOffset;
  late final Animation<double> _underlineScale;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineOffset;
  late final Animation<double> _ambientShift;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();

    _logoOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.86, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.58, curve: Curves.easeOutBack),
      ),
    );
    _logoOffset = Tween<Offset>(
      begin: const Offset(0, 22),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.58, curve: Curves.easeOutCubic),
      ),
    );
    _titleOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.28, 0.72, curve: Curves.easeOut),
    );
    _titleOffset = Tween<Offset>(
      begin: const Offset(0, 16),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.28, 0.72, curve: Curves.easeOutCubic),
      ),
    );
    _underlineScale = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.56, 0.88, curve: Curves.easeOutCubic),
    );
    _taglineOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.66, 1.0, curve: Curves.easeOut),
    );
    _taglineOffset = Tween<Offset>(
      begin: const Offset(0, 12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.66, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _ambientShift = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF6F4FF),
              Color(0xFFEDEBFF),
              Color(0xFFE6E4FF),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) {
              return Stack(
                children: [
                  Positioned(
                    top: 76 + (_ambientShift.value * 10),
                    left: -54 + (_ambientShift.value * 8),
                    child: _SoftCircle(size: 260, opacity: 0.20),
                  ),
                  Positioned(
                    right: -92 - (_ambientShift.value * 10),
                    bottom: 132 + (_ambientShift.value * 12),
                    child: _SoftCircle(size: 320, opacity: 0.26),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.translate(
                            offset: _logoOffset.value,
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: Container(
                                width: 176,
                                height: 176,
                                padding: const EdgeInsets.all(54),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.72),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.86),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primary
                                          .withValues(alpha: 0.16),
                                      blurRadius: 42,
                                      offset: const Offset(0, 24),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/images/daydesk_logo.png',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 42),
                        Opacity(
                          opacity: _titleOpacity.value,
                          child: Transform.translate(
                            offset: _titleOffset.value,
                            child: Text(
                              'DayDesk',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                    color: AppTheme.primary,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Transform.scale(
                          scaleX: _underlineScale.value,
                          child: Container(
                            width: 62,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8680E8),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 30,
                    right: 30,
                    bottom: 64,
                    child: Opacity(
                      opacity: _taglineOpacity.value,
                      child: Transform.translate(
                        offset: _taglineOffset.value,
                        child: Text(
                          'Master your time and wealth.',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0,
                                  ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  const _SoftCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: opacity * 0.7),
            blurRadius: 80,
            spreadRadius: 36,
          ),
        ],
      ),
    );
  }
}
