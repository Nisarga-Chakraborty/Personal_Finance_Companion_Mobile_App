import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment/providers/home_provider.dart';
import 'package:assignment/database/transaction.dart' as database;
import 'package:intl/intl.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _selectedFilter = 'all'; // 'all', 'income', 'expense'
  String _searchQuery = '';
  final _searchController = TextEditingController();
  List<String> filterItems = ["all", "income", "expense"];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(allTransactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Transactions")),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            const Center(child: Text('Oops !! Something went wrong')),
        data: (transactions) => _buildContent(transactions),
      ),
    );
  }

  Widget _buildContent(List<database.Transaction> transactions) {
    var filtered = transactions.where((t) {
      if (_selectedFilter == "all") return true;
      if (_selectedFilter == "income") return t.type == "income";
      if (_selectedFilter == "expense") return t.type == "expense";
      return true;
    }).toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((b) {
        return b.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (b.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }
    // group by date
    final Map<String, List<database.Transaction>> grouped = {};
    for (var t in filtered) {
      final key = _formatDateKey(t.date);
      grouped[key] = [...(grouped[key] ?? []), t];
    }

    // build the UI
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterChips(),
        filtered.isEmpty
            ? const Expanded(
                child: Center(child: Text('No transactions found')),
              )
            : Expanded(child: _buildGroupedList(grouped)),
      ],
    );
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txnDate = DateTime(date.year, date.month, date.day);

    if (txnDate == today) return 'Today';
    if (txnDate == yesterday) return 'Yesterday';
    return DateFormat('dd MMM yyyy').format(date);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search by category or note...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }
  // using DropdownButtonFormField
  // Widget _buildFilterChips() {
  //   return DropdownButtonFormField<String>(
  //     items: filterItems
  //         .map((a) => DropdownMenuItem(value: a, child: Text(a)))
  //         .toList(),
  //     onChanged: (value) {
  //       setState(() {
  //         _selectedFilter = value!;
  //       });
  //     },
  //   );
  // }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: filterItems.map((filter) {
          return ChoiceChip(
            label: Text(filter),
            selected: _selectedFilter == filter,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedFilter = filter);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGroupedList(Map<String, List<database.Transaction>> grouped) {
    return ListView(
      children: grouped.entries.expand((entry) {
        return [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              entry.key,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ...entry.value.map(
            (transaction) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: Icon(
                  transaction.type == 'income'
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: transaction.type == 'income'
                      ? Colors.green
                      : Colors.red,
                ),
                title: Text(transaction.category),
                subtitle: transaction.note != null
                    ? Text(transaction.note!)
                    : null,
                trailing: Text(
                  '${transaction.type == 'income' ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: transaction.type == 'income'
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ];
      }).toList(),
    );
  }
}
