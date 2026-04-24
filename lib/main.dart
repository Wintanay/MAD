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
        primaryColor: const Color(0xFF00C853), // Success Green
        cardColor: const Color(0xFF2D2E33), // Dark Theme Card
      ),
      home: const SplashScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildBalanceCard(context),
            const SizedBox(height: 20),
            _buildTransactionList(),
          ],
        ),
      ),
      floatingActionButton: _buildAddButton(context),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- DARK BALANCE CARD ---
  Widget _buildBalanceCard(BuildContext context) {
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
            const Text(
              "Total Balance",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              "0.00 ETB",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem("Income", "+0.00 ETB", Colors.greenAccent),
                _buildStatItem("Expense", "-0.00 ETB", Colors.redAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- EMPTY STATE LIST ---
  Widget _buildTransactionList() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined, // Empty document icon
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 15),
            const Text(
              "No Transactions yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
        );
      },
      backgroundColor: const Color(0xFF00C853),
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white, size: 35),
    );
  }

  Widget _buildStatItem(String title, String amount, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        Text(
          amount,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  // --- DARK BOTTOM NAVIGATION ---
  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
      child: Container(
        height: 75,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(30),
        ),
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
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}
