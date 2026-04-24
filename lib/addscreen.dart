import 'package:flutter/material.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2E33),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text("Add Expense",
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  const Text(
                    "0.00 ETB",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCircleButton(Icons.close, Colors.redAccent),
                      _buildCircleButton(Icons.check, Colors.greenAccent),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Choose category",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            _buildCategoryItem(Icons.restaurant, "Food"),
            _buildCategoryItem(Icons.directions_bus, "Transport"),
            _buildCategoryItem(Icons.home, "House Rent"),
            _buildCategoryItem(Icons.shopping_basket, "Shopping"),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Save",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, Color color) {
    return CircleAvatar(
        backgroundColor: color, child: Icon(icon, color: Colors.white));
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Icon(icon, color: Colors.black)),
          const SizedBox(width: 20),
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
