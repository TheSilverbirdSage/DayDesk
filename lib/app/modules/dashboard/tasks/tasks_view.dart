import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/app/modules/dashboard/widgets/dashboard_scaffold.dart';

import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../widgets/notification_bell.dart';
import '../widgets/swipe_delete_action.dart';
import '../widgets/task_details_dialog.dart';
import 'tasks_controller.dart';

class TasksView extends GetView<TasksController> {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      activeRoute: AppRoutes.tasks,
      child: Column(
        children: [
          const _TasksTopBar(),
          Expanded(
            child: Stack(
              children: [
                Obx(
                  () => ListView(
                    padding: const EdgeInsets.fromLTRB(26, 18, 26, 138),
                    children: [
                      _SearchBox(controller: controller),
                      const SizedBox(height: 26),
                      _CategoryChips(controller: controller),
                      const SizedBox(height: 36),
                      if (controller.sections.isEmpty)
                        const _EmptyTasks()
                      else
                        ...controller.sections.map(
                          (section) => _TaskSectionBlock(
                            section: section,
                            onToggle: controller.toggleTask,
                            onDelete: controller.deleteTask,
                            onLongPress: (task) => showTaskDetailsDialog(
                              context,
                              TaskDetailsData(
                                title: task.title,
                                section: task.section,
                                createdAt: task.createdAt,
                                scheduledAt: task.scheduledAt,
                                dueLabel: task.time,
                                notes: task.notes,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Positioned(
                //   right: 36,
                //   bottom: 90,
                //   child: _FloatingAddButton(onPressed: controller.addTaskStub),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TasksTopBar extends StatelessWidget {
  const _TasksTopBar();

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 26,
        right: 20,
        bottom: 20,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primary.withValues(
              alpha: isDark ? 0.22 : 0.12,
            ),
            child: Icon(
              Icons.person_rounded,
              color: isDark ? const Color(0xFFB4B5FF) : AppTheme.primary,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              'Tasks',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryAccent(context),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search_rounded,
              color: AppTheme.secondaryText(context).withValues(alpha: 0.72),
              size: 29,
            ),
          ),
          const SizedBox(width: 12),
          const NotificationBell(),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.controller});

  final TasksController controller;

  @override
  Widget build(BuildContext context) {
    final primaryText = AppTheme.primaryText(context);
    final secondaryText = AppTheme.secondaryText(context);
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider(context)),
        boxShadow: AppTheme.softShadow(context),
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.updateSearch,
        style: TextStyle(
          color: primaryText,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Search daily tasks...',
          hintStyle: TextStyle(
            color: secondaryText.withValues(alpha: 0.52),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 28, right: 18),
            child: Icon(
              Icons.search_rounded,
              color: primaryText.withValues(alpha: 0.62),
              size: 34,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 78),
          filled: true,
          fillColor: AppTheme.surface(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.2),
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.controller});

  final TasksController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: controller.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Obx(
            () {
              final isSelected = controller.selectedCategory.value == category;
              return InkWell(
                borderRadius: BorderRadius.circular(38),
                onTap: () => controller.selectCategory(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  constraints: const BoxConstraints(minWidth: 70),
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.surface(context),
                    borderRadius: BorderRadius.circular(38),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.divider(context),
                    ),
                    boxShadow: isSelected || isDark
                        ? []
                        : AppTheme.softShadow(context),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.72)
                          : AppTheme.primaryText(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TaskSectionBlock extends StatelessWidget {
  const _TaskSectionBlock({
    required this.section,
    required this.onToggle,
    required this.onDelete,
    required this.onLongPress,
  });

  final TaskSection section;
  final void Function(TaskListItem task) onToggle;
  final void Function(TaskListItem task) onDelete;
  final void Function(TaskListItem task) onLongPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 34),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  section.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.primaryText(context),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                ),
              ),
              Text(
                section.countLabel,
                style: TextStyle(
                  color: section.countColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...section.tasks.map(
            (task) => _TaskListTile(
              task: task,
              onToggle: () => onToggle(task),
              onDelete: () => onDelete(task),
              onLongPress: () => onLongPress(task),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskListTile extends StatelessWidget {
  const _TaskListTile({
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onLongPress,
  });

  final TaskListItem task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final muted = task.isDone;
    final accent = task.isUrgent ? const Color(0xFFC00000) : AppTheme.primary;
    final checkboxColor = muted ? const Color(0xFF8478D1) : accent;
    final primaryText = AppTheme.primaryText(context);
    final secondaryText = AppTheme.secondaryText(context);

    return SwipeDeleteAction(
      onDelete: onDelete,
      bottomInset: 18,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.fromLTRB(18, 16, 14, 14),
          decoration: BoxDecoration(
            color: muted ? Colors.transparent : AppTheme.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: muted ? Border.all(color: AppTheme.divider(context)) : null,
            boxShadow: muted ? [] : AppTheme.softShadow(context),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: muted ? checkboxColor : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: muted
                          ? checkboxColor
                          : (task.isUrgent
                              ? const Color(0xFFC00000)
                              : AppTheme.divider(context)),
                      width: 2.4,
                    ),
                  ),
                  child: muted
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14)
                      : null,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: muted
                                ? secondaryText.withValues(alpha: 0.74)
                                : primaryText,
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            decoration: muted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          task.icon,
                          color: muted
                              ? secondaryText.withValues(alpha: 0.56)
                              : secondaryText,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            muted
                                ? (task.completedText ??
                                    'Completed at ${task.time}')
                                : task.time,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: muted
                                  ? secondaryText.withValues(alpha: 0.56)
                                  : secondaryText,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        if (!muted && task.priority != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '•',
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              task.priority!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFC00000),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Icon(
                Icons.drag_indicator_rounded,
                color: secondaryText.withValues(alpha: 0.55),
                size: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Text(
          'No tasks found',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.secondaryText(context),
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
