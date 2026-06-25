import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../dashboard/widgets/dashboard_scaffold.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      activeRoute: AppRoutes.settings,
      child: SafeArea(
        bottom: false,
        child: Obx(
          () => ListView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 112),
            children: [
              _SettingsHeader(isDark: controller.isDarkMode.value),
              const SizedBox(height: 24),
              _SectionCard(
                title: 'Profile',
                icon: Icons.person_rounded,
                children: [
                  _SettingsTextField(
                    label: 'Your Name',
                    controller: controller.nameController,
                    hintText: 'Enter your full name',
                  ),
                  const SizedBox(height: 18),
                  _CurrencySelector(controller: controller),
                ],
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: 'Planning',
                icon: Icons.check_circle_rounded,
                children: [
                  _TaskGoalSlider(controller: controller),
                  const SizedBox(height: 22),
                  const _FieldLabel('Default Task Categories'),
                  const SizedBox(height: 12),
                  _CategoryWrap(controller: controller),
                ],
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: 'Finance',
                icon: Icons.payments_rounded,
                children: [
                  _SettingsTextField(
                    label: 'Daily Budget',
                    controller: controller.dailyBudgetController,
                    hintText: '45.00',
                    prefixText: r'$',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SettingsTextField(
                    label: 'Savings Goal',
                    controller: controller.savingsGoalController,
                    hintText: '2500',
                    prefixText: r'$',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: 'Appearance',
                icon: Icons.dark_mode_rounded,
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: controller.isDarkMode.value,
                    onChanged: controller.updateDarkMode,
                    activeThumbColor: AppTheme.primaryAccent(context),
                    activeTrackColor:
                        AppTheme.primaryAccent(context).withValues(alpha: 0.28),
                    title: Text(
                      'Dark Mode',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    secondary: Icon(
                      controller.isDarkMode.value
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: AppTheme.primaryAccent(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              ElevatedButton.icon(
                onPressed: controller.saveSettings,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Save Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final foreground = isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary;
    final secondary =
        isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;

    return Row(
      children: [
        IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back_rounded, color: foreground),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'Edit your DayDesk preferences',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: secondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.darkCardBackground : Colors.white;
    final foreground = isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryAccent(context),
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsTextField extends StatelessWidget {
  const _SettingsTextField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.prefixText,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final String? prefixText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: TextInputAction.next,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hintText,
            prefixText: prefixText,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  const _CurrencySelector({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Preferred Currency'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: controller.currencies.map(
            (currency) {
              final selected = controller.selectedCurrency.value == currency;
              return ChoiceChip(
                label: Text(currency),
                selected: selected,
                onSelected: (_) => controller.selectCurrency(currency),
                selectedColor: AppTheme.primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : null,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}

class _TaskGoalSlider extends StatelessWidget {
  const _TaskGoalSlider({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: _FieldLabel('Daily Task Goal')),
            Text(
              '${controller.dailyTaskGoal.value.round()} tasks',
              style: TextStyle(
                color: AppTheme.primaryAccent(context),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        Slider(
          min: 1,
          max: 15,
          divisions: 14,
          value: controller.dailyTaskGoal.value,
          onChanged: controller.updateTaskGoal,
        ),
      ],
    );
  }
}

class _CategoryWrap extends StatelessWidget {
  const _CategoryWrap({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...controller.categoryOptions.map(
          (category) {
            final selected = controller.selectedCategories.contains(category);
            return ChoiceChip(
              label: Text(category),
              selected: selected,
              onSelected: (_) => controller.toggleCategory(category),
              selectedColor: AppTheme.primary,
              labelStyle: TextStyle(
                color: selected ? Colors.white : null,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            );
          },
        ),
        if (controller.isAddingCategory.value)
          SizedBox(
            width: 210,
            height: 48,
            child: TextField(
              controller: controller.categoryController,
              focusNode: controller.categoryFocusNode,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => controller.addCategory(),
              decoration: InputDecoration(
                hintText: 'Category name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check_rounded),
                  onPressed: controller.addCategory,
                  tooltip: 'Add category',
                ),
              ),
            ),
          )
        else
          ActionChip(
            onPressed: controller.showCategoryInput,
            avatar: const Icon(Icons.add_rounded),
            label: const Text('Add new'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
      ],
    );
  }
}
