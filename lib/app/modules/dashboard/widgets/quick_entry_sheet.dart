import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/onboarding_service.dart';

class QuickEntryController extends GetxController {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final notesController = TextEditingController();

  final entryType = 'Task'.obs;
  final category = 'Work'.obs;
  final dueDate = Rxn<DateTime>();
  final selectedTime = Rxn<TimeOfDay>();
  final isUrgent = false.obs;

  final financeCategories = const [
    'Food & Drinks',
    'Transport',
    'Housing',
    'Income',
    'General',
  ];

  List<String> get categories {
    if (entryType.value == 'Finance') return financeCategories;

    final onboardingCategories = Get.isRegistered<OnboardingService>()
        ? Get.find<OnboardingService>().categories
        : const <String>[];
    final values = <String>{
      'Consistent',
      ...onboardingCategories.where((item) => item.trim().isNotEmpty),
      'Urgent',
    }.toList();
    return values.isEmpty ? const ['Consistent', 'Work', 'Urgent'] : values;
  }

  void selectEntryType(String value) {
    entryType.value = value;
    category.value = categories.first;
    isUrgent.value = false;
  }

  String get formattedDueDate {
    final date = dueDate.value;
    if (date == null) return 'mm/dd/yyyy';
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day/${date.year}';
  }

  String get formattedSelectedTime {
    final time = selectedTime.value;
    if (time == null) return '--:--';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: dueDate.value ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primary,
                  secondary: AppTheme.accent,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      dueDate.value = picked;
    }
  }

  Future<void> pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: Get.context!,
      initialTime: selectedTime.value ?? now,
    );

    if (picked != null) {
      selectedTime.value = picked;
    }
  }

  Future<void> saveEntry() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar('Missing title', 'Add a title before saving.');
      return;
    }

    if (entryType.value == 'Finance') {
      await _saveFinanceEntry(title);
      return;
    }

    final isTaskUrgent = isUrgent.value || category.value == 'Urgent';
    DateTime? scheduledDateTime;
    if (dueDate.value != null && selectedTime.value != null) {
      final date = dueDate.value!;
      final time = selectedTime.value!;
      scheduledDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    }

    await Get.find<LocalStorageService>().addTask(
      title: title,
      section:
          isTaskUrgent ? 'Urgent' : _taskSectionFromCategory(category.value),
      time: dueDate.value == null ? 'Today' : formattedDueDate,
      iconCodePoint: Icons.event_rounded.codePoint,
      priority: isTaskUrgent ? 'High Priority' : null,
      notes: notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
      isUrgent: isTaskUrgent,
      isConsistent: category.value == 'Consistent',
      dueDate: dueDate.value ?? DateTime.now(),
      scheduledAt: scheduledDateTime,
    );

    Get.back<void>();
    await Future<void>.delayed(Duration.zero);
    Get.snackbar('Task added', '$title was added to your tasks.');
  }

  Future<void> _saveFinanceEntry(String title) async {
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      Get.snackbar('Missing amount', 'Add a transaction amount before saving.');
      return;
    }

    final signedAmount = category.value == 'Income' ? amount : -amount;
    final style = _financeStyleForCategory(category.value);

    await Get.find<LocalStorageService>().addFinanceActivity(
      title: title,
      category: category.value,
      amount: signedAmount,
      iconCodePoint: style.iconCodePoint,
      iconColorValue: style.iconColorValue,
      backgroundColorValue: style.backgroundColorValue,
      notes: notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
      occurredAt: dueDate.value,
    );

    Get.back<void>();
    await Future<void>.delayed(Duration.zero);
    Get.snackbar('Transaction added', '$title was added to your finances.');
  }

  String _taskSectionFromCategory(String category) {
    if (category == 'Work & Career') return 'Work';
    return category;
  }

  _FinanceEntryStyle _financeStyleForCategory(String category) {
    return switch (category) {
      'Income' => const _FinanceEntryStyle(0xe57d, 0xFF087A45, 0xFFE9FBEF),
      'Transport' => const _FinanceEntryStyle(0xe530, 0xFF1F54D9, 0xFFEFF3FF),
      'Food & Drinks' =>
        const _FinanceEntryStyle(0xe532, 0xFFFF6B00, 0xFFFFF2E5),
      'Housing' => const _FinanceEntryStyle(0xe88a, 0xFF1877F2, 0xFFEAF4FF),
      _ => const _FinanceEntryStyle(0xe227, 0xFF2D2B8F, 0xFFEDEBFA),
    };
  }

  @override
  void onClose() {
    titleController.dispose();
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }
}

class QuickEntrySheet extends GetView<QuickEntryController> {
  const QuickEntrySheet({super.key});

  static Future<T?> show<T>() {
    Get.put(QuickEntryController());
    return Get.bottomSheet<T>(
      const QuickEntrySheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    ).whenComplete(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isRegistered<QuickEntryController>()) {
          Get.delete<QuickEntryController>();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.58,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(42)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 72,
                height: 7,
                decoration: BoxDecoration(
                  color: AppTheme.isDark(context)
                      ? Colors.white.withValues(alpha: 0.16)
                      : const Color(0xFFDCE5F6),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    15,
                    20,
                    MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  children: [
                    _SheetHeader(controller: controller),
                    const SizedBox(height: 26),
                    _EntryTypeSelector(controller: controller),
                    const SizedBox(height: 40),
                    const _FieldLabel('WHAT NEEDS TO BE DONE?'),
                    const SizedBox(height: 18),
                    _SoftTextField(
                      controller: controller.titleController,
                      hintText: 'Task title or expense name',
                    ),
                    const SizedBox(height: 34),
                    const _FieldLabel('CATEGORY'),
                    const SizedBox(height: 18),
                    _CategoryField(controller: controller),
                    const SizedBox(height: 34),
                    const _FieldLabel('DUE DATE'),
                    const SizedBox(height: 18),
                    _DueDateField(controller: controller),
                    const SizedBox(height: 18),
                    const _FieldLabel('TIME'),
                    const SizedBox(height: 18),
                    _TimeField(controller: controller),
                    const SizedBox(height: 34),
                    _AmountBox(controller: controller),
                    const SizedBox(height: 34),
                    const _FieldLabel('ADDITIONAL NOTES'),
                    const SizedBox(height: 18),
                    _SoftTextField(
                      controller: controller.notesController,
                      hintText: 'Notes',
                      minLines: 2,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              _SaveFooter(controller: controller),
            ],
          ),
        );
      },
    );
  }
}

class _FinanceEntryStyle {
  const _FinanceEntryStyle(
    this.iconCodePoint,
    this.iconColorValue,
    this.backgroundColorValue,
  );

  final int iconCodePoint;
  final int iconColorValue;
  final int backgroundColorValue;
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.controller});

  final QuickEntryController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () => Get.back<void>(),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: AppTheme.primaryAccent(context),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            'New Entry',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.primaryText(context),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
          ),
        ),
        const SizedBox(width: 76),
      ],
    );
  }
}

class _EntryTypeSelector extends StatelessWidget {
  const _EntryTypeSelector({required this.controller});

  final QuickEntryController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        height: 65,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: AppTheme.softFill(context),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: _TypeButton(
                label: 'TASK',
                icon: Icons.check_circle_outline_rounded,
                selected: controller.entryType.value == 'Task',
                onTap: () => controller.selectEntryType('Task'),
              ),
            ),
            Expanded(
              child: _TypeButton(
                label: 'FINANCE',
                icon: Icons.payments_outlined,
                selected: controller.entryType.value == 'Finance',
                onTap: () => controller.selectEntryType('Finance'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(19),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppTheme.surface(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected
                  ? AppTheme.primaryAccent(context)
                  : AppTheme.secondaryText(context),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? AppTheme.primaryAccent(context)
                    : AppTheme.secondaryText(context),
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppTheme.secondaryText(context),
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _SoftTextField extends StatelessWidget {
  const _SoftTextField({
    required this.controller,
    required this.hintText,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      style: TextStyle(
        color: AppTheme.primaryText(context),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppTheme.secondaryText(context).withValues(alpha: 0.40),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: AppTheme.softFill(context).withValues(alpha: 0.72),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.2),
        ),
      ),
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({required this.controller});

  final QuickEntryController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final categories = controller.categories;
        if (!categories.contains(controller.category.value)) {
          controller.category.value = categories.first;
        }

        return DropdownButtonFormField<String>(
          initialValue: controller.category.value,
          items: categories
              .map(
                (category) => DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              controller.category.value = value;
              controller.isUrgent.value = value == 'Urgent';
            }
          },
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 34),
          style: TextStyle(
            color: AppTheme.primaryText(context),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.softFill(context).withValues(alpha: 0.72),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.2),
            ),
          ),
        );
      },
    );
  }
}

class _DueDateField extends StatelessWidget {
  const _DueDateField({required this.controller});

  final QuickEntryController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: controller.pickDueDate,
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppTheme.softFill(context).withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  controller.formattedDueDate,
                  style: TextStyle(
                    color: AppTheme.primaryText(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.calendar_month_outlined,
                color: AppTheme.secondaryText(context),
                size: 27,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountBox extends StatelessWidget {
  const _AmountBox({required this.controller});

  final QuickEntryController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: BoxDecoration(
        color: AppTheme.isDark(context)
            ? AppTheme.accent.withValues(alpha: 0.12)
            : const Color(0xFFEFFFF8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.accent.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.attach_money_rounded,
                  color: AppTheme.accent, size: 20),
              SizedBox(width: 2),
              Expanded(
                child: Text(
                  'Transaction Amount',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'OPTIONAL',
                style: TextStyle(
                  color: Color(0xFF61B28E),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          TextField(
            controller: controller.amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              color: AppTheme.primaryText(context).withValues(alpha: 0.72),
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
            decoration: InputDecoration(
              prefixText: r'$ ',
              prefixStyle: TextStyle(
                color: AppTheme.secondaryText(context).withValues(alpha: 0.35),
                fontSize: 36,
                fontWeight: FontWeight.w800,
              ),
              hintText: '0.00',
              hintStyle: TextStyle(
                color: AppTheme.secondaryText(context).withValues(alpha: 0.20),
                fontSize: 36,
                fontWeight: FontWeight.w800,
              ),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveFooter extends StatelessWidget {
  const _SaveFooter({required this.controller});

  final QuickEntryController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        30,
        20,
        30,
        MediaQuery.of(context).padding.bottom + 5,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        border: Border(
          top: BorderSide(color: AppTheme.divider(context)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: controller.saveEntry,
            icon: const Icon(Icons.add_task_rounded, size: 24),
            label: const Text(
              'Save Entry',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(62),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: AppTheme.secondaryText(context),
                size: 17,
              ),
              const SizedBox(width: 10),
              Text(
                'END-TO-END ENCRYPTED',
                style: TextStyle(
                  color: AppTheme.secondaryText(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.controller});

  final QuickEntryController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: controller.pickTime,
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppTheme.softFill(context).withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  controller.formattedSelectedTime,
                  style: TextStyle(
                    color: AppTheme.primaryText(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.access_time_rounded,
                color: AppTheme.secondaryText(context),
                size: 27,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
