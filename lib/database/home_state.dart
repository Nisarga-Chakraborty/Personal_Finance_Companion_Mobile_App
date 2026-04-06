import 'package:assignment/database/transaction.dart';
import 'package:assignment/database/home_state.dart';

class CategoryBreakdown {
  final String category;
  final double totalAmount;
  final double percentage;

  const CategoryBreakdown({
    required this.category,
    required this.totalAmount,
    required this.percentage,
  });
}

class HomeState {
  final double totalBalance;
  final double monthIncome;
  final double monthExpenses;
  final double? trendAmount;
  final bool? trendIsPositive;
  final List<CategoryBreakdown> breakdown;
  final List<Transaction> recentTransactions;
  final String? insightText;
  final bool isLoading;
  final bool isEmpty;
  final double? budgetProgress;
  final double? budgetLimit;

  const HomeState({
    required this.totalBalance,
    required this.monthIncome,
    required this.monthExpenses,
    this.trendAmount,
    this.trendIsPositive = true,
    required this.breakdown,
    required this.recentTransactions,
    this.insightText,
    required this.isLoading,
    required this.isEmpty,
    this.budgetProgress,
    this.budgetLimit,
  });
}
