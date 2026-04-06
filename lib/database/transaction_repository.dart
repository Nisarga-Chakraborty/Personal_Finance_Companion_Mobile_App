import 'package:assignment/database/budget.dart';
import 'package:assignment/database/home_state.dart';
import 'package:assignment/database/transaction.dart' as database;
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:uuid/uuid.dart';
import 'app_database.dart';

class TransactionRepository {
  final Database _db;
  static const _table = 'transactions';

  TransactionRepository(this._db);

  // ─── CREATE ───────────────────────────────────────────

  Future<database.Transaction> addTransaction({
    required double amount,
    required String type,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    final txn = database.Transaction(
      id: const Uuid().v4(),
      amount: amount,
      type: type,
      category: category,
      date: date,
      note: note,
    );
    await _db.insert(_table, txn.toMap());
    return txn;
  }

  // ─── READ ─────────────────────────────────────────────

  Future<List<database.Transaction>> getAllTransactions() async {
    final maps = await _db.query(
      _table,
      orderBy: 'date DESC',
    ); // getting the transactions recent first i.e. decreasing order by date
    return maps.map(database.Transaction.fromMap).toList();
  }

  Future<List<database.Transaction>> getTransactionsByMonth(
    int year,
    int month,
  ) async {
    // SQLite stores date as text, so we use LIKE for month filtering
    final prefix = '${year.toString()}-${month.toString().padLeft(2, '0')}';
    final maps = await _db.query(
      _table,
      where: 'date LIKE ?',
      whereArgs: ['$prefix%'],
      orderBy: 'date DESC',
    );
    return maps.map(database.Transaction.fromMap).toList();
  }

  Future<database.Transaction?> getTransactionById(String id) async {
    final maps = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return database.Transaction.fromMap(maps.first);
  }

  // ─── UPDATE ───────────────────────────────────────────

  Future<void> updateTransaction(database.Transaction txn) async {
    await _db.update(_table, txn.toMap(), where: 'id = ?', whereArgs: [txn.id]);
  }

  // ─── DELETE ───────────────────────────────────────────

  Future<void> deleteTransaction(String id) async {
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  // ─── UTILITY ──────────────────────────────────────────

  Future<bool> hasAnyTransactions() async {
    final result = await _db.rawQuery('SELECT COUNT(*) as count FROM $_table');
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  Future<HomeState> loadHomeData() async {
    final allTransactions = await getAllTransactions();
    // Get budget info using your Budget class
    final budget = await getCurrentMonthlyBudget();
    final budgetLimit = budget?.amount;
    final budgetProgress = budget != null ? await getBudgetProgress() : null;

    // empty check first
    if (allTransactions.isEmpty) {
      return HomeState(
        totalBalance: 0,
        monthIncome: 0,
        monthExpenses: 0,
        breakdown: [],
        recentTransactions: [],
        isLoading: false,
        isEmpty: true,
      );
    }

    final now = DateTime.now();
    final thisMonthTransactions = await getTransactionsByMonth(
      now.year,
      now.month,
    );
    final lastMonthTransactions = await getTransactionsByMonth(
      now.month == 1 ? now.year - 1 : now.year,
      now.month == 1 ? 12 : now.month - 1,
    );

    // now calculate using correct lists
    final totalBalance = _calculateTotalBalance(allTransactions);
    final monthIncome = _calculateMonthIncome(thisMonthTransactions);
    final monthExpenses = _calculateMonthExpenses(thisMonthTransactions);

    final thisMonthNet = monthIncome - monthExpenses;
    final trendAmount = _calculateTrendAmount(
      thisMonthTransactions,
      lastMonthTransactions,
      thisMonthNet,
    );
    final trendIsPositive = _calculateTrendIsPositive(
      lastMonthTransactions,
      thisMonthNet,
    );

    final breakdown = _buildCategoryBreakdown(thisMonthTransactions);
    final insightText = _buildInsightText(lastMonthTransactions, breakdown);
    final recentTransactions = allTransactions.take(5).toList();
    return HomeState(
      totalBalance: totalBalance,
      monthIncome: monthIncome,
      monthExpenses: monthExpenses,
      trendAmount: trendAmount,
      trendIsPositive: trendIsPositive,
      breakdown: breakdown,
      insightText: insightText,
      recentTransactions: recentTransactions,
      isLoading: false,
      isEmpty: false,
      budgetProgress: budgetProgress,
      budgetLimit: budgetLimit,
    );
  }

  double _calculateTotalBalance(List<database.Transaction> transactions) {
    double balance = 0;
    for (var txn in transactions) {
      if (txn.type == 'income') {
        balance += txn.amount;
      } else if (txn.type == 'expense') {
        balance -= txn.amount;
      }
    }
    return balance;
  }

  double _calculateMonthIncome(List<database.Transaction> transactions) {
    double income = 0;
    for (var txn in transactions) {
      if (txn.type == "income") {
        income = income + txn.amount;
      }
    }
    return income;
  }

  double _calculateMonthExpenses(List<database.Transaction> transactions) {
    double expenses = 0;
    for (var txn in transactions) {
      if (txn.type == "expense") {
        expenses = expenses + txn.amount;
      }
    }
    return expenses;
  }

  double? _calculateTrendAmount(
    List<database.Transaction> thisMonth,
    List<database.Transaction> lastMonth,
    double thisMonthNet,
  ) {
    if (lastMonth.isEmpty) return null;
    final lastMonthNet =
        _calculateMonthIncome(lastMonth) - _calculateMonthExpenses(lastMonth);
    return (thisMonthNet - lastMonthNet).abs();
  }

  bool _calculateTrendIsPositive(
    List<database.Transaction> lastMonth,
    double thisMonthNet,
  ) {
    if (lastMonth.isEmpty) return true;
    final lastMonthNet =
        _calculateMonthIncome(lastMonth) - _calculateMonthExpenses(lastMonth);
    return thisMonthNet >= lastMonthNet;
  }

  List<CategoryBreakdown> _buildCategoryBreakdown(
    List<database.Transaction> transactions,
  ) {
    double totalExpenses = 0;
    // step 1 - filter expenses only
    final expenses = transactions.where((t) => t.type == 'expense').toList();

    // step 2 - if no expenses return empty
    if (expenses.isEmpty) return [];

    // step 3 - group by category using a Map
    final Map<String, double> grouped = {};
    for (var txn in expenses) {
      grouped[txn.category] = (grouped[txn.category] ?? 0) + txn.amount;
      totalExpenses = totalExpenses + txn.amount;
    }
    List<CategoryBreakdown> breakdown = [];
    breakdown = grouped.entries.map((entry) {
      return CategoryBreakdown(
        category: entry.key,
        totalAmount: entry.value,
        percentage: (entry.value / totalExpenses) * 100,
      );
    }).toList();
    breakdown.sort((a, b) {
      return b.totalAmount.compareTo(a.totalAmount); // sort descending
      // here i can also do --> return b.percentage.compareTo(a.percentage); // sort by percentage instead of amount
    });
    // step 4 - taking top 4 and combine the rest into "Other"
    final result = breakdown.take(4).toList();

    if (breakdown.length > 4) {
      final othersAmount = breakdown
          .skip(4)
          .fold(0.0, (sum, item) => sum + item.totalAmount);
      final othersPercentage = breakdown
          .skip(4)
          .fold(0.0, (sum, item) => sum + item.percentage);

      result.add(
        CategoryBreakdown(
          category: 'Other',
          totalAmount: othersAmount,
          percentage: othersPercentage,
        ),
      );
    }

    return result;
  }

  Future<void> setMonthlyBudget(double amount) async {
    final now = DateTime.now();

    // Check if budget already exists for this month
    final existing = await _db.query(
      'budget',
      where: 'month = ? AND year = ?',
      whereArgs: [now.month, now.year],
    );

    if (existing.isNotEmpty) {
      // Update existing budget
      await _db.update(
        'budget',
        {'amount': amount},
        where: 'month = ? AND year = ?',
        whereArgs: [now.month, now.year],
      );
    } else {
      // Create Budget object and insert
      final budget = Budget(
        id: const Uuid().v4(),
        month: now.month,
        year: now.year,
        amount: amount,
      );
      await _db.insert('budget', budget.toMap());
    }
  }

  Future<Budget?> getCurrentMonthlyBudget() async {
    final now = DateTime.now();
    final result = await _db.query(
      'budget',
      where: 'month = ? AND year = ?',
      whereArgs: [now.month, now.year],
    );

    if (result.isEmpty) return null;
    return Budget.fromMap(result.first); // Returns Budget object
  }

  Future<double> getCurrentMonthSpending() async {
    final now = DateTime.now();
    final transactions = await getTransactionsByMonth(now.year, now.month);
    return _calculateMonthExpenses(transactions);
  }

  Future<double> getBudgetProgress() async {
    final budget = await getCurrentMonthlyBudget();
    if (budget == null || budget.amount == 0) return 0;

    final spent = await getCurrentMonthSpending();
    return (spent / budget.amount).clamp(0.0, 1.0);
  }

  /*String? _buildInsightText(
    List<database.Transaction> lastMonthTransactions,
    List<CategoryBreakdown> breakdown,
  ) {
    if (breakdown.isEmpty) return null;
    final topCategory = breakdown.first;
    final topAmount = topCategory.totalAmount;
    final topPercentage = topCategory.percentage;
    final topName = topCategory.category;

    if (breakdown.isEmpty) {
      return "No expenses recorded this month. Start adding transactions to see insights here!";
    } else if (lastMonthTransactions.isEmpty && topAmount > 0) {
      return "$topName is your top spend at ${topPercentage.toStringAsFixed(0)}% this month.";
    } else if (lastMonthTransactions.isNotEmpty) {
      final lastMonthBreakdown = _buildCategoryBreakdown(lastMonthTransactions);
      final lastMonthTop = lastMonthBreakdown!.first;
      if (lastMonthTop.category == topName) {
        double changeAmount = topAmount - lastMonthTop.totalAmount;
        double changePercent =
            ((changeAmount) / lastMonthTop.totalAmount) * 100;
        return "$topName is still your top spend at - ${changeAmount >= 0 ? "increased" : "decreased"} ${topPercentage.toStringAsFixed(0)}% this month, ${changePercent >= 0 ? 'up' : 'down'} ${changePercent.abs().toStringAsFixed(0)}% from last month.";
      } else if (lastMonthTop.category != topName) {
        return "$topName is now your top spend at ${topPercentage.toStringAsFixed(0)}% this month, overtaking ${lastMonthTop.category} which was at ${lastMonthTop.percentage.toStringAsFixed(0)}% last month.";
      } else {
        return "Your spending pattern is consistent with last month, with $topName as your top category at ${topPercentage.toStringAsFixed(0)}%.";
      }
    } else {
      return null;
    }
  }*/
  String? _buildInsightText(
    List<database.Transaction> lastMonthTransactions,
    List<CategoryBreakdown> breakdown,
  ) {
    if (breakdown.isEmpty) return null;

    final topCategory = breakdown.first;
    final topAmount = topCategory.totalAmount;
    final topPercentage = topCategory.percentage;
    final topName = topCategory.category;

    if (lastMonthTransactions.isEmpty) {
      return "$topName is your top spend at ${topPercentage.toStringAsFixed(0)}% this month.";
    } else {
      final lastMonthBreakdown = _buildCategoryBreakdown(lastMonthTransactions);
      if (lastMonthBreakdown.isEmpty) {
        return "$topName is your top spend at ${topPercentage.toStringAsFixed(0)}% this month.";
      }
      final lastMonthTop = lastMonthBreakdown.first;
      if (lastMonthTop.category == topName) {
        double changeAmount = topAmount - lastMonthTop.totalAmount;
        double changePercent =
            ((changeAmount) / lastMonthTop.totalAmount) * 100;
        return "$topName is still your top spend — ${changePercent >= 0 ? 'up' : 'down'} ${changePercent.abs().toStringAsFixed(0)}% from last month.";
      } else {
        return "$topName is now your top spend at ${topPercentage.toStringAsFixed(0)}%, overtaking ${lastMonthTop.category} from last month.";
      }
    }
  }
}
