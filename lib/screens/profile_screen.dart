import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 👇 your existing provider
final themeProvider = StateProvider<bool>((ref) => false);

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _budgetController = TextEditingController();

  String _gender = 'Other';

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,

      body: SafeArea(
        child: Column(
          children: [
            // 🔥 HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [Colors.black, Colors.grey.shade900]
                      : [const Color(0xFF6A11CB), const Color(0xFF2575FC)],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Your Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 🔥 BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 🌙 THEME TOGGLE (NEW)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        title: const Text("Dark Mode"),
                        value: isDark,
                        onChanged: (val) {
                          ref.read(themeProvider.notifier).state = val;
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildTextField("Name", _nameController),
                    const SizedBox(height: 12),

                    _buildTextField("Age", _ageController, isNumber: true),
                    const SizedBox(height: 12),

                    _buildTextField(
                      "Monthly Budget",
                      _budgetController,
                      isNumber: true,
                    ),

                    const SizedBox(height: 16),

                    // 🔥 Gender Chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ["Male", "Female", "Other"]
                          .map(
                            (g) => ChoiceChip(
                              label: Text(g),
                              selected: _gender == g,
                              onSelected: (_) => setState(() => _gender = g),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 30),

                    // 🔥 Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Saved (UI Only)")),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Save"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
