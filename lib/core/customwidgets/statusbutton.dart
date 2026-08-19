  import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanagerapp/domain/entities/task_entity.dart';
import 'package:taskmanagerapp/presentation/bloc/task/task_bloc.dart';
import 'package:taskmanagerapp/presentation/bloc/task/task_event.dart';

Widget buildStatusButton(
    BuildContext context,
    TaskEntity task,
    TaskCompletionStatus targetStatus,
    String label,
    Color color,
    IconData icon,
  ) {
    final isSelected = task.status == targetStatus;
    return Expanded(
      child: Material(
        color: isSelected ? color : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            if (!isSelected) {
              context.read<TaskBloc>().add(
                ToggleTaskStatusEvent(task.id, targetStatus),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: isSelected ? Colors.white : color),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

