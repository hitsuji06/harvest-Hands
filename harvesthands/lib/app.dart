import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/company/dashboard_screen.dart';
import 'screens/volunteer/feed_screen.dart';
import 'theme/app_theme.dart';

class HarvestHandsApp extends StatelessWidget {
  const HarvestHandsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, child) {
          return MaterialApp(
            title: 'HarvestHands',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            home: const _AuthGate(),
          );
        },
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.loading:
        return const _SplashScreen();
      case AuthStatus.authenticated:
        final user = auth.currentUser!;
        return user.isCompany ? const CompanyDashboardScreen() : const FeedScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 120,
              errorBuilder: (_, _, _) => Icon(
                Icons.volunteer_activism,
                size: 80,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'HarvestHands',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 32),
            CircularProgressIndicator(color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
