import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanagerapp/core/constants/app_colors.dart';
import 'package:taskmanagerapp/domain/entities/task_entity.dart';
import 'package:taskmanagerapp/presentation/bloc/auth/auth_bloc.dart';
import 'package:taskmanagerapp/presentation/bloc/auth/auth_event.dart';
import 'package:taskmanagerapp/presentation/bloc/auth/auth_state.dart';
import 'package:taskmanagerapp/presentation/bloc/task/task_bloc.dart';
import 'package:taskmanagerapp/presentation/bloc/task/task_event.dart';
import 'package:taskmanagerapp/presentation/bloc/task/task_state.dart';
import 'package:taskmanagerapp/presentation/screens/tasks/add_edit_task_screen.dart';
import 'package:taskmanagerapp/presentation/screens/tasks/task_detail_screen.dart';
import '../../../core/customwidgets/filterchip.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/sync_indicator.dart';
import '../../../core/widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddTaskScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddEditTaskScreen()));
  }

  void _openTaskDetailScreen(TaskEntity task) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)));
  }

  void _openEditTaskScreen(TaskEntity task) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditTaskScreen(taskToEdit: task)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthenticatedState ? authState.user : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user != null ? ' ${user.name}' : 'User name not found',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (user != null)
              Text(
                user.email,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
            tooltip: 'Sign Out',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.read<AuthBloc>().add(const SignOutEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, taskState) {
          return Column(
            children: [
              //indicato ,online/offline
              SyncIndicator(
                isOnline: taskState.isOnline,
                isSyncing: taskState.isSyncing,
              ),

              // actions bar (search , filter,sort)`
              Container(
                padding: const EdgeInsets.all(16.0),
                color: AppColors.surface,
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (val) =>
                          context.read<TaskBloc>().add(SearchTasksEvent(val)),
                      decoration: InputDecoration(
                        hintText: 'Search tasks ..',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.textMuted,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<TaskBloc>().add(
                                    const SearchTasksEvent(''),
                                  );
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Filter_Chips and Sort
                    Row(
                      children: [
                        // Status
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                buildFilterChip(
                                  label: 'All (${taskState.totalTasksCount})',
                                  filter: TaskStatusFilter.all,
                                  current: taskState.statusFilter,
                                  onSelected: () =>
                                      context.read<TaskBloc>().add(
                                        const FilterTasksEvent(
                                          TaskStatusFilter.all,
                                        ),
                                      ),
                                ),
                                const SizedBox(width: 6),
                                buildFilterChip(
                                  label:
                                      'Pending (${taskState.pendingTasksCount})',
                                  filter: TaskStatusFilter.pending,
                                  current: taskState.statusFilter,
                                  onSelected: () =>
                                      context.read<TaskBloc>().add(
                                        const FilterTasksEvent(
                                          TaskStatusFilter.pending,
                                        ),
                                      ),
                                ),
                                const SizedBox(width: 6),
                                buildFilterChip(
                                  label:
                                      'Started (${taskState.startedTasksCount})',
                                  filter: TaskStatusFilter.started,
                                  current: taskState.statusFilter,
                                  onSelected: () =>
                                      context.read<TaskBloc>().add(
                                        const FilterTasksEvent(
                                          TaskStatusFilter.started,
                                        ),
                                      ),
                                ),
                                const SizedBox(width: 6),
                                buildFilterChip(
                                  label:
                                      'Completed (${taskState.completedTasksCount})',
                                  filter: TaskStatusFilter.completed,
                                  current: taskState.statusFilter,
                                  onSelected: () =>
                                      context.read<TaskBloc>().add(
                                        const FilterTasksEvent(
                                          TaskStatusFilter.completed,
                                        ),
                                      ),
                                ),
                                const SizedBox(width: 6),
                                buildFilterChip(
                                  label:
                                      'Dropped (${taskState.droppedTasksCount})',
                                  filter: TaskStatusFilter.dropped,
                                  current: taskState.statusFilter,
                                  onSelected: () =>
                                      context.read<TaskBloc>().add(
                                        const FilterTasksEvent(
                                          TaskStatusFilter.dropped,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Sort
                        PopupMenuButton<TaskSortOption>(
                          icon: const Icon(
                            Icons.sort_rounded,
                            color: AppColors.primary,
                          ),
                          tooltip: 'Sort Options',
                          onSelected: (option) => context.read<TaskBloc>().add(
                            SortTasksEvent(option),
                          ),
                          itemBuilder: (context) => [
                            CheckedPopupMenuItem(
                              checked:
                                  taskState.sortOption ==
                                  TaskSortOption.dueDateAsc,
                              value: TaskSortOption.dueDateAsc,
                              child: const Text('Due Date (Earliest)'),
                            ),
                            CheckedPopupMenuItem(
                              checked:
                                  taskState.sortOption ==
                                  TaskSortOption.dueDateDesc,
                              value: TaskSortOption.dueDateDesc,
                              child: const Text('Due Date (Latest)'),
                            ),
                            CheckedPopupMenuItem(
                              checked:
                                  taskState.sortOption ==
                                  TaskSortOption.priorityHighToLow,
                              value: TaskSortOption.priorityHighToLow,
                              child: const Text('Priority (High to Low)'),
                            ),
                            CheckedPopupMenuItem(
                              checked:
                                  taskState.sortOption ==
                                  TaskSortOption.createdDateDesc,
                              value: TaskSortOption.createdDateDesc,
                              child: const Text('Newest Created'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // taskvieew
              Expanded(child: _buildTaskListContent(context, taskState)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTaskScreen,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTaskListContent(BuildContext context, TaskState taskState) {
    if (taskState.status == TaskBlocStatus.loading) {
      return const LoadingView(message: 'Loading tasks from Firestore...');
    }
    if (taskState.status == TaskBlocStatus.failure) {
      return ErrorView(
        errorMessage: taskState.errorMessage ?? 'Failed to load tasks',
        onRetry: () =>
            context.read<TaskBloc>().add(const SubscribeTasksEvent()),
      );
    }
    final tasks = taskState.filteredTasks;
    if (tasks.isEmpty) {
      return EmptyView(
        title: taskState.searchQuery.isNotEmpty
            ? 'No matching tasks'
            : 'No tasks found',
        subtitle: taskState.searchQuery.isNotEmpty
            ? 'Try searching with a different term or clear the filter.'
            : 'No tasks found matching the selected status filter.',
        actionLabel: taskState.searchQuery.isEmpty ? 'Add Task' : null,
        onActionPressed: taskState.searchQuery.isEmpty
            ? _openAddTaskScreen
            : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onStatusChanged: (newStatus) {
            context.read<TaskBloc>().add(
              ToggleTaskStatusEvent(task.id, newStatus),
            );
          },

          onEdit: () => _openEditTaskScreen(task),
          onDelete: () {
            context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
          },
        );
      },
    );
  }
}
