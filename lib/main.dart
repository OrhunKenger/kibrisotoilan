import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'injection_container.dart' as di;
import 'core/services/lookup_service.dart';

import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/main_wrapper.dart';
import 'presentation/pages/user_type_selection_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch unhandled async errors to prevent app crash (especially on web)
  FlutterError.onError = (details) {
    if (kDebugMode) FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) debugPrint('Unhandled error: $error');
    return true;
  };

  await di.init();
  await di.sl<LookupService>().loadLookups();

  final authBloc = di.sl<AuthBloc>()..add(const AppStarted());

  // Wire up 401 auto-logout: when interceptor detects 401, trigger logout
  di.setOnUnauthorized(() {
    authBloc.add(const LogoutRequested());
  });

  runApp(
    BlocProvider<AuthBloc>(
      create: (context) => authBloc,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KıbrısOto',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            di.resetUnauthorizedFlag();
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthInitial || state is AuthLoading) {
            return const SplashPage();
          } else if (state is Authenticated) {
            return const MainWrapper();
          } else if (state is RegisterSuccess) {
            return const UserTypeSelectionPage();
          } else if (state is Unauthenticated || state is AuthError) {
            return const UserTypeSelectionPage();
          }
          return const SplashPage();
        },
      ),
    );
  }
}
