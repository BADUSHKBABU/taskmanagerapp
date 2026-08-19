import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanagerapp/core/constants/app_colors.dart';
import 'package:taskmanagerapp/core/customwidgets/statusbutton.dart';
import 'package:taskmanagerapp/core/utils/date_formatter.dart';
import 'package:taskmanagerapp/domain/entities/task_entity.dart';
import 'package:taskmanagerapp/presentation/bloc/task/task_bloc.dart';
import 'package:taskmanagerapp/presentation/bloc/task/task_event.dart';
import 'package:taskmanagerapp/presentation/bloc/task/task_state.dart';
import 'package:taskmanagerapp/presentation/screens/tasks/add_edit_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskEntity task;

  const TaskDetailScreen({super.key, required this.task});

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'High Priority';
      case TaskPriority.medium:
        return 'Medium Priority';
      case TaskPriority.low:
        return 'Low Priority';
    }
  }

  Color _getStatusColor(TaskCompletionStatus status) {
    switch (status) {
      case TaskCompletionStatus.pending:
        return AppColors.statusPending;
      case TaskCompletionStatus.started:
        return AppColors.statusStarted;
      case TaskCompletionStatus.completed:
        return AppColors.statusCompleted;
      case TaskCompletionStatus.dropped:
        return AppColors.statusDropped;
    }
  }

  String _getStatusTitle(TaskCompletionStatus status) {
    switch (status) {
      case TaskCompletionStatus.pending:
        return 'Pending';
      case TaskCompletionStatus.started:
        return 'In Progress (Started)';
      case TaskCompletionStatus.completed:
        return 'Completed';
      case TaskCompletionStatus.dropped:
        return 'Dropped';
    }
  }

  String _getStatusSubtitle(TaskCompletionStatus status, bool isOverdue) {
    switch (status) {
      case TaskCompletionStatus.pending:
        return isOverdue
            ? 'Overdue! Needs attention.'
            : 'Waiting to be started.';
      case TaskCompletionStatus.started:
        return 'Currently being worked on.';
      case TaskCompletionStatus.completed:
        return 'Great job! This task is finished.';
      case TaskCompletionStatus.dropped:
        return 'This task was cancelled or dropped.';
    }
  }

  IconData _getStatusIcon(TaskCompletionStatus status) {
    switch (status) {
      case TaskCompletionStatus.pending:
        return Icons.hourglass_empty_rounded;
      case TaskCompletionStatus.started:
        return Icons.play_circle_outline_rounded;
      case TaskCompletionStatus.completed:
        return Icons.check_circle_rounded;
      case TaskCompletionStatus.dropped:
        return Icons.cancel_outlined;
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task'),
        content: const Text(
          'Are you sure you want to delete this task? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        final currentTask = state.allTasks.firstWhere(
          (t) => t.id == task.id,
        );
        final priorityColor = _getPriorityColor(currentTask.priority);
        final dueStatus = DateFormatter.getDueStatus(currentTask.dueDate);
        final isOverdue =dueStatus == 'Overdue' &&
            currentTask.status != TaskCompletionStatus.completed &&
            currentTask.status != TaskCompletionStatus.dropped;
        final currentStatusColor = _getStatusColor(currentTask.status);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Task Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            backgroundColor: AppColors.surface,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AddEditTaskScreen(taskToEdit: currentTask),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                ),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: currentStatusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(currentTask.status),
                        color: currentStatusColor,
                        size: 32,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusTitle(currentTask.status),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: currentStatusColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getStatusSubtitle(currentTask.status, isOverdue),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Change Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    buildStatusButton(
                      context,
                      currentTask,
                      TaskCompletionStatus.pending,
                      'Pending',
                      AppColors.statusPending,
                      Icons.hourglass_empty_rounded,
                    ),
                    const SizedBox(width: 6),
                    buildStatusButton(
                      context,
                      currentTask,
                      TaskCompletionStatus.started,
                      'Started',
                      AppColors.statusStarted,
                      Icons.play_circle_outline_rounded,
                    ),
                    const SizedBox(width: 6),
                    buildStatusButton(
                      context,
                      currentTask,
                      TaskCompletionStatus.completed,
                      'Completed',
                      AppColors.statusCompleted,
                      Icons.check_circle_rounded,
                    ),
                    const SizedBox(width: 6),
                    buildStatusButton(
                      context,
                      currentTask,
                      TaskCompletionStatus.dropped,
                      'Dropped',
                      AppColors.statusDropped,
                      Icons.cancel_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  currentTask.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    decoration: currentTask.isCompleted
                        ? TextDecoration.lineThrough
                        : currentTask.status == TaskCompletionStatus.dropped
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 16),

                // Metadata Row (Priority & Due Date)
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    // Priority Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flag_rounded,
                            size: 16,
                            color: priorityColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getPriorityLabel(currentTask.priority),
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Due Date Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? AppColors.dangerLight
                            : AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 16,
                            color: isOverdue
                                ? AppColors.danger
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Due: ${DateFormatter.formatDate(currentTask.dueDate)} ($dueStatus)',
                            style: TextStyle(
                              color: isOverdue
                                  ? AppColors.danger
                                  : AppColors.primaryDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 20),

                // Description Header & Body
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    currentTask.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Created Info
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Created on ${DateFormatter.formatDateTime(currentTask.createdDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}
