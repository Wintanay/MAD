import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  String selectedCategory = "";
  String transactionType = "Expense";
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _resetInput() {
    setState(() {
      _amountController.clear();
      selectedCategory = "";
    });
  }

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildTypeToggle(),
                const SizedBox(height: 10),
                _buildHeaderCard(),
                const SizedBox(height: 40),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Choose category",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                if (transactionType == "Expense") ...[
                  _buildCategoryItem(Icons.restaurant, "Food"),
                  _buildCategoryItem(Icons.directions_bus, "Transport"),
                  _buildCategoryItem(Icons.home, "House Rent"),
                  _buildCategoryItem(Icons.shopping_basket, "Shopping"),
                ] else ...[
                  _buildCategoryItem(Icons.work, "Salary"),
                  _buildCategoryItem(Icons.card_giftcard, "Gift"),
                  _buildCategoryItem(Icons.savings, "Interest"),
                ],
                const SizedBox(height: 50),
                _buildSaveButton(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text("Expense"),
          selected: transactionType == "Expense",
          selectedColor: Colors.red[100],
          onSelected: (val) {
            transactionType = "Expense";
            _resetInput(); // Clears amount when switching
          },
        ),
        const SizedBox(width: 20),
        ChoiceChip(
          label: const Text("Income"),
          selected: transactionType == "Income",
          selectedColor: Colors.green[100],
          onSelected: (val) {
            transactionType = "Income";
            _resetInput(); // Clears amount when switching
          },
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
          color: transactionType == "Income"
              ? const Color(0xFF1B5E20)
              : const Color(0xFF2D2E33),
          borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Text("Add $transactionType",
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: "0.00",
              hintStyle: TextStyle(color: Colors.white38),
              suffixText: " ETB",
              suffixStyle: TextStyle(color: Colors.white70, fontSize: 16),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => _amountController.clear(),
                child: const CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: Icon(Icons.close, color: Colors.white)),
              ),
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: const CircleAvatar(
                    backgroundColor: Colors.greenAccent,
                    child: Icon(Icons.check, color: Colors.white)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          double? enteredAmount = double.tryParse(_amountController.text);
          if (selectedCategory.isEmpty ||
              enteredAmount == null ||
              enteredAmount <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Complete all fields")));
            return;
          }
          // Sending data back
          Navigator.pop(context, {
            'category': selectedCategory,
            'amount': enteredAmount,
            'type': transactionType,
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C853),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text("Save",
            style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    bool isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border:
              isSelected ? Border.all(color: const Color(0xFF00C853)) : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  isSelected ? const Color(0xFF00C853) : Colors.grey[200],
              child:
                  Icon(icon, color: isSelected ? Colors.white : Colors.black),
            ),
            const SizedBox(width: 20),
            Text(label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF00C853))
          ],
        ),
      ),
    );
  }
}
