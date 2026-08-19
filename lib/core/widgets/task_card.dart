import 'package:flutter/material.dart';
import 'package:taskmanagerapp/core/constants/app_colors.dart';
import 'package:taskmanagerapp/core/utils/date_formatter.dart';
import 'package:taskmanagerapp/domain/entities/task_entity.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final ValueChanged<TaskCompletionStatus> onStatusChanged;
  
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onStatusChanged,
    
    required this.onEdit,
    required this.onDelete,
  });

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
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
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

  String _getStatusLabel(TaskCompletionStatus status) {
    switch (status) {
      case TaskCompletionStatus.pending:
        return 'Pending';
      case TaskCompletionStatus.started:
        return 'Started';
      case TaskCompletionStatus.completed:
        return 'Completed';
      case TaskCompletionStatus.dropped:
        return 'Dropped';
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

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(task.priority);
    final statusColor = _getStatusColor(task.status);
    final dueStatus = DateFormatter.getDueStatus(task.dueDate);
    final isOverdue = dueStatus == 'Overdue' && task.status != TaskCompletionStatus.completed && task.status != TaskCompletionStatus.dropped;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: task.isCompleted || task.status == TaskCompletionStatus.dropped
            ? AppColors.surface.withValues(alpha: 0.8)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue ? AppColors.danger.withValues(alpha: 0.4) : AppColors.border,
          width: isOverdue ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          // onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Status Quick Button, Title, Options Popup
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Status Change Button
                    GestureDetector(
                      onTap: () {},
                      child: PopupMenuButton<TaskCompletionStatus>(
                        tooltip: 'Change Status',
                        onSelected: onStatusChanged,
                        itemBuilder: (context) => [
                          _buildStatusMenuItem(TaskCompletionStatus.pending, 'Pending', AppColors.statusPending, Icons.hourglass_empty_rounded),
                          _buildStatusMenuItem(TaskCompletionStatus.started, 'Started', AppColors.statusStarted, Icons.play_circle_outline_rounded),
                          _buildStatusMenuItem(TaskCompletionStatus.completed, 'Completed', AppColors.statusCompleted, Icons.check_circle_rounded),
                          _buildStatusMenuItem(TaskCompletionStatus.dropped, 'Dropped', AppColors.statusDropped, Icons.cancel_outlined),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getStatusIcon(task.status), size: 16, color: statusColor),
                              const SizedBox(width: 6),
                              Text(
                                _getStatusLabel(task.status),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_drop_down_rounded, size: 16, color: statusColor),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: task.isCompleted || task.status == TaskCompletionStatus.dropped
                                  ? AppColors.textMuted
                                  : AppColors.textPrimary,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : task.status == TaskCompletionStatus.dropped
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                            ),
                          ),
                          if (task.description.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              task.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: task.isCompleted || task.status == TaskCompletionStatus.dropped
                                    ? AppColors.textMuted
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Options Popup Menu
                    GestureDetector(
                      onTap: () {},
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted, size: 20),
                        onSelected: (value) {
                          if (value == 'edit') onEdit();
                          if (value == 'delete') onDelete();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: AppColors.danger)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 12),

                // Bottom Row: Priority Badge & Due Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Priority Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: priorityColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getPriorityLabel(task.priority),
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Due Date & Relative Status
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: isOverdue ? AppColors.danger : AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.formatDate(task.dueDate),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isOverdue ? FontWeight.bold : FontWeight.w500,
                            color: isOverdue ? AppColors.danger : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<TaskCompletionStatus> _buildStatusMenuItem(
    TaskCompletionStatus status,
    String label,
    Color color,
    IconData icon,
  ) {
    return PopupMenuItem(
      value: status,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: task.status == status ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
