import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_colors.dart';
import '../../presentation/home/home_screen.dart';

import '../../providers/auth_provider.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/auth/pin_lock_screen.dart';
import '../../presentation/onboarding/welcome_screen.dart';
import '../../presentation/onboarding/setup_assets_screen.dart';

import '../../presentation/transaction/add_transaction_screen.dart';
import '../../presentation/transaction/transaction_detail_screen.dart';
import '../../presentation/transaction/transaction_list_screen.dart';

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen(authNotifierProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = GoRouterRefreshNotifier(ref);
  return GoRouter(
    refreshListenable: refreshNotifier,
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      
      if (authState.isLoadingAuth) return '/splash';

      final isLoggedIn = authState.isLoggedIn;
      final isOnboarded = authState.isOnboarded;
      final isPinLocked = authState.isPinLocked;
      
      final isAuthRoute = state.uri.path.startsWith('/auth');
      
      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn && isPinLocked && state.uri.path != '/pin-lock') return '/pin-lock';
      if (isLoggedIn && !isPinLocked && !isOnboarded && !state.uri.path.startsWith('/onboarding')) return '/onboarding';
      if (isLoggedIn && !isPinLocked && isOnboarded && state.uri.path.startsWith('/onboarding')) return '/home';
      
      // Prevent going to login when already logged in
      if (isLoggedIn && isAuthRoute) return '/home';
      
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/pin-lock', builder: (context, state) => const PinLockScreen()),
      GoRoute(path: '/auth/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/auth/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/onboarding/setup-assets', builder: (context, state) => const SetupAssetsScreen()),
      
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/analytics', builder: (context, state) => const AnalyticsScreen()),
          GoRoute(path: '/chatbot', builder: (context, state) => const ChatbotScreen()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
          
          GoRoute(
            path: '/transaction/list',
            builder: (context, state) => const TransactionListScreen()
          ),
          GoRoute(
            path: '/transaction/add',
            builder: (context, state) => AddTransactionScreen(
              initialType: state.uri.queryParameters['type'],
            )
          ),
          GoRoute(
            path: '/transaction/:id',
            builder: (context, state) => TransactionDetailScreen(id: state.pathParameters['id']!)
          ),
          GoRoute(path: '/budget', builder: (context, state) => const BudgetScreen()),
          GoRoute(path: '/budget/add', builder: (context, state) => const AddBudgetScreen()),
          GoRoute(path: '/recurring', builder: (context, state) => const RecurringScreen()),
          GoRoute(path: '/settings/assets', builder: (context, state) => const ManageAssetsScreen()),
          GoRoute(path: '/settings/categories', builder: (context, state) => const ManageCategoriesScreen()),
          GoRoute(path: '/settings/export', builder: (context, state) => const ExportScreen()),
          GoRoute(path: '/settings/import', builder: (context, state) => const ImportScreen()),
          GoRoute(path: '/settings/feedback', builder: (context, state) => const FeedbackScreen()),
        ]
      ),
    ]
  );
});

// Dummy Screens to pass analyze (untuk screen yg belum dibuat)
class SplashScreen extends StatelessWidget { const SplashScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primaryAccent))); }
class MainScaffold extends StatelessWidget { final Widget child; const MainScaffold({super.key, required this.child}); @override Widget build(BuildContext context) => Scaffold(body: child); }

class AnalyticsScreen extends StatelessWidget { const AnalyticsScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(); }
class ChatbotScreen extends StatelessWidget { const ChatbotScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(); }
class SettingsScreen extends StatelessWidget { const SettingsScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(); }
class BudgetScreen extends StatelessWidget { const BudgetScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(); }
class AddBudgetScreen extends StatelessWidget { const AddBudgetScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(); }
class RecurringScreen extends StatelessWidget { const RecurringScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(); }
class ManageAssetsScreen extends StatelessWidget { const ManageAssetsScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(); }
class ManageCategoriesScreen extends StatelessWidget { const ManageCategoriesScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(); }
class ExportScreen extends StatelessWidget { const ExportScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(); }
class ImportScreen extends StatelessWidget { const ImportScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(); }
class FeedbackScreen extends StatelessWidget { const FeedbackScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(); }
