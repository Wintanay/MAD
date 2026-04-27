import 'package:flutter/material.dart';
import 'splashscreen.dart';
import 'loginscreen.dart';
import 'addscreen.dart';

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Expense Tracker',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF00C853),
      ),
      home: const SplashScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

        // Logical check to update balance correctly
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 20),
            _buildTransactionList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddScreen,
        backgroundColor: const Color(0xFF00C853),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBalanceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
            color: const Color(0xFF2D2E33),
            borderRadius: BorderRadius.circular(24)),
        child: Column(
          children: [
            const Text("Total Balance",
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              "${totalBalance.toStringAsFixed(2)} ETB",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                    "Income",
                    "+${totalIncome.toStringAsFixed(2)} ETB",
                    Colors.greenAccent),
                _buildStatItem(
                    "Expense",
                    "-${totalExpense.toStringAsFixed(2)} ETB",
                    Colors.redAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String amount, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        Text(amount,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildTransactionList() {
    if (transactions.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.article_outlined, size: 100, color: Colors.grey[300]),
              const SizedBox(height: 15),
              const Text("No Transactions yet",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final item = transactions[index];
          bool isIncome = item['type'] == 'Income';
          return ListTile(
            leading: CircleAvatar(
                backgroundColor: const Color(0xFFF5F5F5),
                child: Icon(
                    isIncome
                        ? Icons.account_balance_wallet
                        : Icons.shopping_bag,
                    color: Colors.black)),
            title: Text(item['category'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text(
                "${isIncome ? '+' : '-'}${item['amount'].toStringAsFixed(2)} ETB",
                style: TextStyle(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
      child: Container(
        height: 75,
        decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(30)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, "Home", const Color(0xFF00C853)),
            _buildNavItem(Icons.bar_chart_outlined, "Charts", Colors.white),
            _buildNavItem(Icons.description_outlined, "Records", Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        Text(label, style: TextStyle(color: color, fontSize: 12))
      ],
    );
  }
}
