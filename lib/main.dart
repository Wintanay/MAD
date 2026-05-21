import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/add_screen.dart';
import 'screens/chart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/record_screen.dart';

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF00C853),
      ),
      home: const SplashScreen(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> dummyTransactions = [];

  void _navigateToAddScreen() async {
    final newTransaction = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );

    if (newTransaction != null && newTransaction is Map<String, dynamic>) {
      setState(() {
        dummyTransactions.add(newTransaction);
      });
    }
  }

  // CHANGE 1: Changed from 'late final List' to 'get' so home rebuilds on state change
  List<Widget> get _pages => [
    _buildHomeContent(),
    const ChartsScreen(),
    RecordsScreen(transactions: dummyTransactions),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: _pages[_selectedIndex],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: FloatingActionButton(
          onPressed: _navigateToAddScreen,
          backgroundColor: const Color(0xFF00C853),
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white, size: 35),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: const Color(0xFF1E1E1E),
          selectedItemColor: const Color(0xFF00C853),
          unselectedItemColor: Colors.grey[400],
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle:
              const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled, size: 24), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined, size: 24), label: 'Charts'),
            BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined, size: 24), label: 'Records'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, size: 24), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  // CHANGE 2: _buildHomeContent now calculates real totals from dummyTransactions
  Widget _buildHomeContent() {
    double totalIncome = dummyTransactions
        .where((t) => t['type'] == 'Income')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));

    double totalExpense = dummyTransactions
        .where((t) => t['type'] == 'Expense')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));

    double totalBalance = totalIncome - totalExpense;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2C32),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text("Total Balance",
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  "${totalBalance.toStringAsFixed(2)} ETB",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _balanceStatColumn("Income",
                        "+${totalIncome.toStringAsFixed(2)} ETB",
                        const Color(0xFF00C853)),
                    _balanceStatColumn("Expense",
                        "-${totalExpense.toStringAsFixed(2)} ETB",
                        const Color(0xFFEF5350)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          // CHANGE 3: Shows transaction list when data exists, empty state when not
          dummyTransactions.isEmpty
              ? const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined,
                            size: 100, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("No Transactions yet",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: dummyTransactions.length,
                    itemBuilder: (context, index) {
                      final t = dummyTransactions[index];
                      bool isIncome = t['type'] == 'Income';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isIncome
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFEBEE),
                          child: Icon(
                            isIncome
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: isIncome
                                ? const Color(0xFF00C853)
                                : const Color(0xFFEF5350),
                          ),
                        ),
                        title: Text(t['category'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(t['type']),
                        trailing: Text(
                          "${isIncome ? '+' : '-'}${(t['amount'] as double).toStringAsFixed(2)} ETB",
                          style: TextStyle(
                            color: isIncome
                                ? const Color(0xFF00C853)
                                : const Color(0xFFEF5350),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _balanceStatColumn(String label, String amount, Color color) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text(amount,
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}