import 'package:assignment/database/transaction.dart' as database;
import 'package:assignment/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  ConsumerState<InsightsScreen> createState() {
    return InsightsScreenState();
  }
}

class InsightsScreenState extends ConsumerState<InsightsScreen> {
  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(allTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Financial Insights"),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.grey[50],
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            const Center(child: Text("Oops! Something went wrong")),
        data: (transactions) => _buildContent(transactions),
      ),
    );
  }

  Widget _buildContent(List<database.Transaction> transactions) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        _buildSectionHeader("Spending Patterns", Icons.trending_up),
        peakSpendingHour(transactions),
        const SizedBox(height: 20),

        _buildSectionHeader("Daily Analysis", Icons.calendar_today),
        mostExpensiveDay(transactions),
        const SizedBox(height: 20),

        _buildSectionHeader("Period Comparison", Icons.compare_arrows),
        monthComparison(transactions),
        const SizedBox(height: 20),

        _buildSectionHeader("Category Insights", Icons.local_offer),
        categoryPlans(transactions),
        const SizedBox(height: 20),

        _buildSectionHeader("Financial Health", Icons.favorite),
        budgetHealthScore(transactions),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget peakSpendingHour(List<database.Transaction> transactions) {
    Map<int, double> hourMap = {};
    for (var i in transactions) {
      int hour = i.date.hour;
      hourMap[hour] = (hourMap[hour] ?? 0) + i.amount;
    }
    int? peakHour;
    double maxAmount = 0.0;
    hourMap.forEach((hour, amount) {
      if (amount > maxAmount) {
        maxAmount = amount;
        peakHour = hour;
      }
    });
    if (peakHour == null) {
      return _buildEmptyCard("No transaction data");
    }
    String timeFormat = peakHour! < 12
        ? "${peakHour}:00 AM"
        : "${peakHour! - 12}:00 PM";
    return _buildCard(
      icon: Icons.schedule,
      title: "Peak Hour",
      subtitle: timeFormat,
      value: "₹${maxAmount.toStringAsFixed(2)}",
      color: Colors.blue,
    );
  }

  Widget mostExpensiveDay(List<database.Transaction> transactions) {
    Map<int, double> dayMap = {};
    for (var i in transactions) {
      int day = i.date.day;
      dayMap[day] = (dayMap[day] ?? 0) + i.amount;
    }
    double maxAmount = 0.0;
    int? peakDay = 0;
    dayMap.forEach((day, amount) {
      if (amount > maxAmount) {
        maxAmount = amount;
        peakDay = day;
      }
    });
    if (peakDay == null) {
      return _buildEmptyCard("No transaction data");
    }
    return _buildCard(
      icon: Icons.today,
      title: "Most Expensive Day",
      subtitle: "Day $peakDay of the month",
      value: "₹${maxAmount.toStringAsFixed(2)}",
      color: Colors.red,
    );
  }

  Widget monthComparison(List<database.Transaction> transactions) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);

    double currentMonthTotal = 0;
    double lastMonthTotal = 0;

    for (var t in transactions) {
      final txnMonth = DateTime(t.date.year, t.date.month);
      if (txnMonth == currentMonth) {
        currentMonthTotal += t.amount;
      } else if (txnMonth == lastMonth) {
        lastMonthTotal += t.amount;
      }
    }

    final percentChange = lastMonthTotal == 0
        ? 0
        : ((currentMonthTotal - lastMonthTotal) / lastMonthTotal) * 100;
    final trend = percentChange > 0 ? "↑" : "↓";

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[300]!, Colors.orange[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                "This Month: ₹${currentMonthTotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "vs Last Month: ₹${lastMonthTotal.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              "Change: $trend ${percentChange.toStringAsFixed(1)}%",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryPlans(List<database.Transaction> transactions) {
    Map<String, int> categoryCount = {};

    for (var t in transactions) {
      categoryCount[t.category] = (categoryCount[t.category] ?? 0) + 1;
    }

    if (categoryCount.isEmpty) {
      return _buildEmptyCard("No categories found");
    }

    String topCategory = categoryCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    int count = categoryCount[topCategory] ?? 0;

    return _buildCard(
      icon: Icons.shopping_bag,
      title: "Most Frequent Category",
      subtitle: topCategory,
      value: "$count transactions",
      color: Colors.green,
    );
  }

  Widget budgetHealthScore(List<database.Transaction> transactions) {
    double totalIncome = 0;
    double totalExpense = 0;

    for (var t in transactions) {
      if (t.type == 'income') {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }

    double savingsRate = totalIncome == 0
        ? 0
        : ((totalIncome - totalExpense) / totalIncome) * 100;
    String healthStatus = savingsRate > 30
        ? "Excellent"
        : savingsRate > 15
        ? "Good"
        : savingsRate > 0
        ? "Fair"
        : "Poor";

    Color healthColor = savingsRate > 30
        ? Colors.green
        : savingsRate > 15
        ? Colors.orange
        : Colors.red;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [healthColor.withOpacity(0.3), healthColor.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: healthColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: healthColor, size: 24),
              const SizedBox(width: 8),
              Text(
                "Health Status: $healthStatus",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: healthColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                "Income",
                "₹${totalIncome.toStringAsFixed(2)}",
                Colors.green,
              ),
              _buildStatItem(
                "Expense",
                "₹${totalExpense.toStringAsFixed(2)}",
                Colors.red,
              ),
              _buildStatItem(
                "Savings",
                "${savingsRate.toStringAsFixed(1)}%",
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[100],
        ),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
