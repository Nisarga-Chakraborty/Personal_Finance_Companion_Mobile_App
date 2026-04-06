import 'package:assignment/database/home_state.dart';
import 'package:assignment/screens/transactions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment/providers/home_provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: homeState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Oops!! Something went wrong')),
        data: (state) => state.isEmpty
            ? const Center(child: Text('No transactions yet'))
            : _buildHomeContent(state, context, ref),
      ),
    );
  }

  Widget _buildHomeContent(
    HomeState state,
    BuildContext context,
    WidgetRef ref,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBalanceHeader(state, context),
          const Divider(height: 1),
          _buildStatsRow(state, context),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Spending Breakdown",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSpendingArea(state, context),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Recent Transactions",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildRecentTransactions(state, context, ref),
          ),
          const Divider(height: 1),
          _buildInsightChip(state, context),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBalanceHeader(HomeState state, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            "${DateTime.now().day} ${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][DateTime.now().month - 1]} ${DateTime.now().year}",

            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Balance: ₹${state.totalBalance.toStringAsFixed(0)}",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (state.trendAmount != null && state.trendIsPositive != null)
            Text(
              "${state.trendIsPositive! ? '↑' : '↓'} ${state.trendAmount!.abs().toStringAsFixed(2)} from last month",
              style: TextStyle(
                color: state.trendIsPositive!
                    ? Colors.greenAccent
                    : Colors.redAccent,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(HomeState state, BuildContext context) {
    final saved = state.monthIncome - state.monthExpenses;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildStatColumn(
              "Income",
              "₹${state.monthIncome.toStringAsFixed(0)}",
              Colors.green,
              context,
            ),
            VerticalDivider(
              color: Theme.of(context).dividerColor,
              thickness: 1,
              width: 1,
            ),
            _buildStatColumn(
              "Expenses",
              "₹${state.monthExpenses.toStringAsFixed(0)}",
              Colors.redAccent,
              context,
            ),
            VerticalDivider(
              color: Theme.of(context).dividerColor,
              thickness: 1,
              width: 1,
            ),
            _buildStatColumn(
              "Saved",
              "₹${saved.toStringAsFixed(0)}",
              Colors.blueAccent,
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    Color valueColor,
    BuildContext context,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*Widget _buildSpendingArea(HomeState state, BuildContext context) {
    final List<Color> categorycolors = [
      Colors.redAccent,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.yellowAccent,
    ];
    if (state.breakdown.isEmpty) {
      return Center(
        child: Text(
          "No spending data available",
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
        ),
      );
    } else {
      final sections = state.breakdown.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        return PieChartSectionData(
          color: categorycolors[index % categorycolors.length],
          value: data.percentage,
          radius: 50,
          showTitle: false,
        );
      }).toList();

      return Row(
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < state.breakdown.length; i++)
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: categorycolors[i % categorycolors.length],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${state.breakdown[i].category}: ${state.breakdown[i].percentage.toStringAsFixed(1)}%",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      );
    }
  }*/

  Widget _buildSpendingArea(HomeState state, BuildContext context) {
    final List<Color> categoryColors = [
      Colors.redAccent,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.yellowAccent,
    ];

    if (state.breakdown.isEmpty) {
      return Center(
        child: Text(
          "No spending data available",
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
        ),
      );
    }

    final sections = state.breakdown.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return PieChartSectionData(
        color: categoryColors[index % categoryColors.length],
        value: data.percentage,
        radius: 50,
        showTitle: false,
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 25,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < state.breakdown.length; i++) ...[
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: categoryColors[i % categoryColors.length],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${state.breakdown[i].category}: ${state.breakdown[i].percentage.toStringAsFixed(1)}%",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(
    HomeState a,
    BuildContext context,
    WidgetRef ref,
  ) {
    if (a.recentTransactions.isEmpty) {
      return Text(
        "No transactions yet",
        style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
      );
    } else {
      return Column(
        children: [
          for (var t in a.recentTransactions)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: t.type == 'income'
                    ? Colors.greenAccent
                    : Colors.redAccent,
                child: Icon(
                  t.type == 'income'
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                ),
              ),
              title: Text(
                t.category,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                DateFormat("dd MMM yyyy").format(t.date),
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onBackground.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              trailing: Text(
                "${t.type == 'income' ? '+' : '-'}₹${t.amount.toStringAsFixed(0)}",
                style: TextStyle(
                  color: t.type == 'income' ? Colors.green : Colors.redAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              //delete any particular ListTile on long press
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Confirm"),
                    content: const Text("Do you want to delete this item ?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          final repo = await ref.read(
                            repositoryProvider.future,
                          );
                          await repo.deleteTransaction(
                            t.id,
                          ); // deleting the transaction
                          ref.invalidate(
                            homeStateProvider,
                          ); // refreshing the Home Screen
                          ref.invalidate(
                            allTransactionsProvider,
                          ); // refreshing the Transactions Screen and Insights Screen

                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Transaction deleted'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        },
                        child: const Text('Delete'),
                      ),
                      /*TextButton(
                        child: Text("About"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),*/
                    ],
                  ),
                );
              },
            ),
        ],
      );
    }
  }

  Widget _buildInsightChip(HomeState state, BuildContext context) {
    if (state.insightText == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.purpleAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Insight",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              state.insightText!,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onBackground.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
        // two Text widgets — "Insight" label + insight text
      ),
    );
  }
}
