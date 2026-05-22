import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/chart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/record_screen.dart';
import 'screens/add_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF00C853),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF00C853),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }
        if (snapshot.hasData) {
          return const MainNavigation();
        }
        return const SplashScreen();
      },
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
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  double? _monthlyBudget;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('budget')
        .get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['monthly'] != null) {
        setState(() {
          _monthlyBudget = (data['monthly'] as num).toDouble();
        });
      }
    }
  }

  Future<void> _loadTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    final loaded = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'category': data['category'],
        'amount': data['amount'],
        'type': data['type'],
        'date': (data['date'] as Timestamp).toDate(),
        'notes': data['notes'] ?? '',
      };
    }).toList();

    setState(() {
      _transactions = loaded;
      _isLoading = false;
    });
  }

  Future<void> _navigateToAddScreen() async {
    final newTransaction = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddExpenseScreen()),
    );

    if (newTransaction != null && newTransaction is Map<String, dynamic>) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .add({
        'category': newTransaction['category'],
        'amount': newTransaction['amount'],
        'type': newTransaction['type'],
        'date': Timestamp.fromDate(newTransaction['date']),
        'notes': newTransaction['notes'] ?? '',
      });

      setState(() {
        _transactions.insert(0, {
          'id': docRef.id,
          'category': newTransaction['category'],
          'amount': newTransaction['amount'],
          'type': newTransaction['type'],
          'date': newTransaction['date'],
          'notes': newTransaction['notes'] ?? '',
        });
      });

      // re-sort by date after insert
      _transactions.sort(
          (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    }
  }

  void _deleteTransaction(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(id)
        .delete();

    setState(() {
      _transactions.removeWhere((t) => t['id'] == id);
    });
  }

  void _editTransaction(String id, Map<String, dynamic> updatedData) {
    setState(() {
      final index = _transactions.indexWhere((t) => t['id'] == id);
      if (index != -1) {
        _transactions[index] = {
          'id': id,
          'category': updatedData['category'],
          'amount': updatedData['amount'],
          'type': updatedData['type'],
          'date': updatedData['date'],
          'notes': updatedData['notes'] ?? '',
        };
      }
    });
  }

  List<Widget> get _pages => [
        _buildHomeContent(),
        ChartsScreen(transactions: _transactions),
        RecordsScreen(
          transactions: _transactions,
          onDelete: _deleteTransaction,
          onEdit: _editTransaction,
        ),
        ProfileScreen(onBudgetUpdated: _loadBudget),
      ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00C853)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: _pages[_selectedIndex],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: FloatingActionButton(
          onPressed: _navigateToAddScreen,
          backgroundColor: const Color(0xFF00C853),
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white, size: 35),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            if (index == 0) _loadBudget();
          },
          backgroundColor: const Color(0xFF1E1E1E),
          selectedItemColor: const Color(0xFF00C853),
          unselectedItemColor: Colors.grey[400],
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle:
              const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled, size: 24), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined, size: 24),
                label: 'Charts'),
            BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined, size: 24),
                label: 'Records'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, size: 24), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    final user = FirebaseAuth.instance.currentUser;
    final String firstName =
        (user?.displayName ?? "User").split(" ").first;

    final now = DateTime.now();

    double totalIncome = _transactions
        .where((t) => t['type'] == 'Income')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));

    double totalExpense = _transactions
        .where((t) => t['type'] == 'Expense')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));

    double monthlyExpense = _transactions
        .where((t) =>
            t['type'] == 'Expense' &&
            (t['date'] as DateTime).year == now.year &&
            (t['date'] as DateTime).month == now.month)
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));

    double totalBalance = totalIncome - totalExpense;

    double budgetPercent = _monthlyBudget == null || _monthlyBudget! <= 0
        ? 0
        : (monthlyExpense / _monthlyBudget!).clamp(0.0, 1.0);

    Color budgetColor = const Color(0xFF00C853);
    String budgetMessage = "";
    if (_monthlyBudget != null) {
      if (budgetPercent >= 1.0) {
        budgetColor = Colors.red;
        budgetMessage = "⚠️ You have exceeded your budget!";
      } else if (budgetPercent >= 0.8) {
        budgetColor = Colors.orange;
        budgetMessage = "⚠️ You are close to your budget limit!";
      }
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, $firstName 👋",
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const Text(
                "Here's your summary",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2C32),
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
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _balanceStatColumn("Income",
                        "+${totalIncome.toStringAsFixed(2)} ETB",
                        const Color(0xFF00C853)),
                    _balanceStatColumn("Expense",
                        "-${totalExpense.toStringAsFixed(2)} ETB",
                        const Color(0xFFEF5350)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Budget progress bar
          if (_monthlyBudget != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: budgetPercent >= 0.8
                      ? budgetColor.withValues(alpha: 0.4)
                      : Colors.transparent,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Monthly Budget",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(
                        "${monthlyExpense.toStringAsFixed(0)} / ${_monthlyBudget!.toStringAsFixed(0)} ETB",
                        style: TextStyle(
                            color: budgetColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: budgetPercent,
                      minHeight: 10,
                      backgroundColor: Colors.grey[200],
                      color: budgetColor,
                    ),
                  ),
                  if (budgetMessage.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(budgetMessage,
                        style: TextStyle(
                            color: budgetColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (_transactions.isNotEmpty)
            const Text(
              "Recent Transactions",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          if (_transactions.isNotEmpty) const SizedBox(height: 10),
          _transactions.isEmpty
              ? const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined,
                            size: 100, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("No Transactions yet",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final t = _transactions[index];
                      final bool isExpense = t['type'] == 'Expense';
                      final date = t['date'] as DateTime;
                      final formattedDate =
                          "${date.day}/${date.month}/${date.year}";
                      final String notes = t['notes'] ?? '';
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isExpense
                                ? const Color(0xFFFFEBEE)
                                : const Color(0xFFE8F5E9),
                            child: Icon(
                              isExpense
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: isExpense
                                  ? const Color(0xFFEF5350)
                                  : const Color(0xFF00C853),
                            ),
                          ),
                          title: Text(t['category'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(formattedDate,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              if (notes.isNotEmpty)
                                Text(notes,
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                            ],
                          ),
                          trailing: Text(
                            "${isExpense ? '-' : '+'}${(t['amount'] as double).toStringAsFixed(2)} ETB",
                            style: TextStyle(
                              color: isExpense
                                  ? const Color(0xFFEF5350)
                                  : const Color(0xFF00C853),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _balanceStatColumn(String label, String amount, Color color) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text(amount,
            style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}