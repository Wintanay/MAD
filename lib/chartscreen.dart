import 'package:flutter/material.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Spending Analysis",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Time Period Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _timeChip("Week", true),
              _timeChip("Month", false),
              _timeChip("Year", false),
            ],
          ),
          const SizedBox(height: 10),
          // Weekly labels
          Container(
            color: const Color(0xFF1E1E1E),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Week 9", style: TextStyle(color: Colors.white)),
                Text("Week 10", style: TextStyle(color: Colors.white)),
                Text("Last Week", style: TextStyle(color: Colors.white)),
                Text("This Week",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Spacer(),
          // Donut Chart Placeholder
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 200,
                width: 200,
                child: CircularProgressIndicator(
                  value: 0.0, // Set to 0% as in your image
                  strokeWidth: 40,
                  backgroundColor: Colors.grey[200],
                  color: const Color(0xFF00C853),
                ),
              ),
              const Text("0%",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _timeChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
