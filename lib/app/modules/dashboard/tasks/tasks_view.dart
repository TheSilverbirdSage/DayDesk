import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/app/modules/dashboard/widgets/dashboard_scaffold.dart';

import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../widgets/notification_bell.dart';
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
            backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
            child: const Icon(Icons.person_rounded, color: AppTheme.primary),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              'Tasks',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search_rounded,
              color: Colors.blueGrey.shade300,
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
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.035)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.updateSearch,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Search daily tasks...',
          hintStyle: TextStyle(
            color: AppTheme.textSecondary.withValues(alpha: 0.52),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 28, right: 18),
            child: Icon(
              Icons.search_rounded,
              color: AppTheme.textPrimary.withValues(alpha: 0.62),
              size: 34,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 78),
          filled: true,
          fillColor: Colors.white,
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
                    color: isSelected ? AppTheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(38),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : Colors.black.withValues(alpha: 0.055),
                    ),
                    boxShadow: [
                      if (!isSelected)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.025),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.72)
                          : AppTheme.textPrimary,
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
  });

  final TaskSection section;
  final void Function(TaskListItem task) onToggle;

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
                        color: AppTheme.textPrimary,
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
  });

  final TaskListItem task;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final muted = task.isDone;
    final accent = task.isUrgent ? const Color(0xFFC00000) : AppTheme.primary;
    final checkboxColor = muted ? const Color(0xFF8478D1) : accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 14),
      decoration: BoxDecoration(
        color: muted ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: muted
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
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
                          : Colors.black.withValues(alpha: 0.16)),
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
                            ? AppTheme.textSecondary.withValues(alpha: 0.74)
                            : AppTheme.textPrimary,
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
                          ? AppTheme.textSecondary.withValues(alpha: 0.56)
                          : AppTheme.textSecondary,
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
                              ? AppTheme.textSecondary.withValues(alpha: 0.56)
                              : AppTheme.textSecondary,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if (!muted && task.priority != null) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '•',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
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
            color: Colors.blueGrey.shade200,
            size: 25,
          ),
        ],
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
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
