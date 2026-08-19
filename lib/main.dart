import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskmanagerapp/core/constants/app_colors.dart';
import 'package:taskmanagerapp/core/network/network_info.dart';
import 'package:taskmanagerapp/core/widgets/error_view.dart';
import 'package:taskmanagerapp/data/datasources/auth_remote_datasource.dart';
import 'package:taskmanagerapp/data/datasources/task_local_datasource.dart';
import 'package:taskmanagerapp/data/datasources/task_remote_datasource.dart';
import 'package:taskmanagerapp/data/repositories/auth_repository_impl.dart';
import 'package:taskmanagerapp/data/repositories/task_repository_impl.dart';
import 'package:taskmanagerapp/domain/usecases/auth_usecases.dart';
import 'package:taskmanagerapp/domain/usecases/task_usecases.dart';
import 'package:taskmanagerapp/firebase_options.dart';
import 'package:taskmanagerapp/presentation/bloc/auth/auth_bloc.dart';
import 'package:taskmanagerapp/presentation/bloc/auth/auth_state.dart';
import 'package:taskmanagerapp/presentation/bloc/task/task_bloc.dart';
import 'package:taskmanagerapp/presentation/screens/auth/login_screen.dart';
import 'package:taskmanagerapp/presentation/screens/tasks/task_list_screen.dart';

import 'core/widgets/loading_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await Hive.openBox(TaskLocalDataSourceImpl.boxName);

  final networkInfo = NetworkInfoImpl(Connectivity());

  final authRemoteDataSource = AuthRemoteDataSourceImpl();
  final taskRemoteDataSource = TaskRemoteDataSourceImpl();
  final taskLocalDataSource = TaskLocalDataSourceImpl();

  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
  );
  final taskRepository = TaskRepositoryImpl(
    remoteDataSource: taskRemoteDataSource,
    localDataSource: taskLocalDataSource,
    networkInfo: networkInfo,
  );


  final signInUseCase = SignInUseCase(authRepository);
  final signUpUseCase = SignUpUseCase(authRepository);
  final signOutUseCase = SignOutUseCase(authRepository);
  final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);

  final getTasksStreamUseCase = GetTasksStreamUseCase(taskRepository);
  final createTaskUseCase = CreateTaskUseCase(taskRepository);
  final updateTaskUseCase = UpdateTaskUseCase(taskRepository);
  final deleteTaskUseCase = DeleteTaskUseCase(taskRepository);
  final toggleTaskStatusUseCase = ToggleTaskStatusUseCase(taskRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            signInUseCase: signInUseCase,
            signUpUseCase: signUpUseCase,
            signOutUseCase: signOutUseCase,
            getCurrentUserUseCase: getCurrentUserUseCase,
          ),
        ),
        BlocProvider<TaskBloc>(
          create: (_) => TaskBloc(
            getTasksStreamUseCase: getTasksStreamUseCase,
            createTaskUseCase: createTaskUseCase,
            updateTaskUseCase: updateTaskUseCase,
            deleteTaskUseCase: deleteTaskUseCase,
            toggleTaskStatusUseCase: toggleTaskStatusUseCase,
            networkInfo: networkInfo,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.danger,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitialState || state is AuthLoadingState) {
          return const Scaffold(
            body: LoadingView(message: 'Checking authentication status...'),
          );
        }

        if (state is AuthenticatedState) {
          return const TaskListScreen();
        }
        if (state is AuthErrorState) {
          return ErrorView(
            errorMessage: state.message.toString(),
            onRetry: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  LoginScreen()),
              );
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
