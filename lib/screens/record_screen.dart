import 'package:flutter/material.dart';

class RecordsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const RecordsScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Records",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Time Period Toggle (Week, Month, Year)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // Dark background
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _timeTab("Week", true),
                  _timeTab("Month", false),
                  _timeTab("Year", false),
                ],
              ),
            ),
          ),

          // 2. Sub-tabs (Week 9, Week 10, etc.)
          Container(
            color: const Color(0xFF1E1E1E), // Match the sub-bar color
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _subTabText("Week 9"),
                _subTabText("Week 10"),
                _subTabText("Last Week"),
                _subTabText("This Week", isActive: true),
              ],
            ),
          ),

          const SizedBox(height: 50),

          // 3. Content Area (Empty State or List)
          Expanded(
            child: transactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final item = transactions[index];
                      bool isInc = item['type'] == 'Income';
                      return _buildTransactionTile(item, isInc);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- UI Components ---

  Widget _timeTab(String label, bool isActive) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent, // Active is white
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _subTabText(String text, {bool isActive = false}) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // The Scroll/Paper Icon
        Icon(Icons.description_outlined, size: 100, color: Colors.grey[300]), 
        const SizedBox(height: 20),
        const Text(
          "No records yet",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text(
          "Your expenses will appear here",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
  Widget _buildTransactionTile(Map<String, dynamic> item, bool isInc) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[100],
        child: Icon(
          isInc ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down,
          color: isInc ? Colors.green : Colors.red,
        ),
      ),
      title: Text(item['category'], style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Text(
        "${isInc ? '+' : '-'}${item['amount'].toStringAsFixed(2)} ETB",
        style: TextStyle(color: isInc ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
      ),
    );
  }
}