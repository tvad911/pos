import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


// Core
import 'core/database/database.dart';

// Features
import 'features/auth/data/auth_repository.dart';
import 'features/auth/domain/auth_bloc.dart';
import 'features/auth/domain/auth_event.dart';
import 'features/auth/domain/auth_state.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/dashboard/presentation/main_screen.dart';
import 'features/settings/data/settings_repository.dart';
import 'features/settings/domain/settings_bloc.dart';
import 'features/inventory/data/inventory_repository.dart';
import 'features/inventory/domain/inventory_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize database
    final database = AppDatabase();
    

    
    // Initialize repositories
    final authRepository = AuthRepository(
      database: database,
    );
    
    final settingsRepository = SettingsRepository(
      database: database,
    );
    
    final inventoryRepository = InventoryRepository(
      database: database,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: database),
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: settingsRepository),
        RepositoryProvider.value(value: inventoryRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: authRepository,
            )..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => SettingsBloc(
              settingsRepository: settingsRepository,
            ),
          ),
          BlocProvider(
            create: (context) => InventoryBloc(
              inventoryRepository: inventoryRepository,
            ),
          ),
        ],
        child: MaterialApp(
          title: 'POS System 2026',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return const MainScreen();
              } else if (state is AuthUnauthenticated || 
                         state is AuthError || 
                         state is AuthLoading) {
                return const LoginScreen();
              } else {
                // Initial check state
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/dashboard': (context) => const MainScreen(),
          },
        ),
      ),
    );
  }
}
