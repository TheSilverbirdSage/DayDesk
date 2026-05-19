import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import 'onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: SafeArea(
        child: Obx(
          () => Stack(
            children: [
              Positioned.fill(
                bottom: 92,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _currentStep(context),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).padding.bottom + 14,
                child: _BottomAction(
                  label: controller.step.value == 3 ? 'Finish Setup' : 'Next',
                  onPressed: controller.next,
                  showDots: controller.step.value == 1,
                  activeDot: controller.step.value,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _currentStep(BuildContext context) {
    return switch (controller.step.value) {
      0 => _StepOne(controller: controller),
      1 => _StepTwo(controller: controller),
      2 => _StepThree(controller: controller),
      _ => _StepFour(controller: controller),
    };
  }
}

class _StepOne extends StatelessWidget {
  const _StepOne({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('step-one'),
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
      children: [
        _TopProgress(
          label: 'Step 1 of 4',
          step: 0,
          alignment: MainAxisAlignment.start,
          onSkip: controller.skip,
        ),
        const SizedBox(height: 22),
        Text(
          'Tell us about yourself',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
        ),
        const SizedBox(height: 34),
        const _Label('Your Name'),
        const SizedBox(height: 14),
        _OutlinedInput(
          controller: controller.nameController,
          hintText: 'Enter your full name',
        ),
        const SizedBox(height: 30),
        const _Label('Preferred Currency'),
        const SizedBox(height: 16),
        _CurrencyGrid(controller: controller),
        const SizedBox(height: 34),
        const _TipCard(
          title: 'Tip of the Day',
          body: 'Your currency choice can be updated later in settings.',
        ),
      ],
    );
  }
}

class _StepTwo extends StatelessWidget {
  const _StepTwo({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('step-two'),
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      children: [
        _BackSkipHeader(onBack: controller.back, onSkip: controller.skip),
        const SizedBox(height: 28),
        const _CenteredProgress(step: 1),
        const SizedBox(height: 22),
        Center(
          child: Text(
            'STEP 2 OF 4',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 5),
        Center(
          child: Text(
            'Set your rhythm',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w400,
                ),
          ),
        ),
        const SizedBox(height: 24),
        _GoalCard(controller: controller),
        const SizedBox(height: 24),
        Text(
          'Default Task Categories',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 14),
        _CategoryWrap(controller: controller),
        const SizedBox(height: 24),
        const _WidePhotoCard(),
      ],
    );
  }
}

class _StepThree extends StatelessWidget {
  const _StepThree({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('step-three'),
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
      children: [
        Row(
          children: [
            const Text(
              'Step 3 of 4',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: controller.skip,
              child: const Text('Skip'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: const LinearProgressIndicator(
                  value: 0.75,
                  minHeight: 7,
                  color: AppTheme.primary,
                  backgroundColor: Color(0xFFE3E8FB),
                ),
              ),
            ),
            const SizedBox(width: 24),
            const Text(
              '75% Complete',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Center(
          child: Text(
            'Plan your finances',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Set your daily limits and future goals to help us tailor your experience.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary.withValues(alpha: 0.82),
                height: 1.35,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(height: 34),
        _MoneyInputCard(
          label: 'DAILY BUDGET',
          controller: controller.dailyBudgetController,
          decimal: true,
        ),
        const SizedBox(height: 22),
        _MoneyInputCard(
          label: 'SAVINGS GOAL',
          controller: controller.savingsGoalController,
        ),
        const SizedBox(height: 42),
        const _FinanceIllustration(),
      ],
    );
  }
}

class _StepFour extends StatelessWidget {
  const _StepFour({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('step-four'),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 18),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: controller.back,
              icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
            ),
            const Spacer(),
            Container(
              width: 62,
              height: 7,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '4 of 4',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const _SecurityHero(),
        const SizedBox(height: 30),
        Text(
          'Your data, your\ncontrol',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w900,
                height: 1.2,
                letterSpacing: 0,
              ),
        ),
        const SizedBox(height: 14),
        Text(
          'Everything you create is stored\nlocally on your device, not on our\nservers.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary.withValues(alpha: 0.86),
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(height: 28),
        const _PrivacyItem(
          icon: Icons.visibility_off_outlined,
          title: 'Zero Surveillance',
          body:
              'We never track your activity or sell your personal data to third parties.',
        ),
        const SizedBox(height: 14),
        const _PrivacyItem(
          icon: Icons.enhanced_encryption_outlined,
          title: 'On-Device Encryption',
          body:
              'Your files are encrypted with military-grade keys generated right here.',
        ),
        const SizedBox(height: 14),
        const _PrivacyItem(
          icon: Icons.ios_share_rounded,
          title: 'Export Anytime',
          body:
              'Take your data with you in universal formats whenever you want.',
        ),
      ],
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.label,
    required this.onPressed,
    required this.showDots,
    required this.activeDot,
  });

  final String label;
  final VoidCallback onPressed;
  final bool showDots;
  final int activeDot;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showDots)
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.48),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.68),
                    ),
                  ),
                  child: Row(
                    children: List.generate(
                      4,
                      (index) => Container(
                        width: 9,
                        height: 9,
                        margin: const EdgeInsets.only(right: 14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == activeDot
                              ? AppTheme.primary
                              : const Color(0xFFDCE5F6),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (showDots) const SizedBox(width: 14),
        if (showDots)
          SizedBox(
            width: 158,
            height: 58,
            child: _NextButton(label: label, onPressed: onPressed),
          )
        else
          Expanded(
            child: SizedBox(
              height: 58,
              child: _NextButton(label: label, onPressed: onPressed),
            ),
          ),
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Row(
        children: [
          Expanded(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  child: Container(
                    height: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primary.withValues(alpha: 0.88),
                          AppTheme.primary.withValues(alpha: 0.68),
                          Colors.white.withValues(alpha: 0.20),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.56),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.22),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.30),
                          blurRadius: 8,
                          offset: const Offset(-4, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          label == 'Finish Setup'
                              ? Icons.check_circle_outline_rounded
                              : Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopProgress extends StatelessWidget {
  const _TopProgress({
    required this.label,
    required this.step,
    required this.onSkip,
    this.alignment = MainAxisAlignment.center,
  });

  final String label;
  final int step;
  final VoidCallback onSkip;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 12),
        ...List.generate(
          4,
          (index) => Container(
            width: 38,
            height: 7,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: index <= step ? AppTheme.primary : const Color(0xFFDCE5F6),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onSkip,
          child: const Text(
            'Skip',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _BackSkipHeader extends StatelessWidget {
  const _BackSkipHeader({required this.onBack, required this.onSkip});

  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary, size: 24),
        ),
        const Spacer(),
        TextButton(
          onPressed: onSkip,
          child: const Text(
            'Skip',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _CenteredProgress extends StatelessWidget {
  const _CenteredProgress({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => Container(
          width: 72,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: index <= step ? AppTheme.primary : const Color(0xFFDCE5F6),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _OutlinedInput extends StatelessWidget {
  const _OutlinedInput({required this.controller, required this.hintText});

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppTheme.textSecondary.withValues(alpha: 0.82),
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
              BorderSide(color: AppTheme.textSecondary.withValues(alpha: 0.35)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
              BorderSide(color: AppTheme.textSecondary.withValues(alpha: 0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
      ),
    );
  }
}

class _CurrencyGrid extends StatelessWidget {
  const _CurrencyGrid({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final symbols = {'USD': r'$', 'EUR': '€', 'GBP': '£', 'Other': '•••'};
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.currencies.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 11,
        crossAxisSpacing: 11,
        childAspectRatio: 1.65,
      ),
      itemBuilder: (context, index) {
        final currency = controller.currencies[index];
        return Obx(
          () {
            final selected = controller.selectedCurrency.value == currency;
            return InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => controller.selectCurrency(currency),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: selected ? AppTheme.primary : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    if (selected)
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        blurRadius: 10,
                      ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      symbols[currency]!,
                      style: TextStyle(
                        color:
                            selected ? AppTheme.primary : AppTheme.textPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currency,
                      style: TextStyle(
                        color:
                            selected ? AppTheme.primary : AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      padding: const EdgeInsets.fromLTRB(24, 62, 24, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFB6BDC4),
            const Color(0xFFF7F5FF).withValues(alpha: 0.94),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE6E2FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Daily Task Goal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                ),
                const Spacer(),
                Text(
                  '${controller.dailyTaskGoal.value.round()}',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 5,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 13),
                activeTrackColor: const Color(0xFFE6E9F8),
                inactiveTrackColor: const Color(0xFFE6E9F8),
                thumbColor: AppTheme.primary,
              ),
              child: Slider(
                min: 1,
                max: 15,
                divisions: 14,
                value: controller.dailyTaskGoal.value,
                onChanged: (value) => controller.dailyTaskGoal.value = value,
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Text('1',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                Spacer(),
                Text('15',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Setting a realistic goal helps maintain\nconsistent momentum.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryWrap extends StatelessWidget {
  const _CategoryWrap({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 18,
        runSpacing: 12,
        children: [
          ...controller.categoryOptions.map(
            (category) {
              final selected = controller.selectedCategories.contains(category);
              return ChoiceChip(
                label: Text(category),
                selected: selected,
                onSelected: (_) => controller.toggleCategory(category),
                selectedColor: AppTheme.primary,
                backgroundColor: Colors.white,
                side: BorderSide(
                    color: AppTheme.textSecondary.withValues(alpha: 0.32)),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32)),
              );
            },
          ),
          if (controller.isAddingCategory.value)
            SizedBox(
              width: 220,
              height: 48,
              child: TextField(
                controller: controller.categoryController,
                focusNode: controller.categoryFocusNode,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                onSubmitted: (_) => controller.addCategory(),
                decoration: InputDecoration(
                  hintText: 'Category name',
                  hintStyle: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check, color: AppTheme.primary),
                    onPressed: controller.addCategory,
                    tooltip: 'Add category',
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide(
                      color: AppTheme.textSecondary.withValues(alpha: 0.32),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: const BorderSide(color: AppTheme.primary),
                  ),
                ),
              ),
            )
          else
            ActionChip(
              onPressed: controller.showCategoryInput,
              avatar: const Icon(Icons.add, color: AppTheme.textSecondary),
              label: const Text('Add new'),
              backgroundColor: Colors.transparent,
              side: BorderSide(
                color: AppTheme.textSecondary.withValues(alpha: 0.30),
                style: BorderStyle.solid,
              ),
              labelStyle: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
            ),
        ],
      ),
    );
  }
}

class _WidePhotoCard extends StatelessWidget {
  const _WidePhotoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8D4A4), Color(0xFFC9D3E5), Color(0xFF886532)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.laptop_mac_rounded, color: Colors.white70, size: 72),
      ),
    );
  }
}

class _MoneyInputCard extends StatelessWidget {
  const _MoneyInputCard({
    required this.label,
    required this.controller,
    this.decimal = false,
  });

  final String label;
  final TextEditingController controller;
  final bool decimal;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: decimal),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixText: r'$',
              prefixStyle: TextStyle(
                color: AppTheme.primary.withValues(alpha: 0.42),
                fontSize: 17,
              ),
              filled: false,
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceIllustration extends StatelessWidget {
  const _FinanceIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.rotate(
        angle: 0.18,
        child: Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            color: const Color(0xFF102432),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.12),
                blurRadius: 38,
                spreadRadius: 18,
              ),
            ],
          ),
          child: const Icon(Icons.auto_graph_rounded,
              color: Color(0xFF73D5E5), size: 74),
        ),
      ),
    );
  }
}

class _SecurityHero extends StatelessWidget {
  const _SecurityHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.fromLTRB(20, 188, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF283642), Color(0xFFC7D5D8), Color(0xFF504D64)],
        ),
      ),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user_outlined, color: AppTheme.primary),
            SizedBox(width: 10),
            Text(
              'Advanced Security Active',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyItem extends StatelessWidget {
  const _PrivacyItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEBFA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary.withValues(alpha: 0.84),
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
