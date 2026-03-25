import 'package:flutter/material.dart';

void main() {
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //for the background
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              // for the top card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Color(0xFF2D2E33),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      "Total Balance",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "0.00 ETB",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem(
                          "Income",
                          "+0.00 ETB",
                          Colors.greenAccent,
                        ),
                        _buildStatItem(
                          "Expense",
                          "-0.00 ETB",
                          Colors.redAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              //for the middle space
              Spacer(),
              Icon(Icons.receipt_long_outlined, size: 120, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                "No Transactions yet",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
      //for the add button
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Color(0xFF00C853),
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white, size: 35),
      ),
      //for bottom navigation
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 25),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(30),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, "Home", Colors.greenAccent),
                _buildNavItem(Icons.bar_chart, "Charts", Colors.white),
                _buildNavItem(Icons.description, "Records", Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String amount, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.white70)),
        Text(
          amount,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
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
