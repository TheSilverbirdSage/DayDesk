import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import 'quick_entry_sheet.dart';

class DashboardScaffold extends StatelessWidget {
  const DashboardScaffold({
    super.key,
    required this.activeRoute,
    required this.child,
  });

  final String activeRoute;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return Scaffold(
      extendBody: true,
      body: child,
      floatingActionButton: FloatingActionButton(
        backgroundColor: isDark ? const Color(0xFF8B8CF6) : AppTheme.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () => QuickEntrySheet.show(),
        child: const Icon(Icons.add_circle_outline_rounded, size: 34),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 74,
        color: AppTheme.navSurface(context),
        elevation: 12,
        shadowColor: isDark
            ? Colors.black.withValues(alpha: 0.35)
            : Colors.black.withValues(alpha: 0.10),
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                route: AppRoutes.home,
                activeRoute: activeRoute,
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.check_circle_outline_rounded,
                activeIcon: Icons.check_circle_rounded,
                label: 'Tasks',
                route: AppRoutes.tasks,
                activeRoute: activeRoute,
              ),
            ),
            const SizedBox(width: 76),
            Expanded(
              child: _NavItem(
                icon: Icons.payments_outlined,
                activeIcon: Icons.payments_rounded,
                label: 'Finance',
                route: AppRoutes.finance,
                activeRoute: activeRoute,
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.bar_chart_rounded,
                activeIcon: Icons.bar_chart_rounded,
                label: 'Charts',
                route: AppRoutes.charts,
                activeRoute: activeRoute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.activeRoute,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final String activeRoute;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final isActive = route == activeRoute;
    final activeColor = isDark ? const Color(0xFFB4B5FF) : AppTheme.primary;
    final color = isActive
        ? activeColor
        : AppTheme.secondaryText(context).withValues(alpha: 0.72);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: isActive ? null : () => Get.offNamed(route),
      child: SizedBox(
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: isActive ? 40 : 32,
              height: 30,
              decoration: BoxDecoration(
                color: isActive
                    ? activeColor.withValues(alpha: isDark ? 0.16 : 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 1, end: isActive ? 1.08 : 1),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: color,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                color: color,
                fontSize: isActive ? 12.4 : 12,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              ),
              child: Text(label, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }
}
