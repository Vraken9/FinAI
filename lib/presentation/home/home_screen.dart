import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/balance_card.dart';
import 'widgets/summary_cards.dart';
import 'widgets/daily_expense_chart.dart';
import 'widgets/ai_daily_insight.dart';
import 'widgets/health_score_widget.dart';
import 'widgets/budget_progress_strip.dart';
import 'widgets/upcoming_recurring.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/draft_recurring_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh providers
        },
        child: const CustomScrollView(
          slivers: [
            SliverSafeArea(
              bottom: false,
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 16),
                    BalanceCard(),
                    SummaryCardsRow(),
                    SizedBox(height: 16),
                    AiDailyInsight(),
                    BudgetProgressStrip(),
                    DraftRecurringBanner(),
                    UpcomingRecurringWidget(),
                    DailyExpenseChart(),
                    RecentTransactions(),
                    SizedBox(height: 180), // Extra padding agar FAB tengah tidak menutupi konten terakhir
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
