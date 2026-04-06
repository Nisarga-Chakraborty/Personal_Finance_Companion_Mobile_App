import 'package:assignment/providers/home_provider.dart';
import 'package:assignment/screens/add_transaction.dart';
import 'package:assignment/screens/home_screen.dart';
import 'package:assignment/screens/insights_screen.dart';
import 'package:assignment/screens/profile_screen.dart';
import 'package:assignment/screens/transactions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  ConsumerState<TabsScreen> createState() {
    return TabsScreenState();
  }
}

class TabsScreenState extends ConsumerState<TabsScreen> {
  int _selectedTabIndex = 0;
  final List<Widget> screens = [
    const HomeScreen(),
    const TransactionsScreen(),
    const InsightsScreen(),
    const ProfileScreen(),
  ];
  void selectedTab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_selectedTabIndex],

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
          ref.invalidate(
            homeStateProvider,
          ); // Refresh Home Screen when returning from Add Transaction
        },
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_outlined),
            activeIcon: Icon(Icons.swap_horiz),
            label: "Transactions",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights),
            label: "Insights",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        currentIndex: _selectedTabIndex,
        onTap: selectedTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
    );
  }
}
