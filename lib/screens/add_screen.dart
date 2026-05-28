import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  String selectedCategory = "";
  String transactionType = "Expense";
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  final List<String> builtInExpense = [
    "Food", "Transport", "House Rent", "Shopping",
    "Medical", "Education", "Entertainment", "Utilities"
  ];
  final List<String> builtInIncome = [
    "Salary", "Gift", "Interest", "Freelance", "Investment", "Rental"
  ];

  List<Map<String, dynamic>> expenseCategories = [
    {"name": "Food", "icon": Icons.restaurant},
    {"name": "Transport", "icon": Icons.directions_bus},
    {"name": "House Rent", "icon": Icons.home},
    {"name": "Shopping", "icon": Icons.shopping_basket},
    {"name": "Medical", "icon": Icons.local_hospital},
    {"name": "Education", "icon": Icons.school},
    {"name": "Entertainment", "icon": Icons.movie},
    {"name": "Utilities", "icon": Icons.bolt},
  ];

  List<Map<String, dynamic>> incomeCategories = [
    {"name": "Salary", "icon": Icons.work},
    {"name": "Gift", "icon": Icons.card_giftcard},
    {"name": "Interest", "icon": Icons.savings},
    {"name": "Freelance", "icon": Icons.laptop},
    {"name": "Investment", "icon": Icons.trending_up},
    {"name": "Rental", "icon": Icons.house},
  ];

  @override
  void initState() {
    super.initState();
    _loadCustomCategories();
  }

  Future<void> _loadCustomCategories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('categories')
        .doc('custom')
        .get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        final List expCats = data['expense'] ?? [];
        final List incCats = data['income'] ?? [];
        setState(() {
          for (final cat in expCats) {
            if (!expenseCategories.any((c) => c['name'] == cat)) {
              expenseCategories.add({"name": cat, "icon": Icons.label});
            }
          }
          for (final cat in incCats) {
            if (!incomeCategories.any((c) => c['name'] == cat)) {
              incomeCategories.add({"name": cat, "icon": Icons.label});
            }
          }
        });
      }
    }
  }

  Future<void> _saveCustomCategories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final customExpense = expenseCategories
        .map((c) => c['name'] as String)
        .where((name) => !builtInExpense.contains(name))
        .toList();

    final customIncome = incomeCategories
        .map((c) => c['name'] as String)
        .where((name) => !builtInIncome.contains(name))
        .toList();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('categories')
        .doc('custom')
        .set({
      'expense': customExpense,
      'income': customIncome,
    });
  }

  Future<void> _pickDate() async {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF00C853),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  )  
                : const ColorScheme.light(
                    primary: Color(0xFF00C853),
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _showAddCategoryDialog() {
    final TextEditingController categoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Add $transactionType Category",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: categoryController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: "Category name",
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final name = categoryController.text.trim();
              if (name.isEmpty) return;
              setState(() {
                if (transactionType == "Expense") {
                  if (!expenseCategories.any((c) => c['name'] == name)) {
                    expenseCategories.add({"name": name, "icon": Icons.label});
                  }
                } else {
                  if (!incomeCategories.any((c) => c['name'] == name)) {
                    incomeCategories.add({"name": name, "icon": Icons.label});
                  }
                }
                selectedCategory = name;
              });
              _saveCustomCategories();
              Navigator.pop(ctx);
            },
            child: const Text("Add",
                style: TextStyle(
                    color: Color(0xFF00C853), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Category",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          "Are you sure you want to delete \"$name\"?",
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (transactionType == "Expense") {
                  expenseCategories.removeWhere((c) => c['name'] == name);
                } else {
                  incomeCategories.removeWhere((c) => c['name'] == name);
                }
                if (selectedCategory == name) selectedCategory = "";
              });
              _saveCustomCategories();
              Navigator.pop(ctx);
            },
            child: const Text("Delete",
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get currentCategories =>
      transactionType == "Expense" ? expenseCategories : incomeCategories;

  bool _isCustomCategory(String name) {
    if (transactionType == "Expense") {
      return !builtInExpense.contains(name);
    } else {
      return !builtInIncome.contains(name);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final fieldColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey[100]!;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildTypeToggle(isDark),
                const SizedBox(height: 10),
                _buildHeaderCard(),
                const SizedBox(height: 20),
                // Date picker
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: fieldColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Color(0xFF00C853), size: 20),
                        const SizedBox(width: 12),
                        Text(
                          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textColor),
                        ),
                        const Spacer(),
                        const Text("Change",
                            style: TextStyle(
                                color: Color(0xFF00C853),
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Notes field
                Container(
                  decoration: BoxDecoration(
                    color: fieldColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _notesController,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      hintText: "Add a note (optional)...",
                      hintStyle:
                          TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: Icon(Icons.notes,
                          color: Color(0xFF00C853), size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Choose category",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    GestureDetector(
                      onTap: _showAddCategoryDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add,
                                color: Color(0xFF00C853), size: 18),
                            SizedBox(width: 4),
                            Text("Add new",
                                style: TextStyle(
                                    color: Color(0xFF00C853),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...currentCategories.map((cat) => _buildCategoryItem(
                    cat['icon'] as IconData,
                    cat['name'] as String,
                    isDark)),
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

  Widget _buildTypeToggle(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              transactionType = "Expense";
              selectedCategory = "";
              _amountController.clear();
            });
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            decoration: BoxDecoration(
              color: transactionType == "Expense"
                  ? Colors.red[100]
                  : isDark
                      ? const Color(0xFF2A2A2A)
                      : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Expense",
              style: TextStyle(
                color: transactionType == "Expense"
                    ? Colors.red[900]
                    : Colors.grey[500],
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            setState(() {
              transactionType = "Income";
              selectedCategory = "";
              _amountController.clear();
            });
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            decoration: BoxDecoration(
              color: transactionType == "Income"
                  ? Colors.green[100]
                  : isDark
                      ? const Color(0xFF2A2A2A)
                      : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Income",
              style: TextStyle(
                color: transactionType == "Income"
                    ? Colors.green[900]
                    : Colors.grey[500],
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
          color: const Color(0xFF2D2E33),
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
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold),
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
          Navigator.pop(context, {
            'category': selectedCategory,
            'amount': enteredAmount,
            'type': transactionType,
            'date': selectedDate,
            'notes': _notesController.text.trim(),
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C853),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text("Save",
            style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, bool isDark) {
    bool isSelected = selectedCategory == label;
    bool isCustom = _isCustomCategory(label);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFE8F5E9)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: isSelected ? Border.all(color: const Color(0xFF00C853)) : null,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => selectedCategory = label),
            child: CircleAvatar(
              backgroundColor: isSelected
                  ? const Color(0xFF00C853)
                  : isDark
                      ? const Color(0xFF2A2A2A)
                      : Colors.grey[200],
              child: Icon(icon,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? Colors.white70
                          : Colors.black),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedCategory = label),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black)),
            ),
          ),
          if (isSelected && !isCustom)
            const Icon(Icons.check_circle, color: Color(0xFF00C853)),
          if (isCustom)
            Row(
              children: [
                if (isSelected)
                  const Icon(Icons.check_circle, color: Color(0xFF00C853)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _confirmDeleteCategory(label),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                ),
              ],
            ),
        ],
      ),
    );
  }
}