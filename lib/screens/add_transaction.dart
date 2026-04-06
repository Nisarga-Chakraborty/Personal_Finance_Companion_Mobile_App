import 'package:assignment/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedType = 'expense';
  String _selectedCategory = 'Food';

  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Health',
    'Other',
  ];

  void _saveTransaction() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);

    final note = _noteController.text.trim();

    final repo = await ref.read(repositoryProvider.future);

    //save to database
    await repo.addTransaction(
      amount: amount,
      type: _selectedType,
      category: _selectedCategory,
      date: DateTime.now(),
      note: note.isEmpty ? null : note,
    );

    ref.invalidate(homeStateProvider); // Refresh Home Screen
    ref.invalidate(allTransactionsProvider); // Refresh Transaction Screen

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Transaction saved"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Transaction")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Amount
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    prefixText: "₹ ",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter amount";
                    }
                    final number = double.tryParse(value);
                    if (number == null || number <= 0) {
                      return "Enter valid amount";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Type toggle
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text("Expense"),
                      selected: _selectedType == 'expense',
                      onSelected: (_) {
                        setState(() => _selectedType = 'expense');
                      },
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text("Income"),
                      selected: _selectedType == 'income',
                      onSelected: (_) {
                        setState(() => _selectedType = 'income');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Category dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: "Category"),
                  items: _categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Select category";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Note
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: "Note (optional)",
                  ),
                ),

                const Spacer(),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Save", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
