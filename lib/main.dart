import 'package:flutter/material.dart';
import 'splashscreen.dart';
import 'loginscreen.dart';
import 'addscreen.dart';
import 'chartscreen.dart';
import 'recordscreen.dart'; // Import Debora's Records Screen

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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

  // GLOBAL DATA: Shared between Home and Records
  double totalBalance = 0.00;
  double totalIncome = 0.00;
  double totalExpense = 0.00;
  List<Map<String, dynamic>> transactions = [];

  void _navigateToAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        transactions.insert(0, result);
        double amount = result['amount'];
        if (result['type'] == 'Income') {
          totalIncome += amount;
          totalBalance += amount;
        } else {
          totalExpense += amount;
          totalBalance -= amount;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // List of screens - Index 2 now passes the real transactions list
    final List<Widget> _pages = [
      _buildHomeContent(),
      const ChartsScreen(),
      RecordsScreen(transactions: transactions), // Passing the list to Records
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _pages[_selectedIndex]),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddScreen,
        backgroundColor: const Color(0xFF00C853),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        _buildBalanceCard(),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(alignment: Alignment.centerLeft, child: Text("Recent", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        ),
        _buildTransactionList(),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(color: const Color(0xFF2D2E33), borderRadius: BorderRadius.circular(24)),
        child: Column(
          children: [
            const Text("Total Balance", style: TextStyle(color: Colors.white70)),
            Text("${totalBalance.toStringAsFixed(2)} ETB", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _stat("Income", "+${totalIncome.toStringAsFixed(2)}", Colors.greenAccent),
                _stat("Expense", "-${totalExpense.toStringAsFixed(2)}", Colors.redAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String val, Color col) => Column(children: [Text(label, style: const TextStyle(color: Colors.white70)), Text(val, style: TextStyle(color: col, fontWeight: FontWeight.bold))]);
  Widget _buildTransactionList() {
    return Expanded(
      child: transactions.isEmpty 
        ? const Center(child: Text("No records yet"))
        : ListView.builder(
            itemCount: transactions.length > 5 ? 5 : transactions.length, // Show only recent 5 on Home
            itemBuilder: (context, index) {
              final item = transactions[index];
              return ListTile(
                title: Text(item['category']),
                trailing: Text("${item['type'] == 'Income' ? '+' : '-'}${item['amount']}", style: TextStyle(color: item['type'] == 'Income' ? Colors.green : Colors.red)),
              );
            },
          ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, 0),
          _navItem(Icons.bar_chart, 1),
          _navItem(Icons.list_alt, 2),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(icon, color: _selectedIndex == index ? const Color(0xFF00C853) : Colors.white),
      onPressed: () => setState(() => _selectedIndex = index),
    );
  }
}