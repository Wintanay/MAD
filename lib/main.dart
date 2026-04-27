import 'package:flutter/material.dart';
import 'splashscreen.dart';
import 'loginscreen.dart';
import 'addscreen.dart';
import 'chartscreen.dart';

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
        primaryColor: const Color(0xFF00C853), // Your project's green
      ),
      // Set the initial screen to SplashScreen
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
  int _selectedIndex = 0; // 0 = Home, 1 = Charts, 2 = Records

  // --- CORE DATA (Maintained here so all screens are updated) ---
  double totalBalance = 0.00;
  double totalIncome = 0.00;
  double totalExpense = 0.00;
  List<Map<String, dynamic>> transactions = [];

  // Logic to handle result from Wintanay's Add Screen
  void _navigateToAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        transactions.insert(0, result);
        double amount = result['amount'];

        // Updates balance based on Income/Expense type
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
    // List of screens to display in the main body
    final List<Widget> _pages = [
      _buildHomeContent(), // Tnebeb's Home Logic
      const ChartsScreen(), // Debora's Spending Analysis
      const Center(
          child: Text("Records Screen")), // Debora's Records Placeholder
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

  // --- TNEBEB'S ORIGINAL HOME UI ---
  Widget _buildHomeContent() {
    return Column(
      children: [
        _buildBalanceCard(),
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text("Recent Transactions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
        _buildTransactionList(),
      ],
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
              Icon(Icons.receipt_long, size: 80, color: Colors.grey[200]),
              Text("No data yet", style: TextStyle(color: Colors.grey[400])),
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
                backgroundColor: Colors.grey[100],
                child: Icon(
                    isIncome
                        ? Icons.keyboard_double_arrow_up
                        : Icons.keyboard_double_arrow_down,
                    color: isIncome ? Colors.green : Colors.red)),
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

  // --- BOTTOM NAVIGATION UI ---
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
            _navItem(Icons.home_filled, "Home", 0),
            _navItem(Icons.bar_chart_outlined, "Charts", 1),
            _navItem(Icons.description_outlined, "Records", 2),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: isSelected ? const Color(0xFF00C853) : Colors.white),
          Text(label,
              style: TextStyle(
                  color: isSelected ? const Color(0xFF00C853) : Colors.white,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
