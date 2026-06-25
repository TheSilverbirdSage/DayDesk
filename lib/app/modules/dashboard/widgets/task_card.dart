import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/task_model.dart';
import 'swipe_delete_action.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onLongPress,
    required this.onDelete,
  });

  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final primaryText = AppTheme.primaryText(context);
    final secondaryText = AppTheme.secondaryText(context);
    return SwipeDeleteAction(
      onDelete: onDelete,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: task.isDone ? Colors.transparent : AppTheme.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: task.isDone
                ? Border.all(color: AppTheme.divider(context))
                : null,
            boxShadow: task.isDone ? [] : AppTheme.softShadow(context),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isDone
                        ? AppTheme.primary.withValues(alpha: 0.72)
                        : Colors.transparent,
                    border: Border.all(
                      color: task.isDone
                          ? AppTheme.primary.withValues(alpha: 0.72)
                          : AppTheme.primary.withValues(alpha: 0.28),
                      width: 2.2,
                    ),
                  ),
                  child: task.isDone
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 21,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: task.isDone ? secondaryText : primaryText,
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _subtitleIcon,
                          color: task.isDone ? secondaryText : primaryText,
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            task.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: task.isDone ? secondaryText : primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (task.badge.isNotEmpty) ...[
                const SizedBox(width: 12),
                _TaskBadge(label: task.badge),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData get _subtitleIcon {
    if (task.isDone) return Icons.check_rounded;
    if (task.subtitle.contains(':')) return Icons.schedule_rounded;
    return Icons.shopping_cart_outlined;
  }
}

class _TaskBadge extends StatelessWidget {
  const _TaskBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isUrgent = label == 'URGENT';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isUrgent ? 0 : 12,
        vertical: isUrgent ? 0 : 8,
      ),
      decoration: BoxDecoration(
        color: isUrgent
            ? Colors.transparent
            : AppTheme.softFill(context).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isUrgent ? AppTheme.urgent : AppTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
