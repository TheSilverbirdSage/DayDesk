import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';

class TaskDetailsData {
  const TaskDetailsData({
    required this.title,
    this.section,
    this.createdAt,
    this.scheduledAt,
    this.dueLabel,
    this.notes,
  });

  final String title;
  final String? section;
  final DateTime? createdAt;
  final DateTime? scheduledAt;
  final String? dueLabel;
  final String? notes;
}

Future<void> showTaskDetailsDialog(
  BuildContext context,
  TaskDetailsData task,
) {
  final primaryText = AppTheme.primaryText(context);
  final secondaryText = AppTheme.secondaryText(context);
  final notes = task.notes?.trim();

  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.softShadow(context),
          border: Border.all(color: AppTheme.divider(context)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: primaryText,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Get.back<void>(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
            if ((task.section ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                task.section!,
                style: TextStyle(
                  color: AppTheme.primaryAccent(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
            const SizedBox(height: 18),
            _DetailRow(
              icon: Icons.add_circle_outline_rounded,
              label: 'Created',
              value: task.createdAt == null
                  ? 'Unknown'
                  : _formatDateTime(task.createdAt!),
            ),
            const SizedBox(height: 14),
            _DetailRow(
              icon: Icons.event_available_rounded,
              label: 'Assigned',
              value: _assignedLabel(task),
            ),
            const SizedBox(height: 18),
            Text(
              'Notes',
              style: TextStyle(
                color: secondaryText,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.softFill(context).withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                notes == null || notes.isEmpty ? 'No additional notes.' : notes,
                style: TextStyle(
                  color: notes == null || notes.isEmpty
                      ? secondaryText
                      : primaryText,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final secondaryText = AppTheme.secondaryText(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: AppTheme.primaryAccent(context),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  color: AppTheme.primaryText(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _assignedLabel(TaskDetailsData task) {
  if (task.scheduledAt != null) {
    return _formatDateTime(task.scheduledAt!);
  }
  final dueLabel = task.dueLabel?.trim();
  if (dueLabel != null && dueLabel.isNotEmpty) return dueLabel;
  return 'Not assigned';
}

String _formatDateTime(DateTime dateTime) {
  return '${_formatDate(dateTime)} at ${_formatTime(dateTime)}';
}

String _formatDate(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (date == today) return 'Today';
  if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
}

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;
  return '$displayHour:$minute $period';
}
