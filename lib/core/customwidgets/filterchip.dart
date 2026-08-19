import 'package:flutter/material.dart';

import '../../presentation/bloc/task/task_event.dart';
import '../constants/app_colors.dart';

Widget buildFilterChip({
  required String label,
  required TaskStatusFilter filter,
  required TaskStatusFilter current,
  required VoidCallback onSelected,
}) {
  final isSelected = filter == current;
  return ChoiceChip(
    label: Text(label),
    selected: isSelected,
    onSelected: (_) => onSelected(),
    selectedColor: AppColors.primary,
    backgroundColor: AppColors.background,
    labelStyle: TextStyle(
      color: isSelected ? Colors.white : AppColors.textSecondary,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      fontSize: 13,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
    ),
  );
}