import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'screens/add_expense_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/receipt_scan_screen.dart';
import 'state/app_state.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<Map>('finflow');
  await NotificationService.instance.init();
  runApp(const FinflowApp());
}

class FinflowApp extends StatelessWidget {
  const FinflowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..load(),
      child: MaterialApp(
        title: 'Finflow',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const RootNavigator(),
        routes: {
          AddExpenseScreen.routeName: (_) => const AddExpenseScreen(),
          BudgetScreen.routeName: (_) => const BudgetScreen(),
          InsightsScreen.routeName: (_) => const InsightsScreen(),
          GoalsScreen.routeName: (_) => const GoalsScreen(),
          ReportsScreen.routeName: (_) => const ReportsScreen(),
          ReceiptScanScreen.routeName: (_) => const ReceiptScanScreen(),
        },
      ),
    );
  }
}

class RootNavigator extends StatefulWidget {
  const RootNavigator({super.key});

  @override
  State<RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<RootNavigator> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (!appState.isProfileReady) {
      return const OnboardingScreen();
    }

    final screens = [
      const DashboardScreen(),
      const BudgetScreen(),
      const InsightsScreen(),
      const GoalsScreen(),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline), label: 'Budget'),
          NavigationDestination(icon: Icon(Icons.auto_graph_outlined), label: 'Insights'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), label: 'Goals'),
        ],
      ),
    );
  }
}
