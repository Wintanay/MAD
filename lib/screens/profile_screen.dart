import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBudgetUpdated;

  const ProfileScreen({super.key, this.onBudgetUpdated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _editingBudget = false;
  bool _editingName = false;
  bool _isLoading = true;
  bool _isSavingName = false;
  bool _isSavingPassword = false;
  double? _currentBudget;
  int _totalTransactions = 0;
  double _totalSaved = 0;
  String _memberSince = "";

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final budgetDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('budget')
        .get();

    if (budgetDoc.exists) {
      final data = budgetDoc.data();
      if (data != null && data['monthly'] != null) {
        _currentBudget = (data['monthly'] as num).toDouble();
        _budgetController.text = _currentBudget!.toStringAsFixed(0);
      }
    }

    final txSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .get();

    double income = 0;
    double expense = 0;
    for (final doc in txSnapshot.docs) {
      final data = doc.data();
      if (data['type'] == 'Income') {
        income += (data['amount'] as num).toDouble();
      } else {
        expense += (data['amount'] as num).toDouble();
      }
    }

    final creationTime = user.metadata.creationTime;
    if (creationTime != null) {
      _memberSince =
          "${creationTime.day}/${creationTime.month}/${creationTime.year}";
    }

    _nameController.text = user.displayName ?? "";

    setState(() {
      _totalTransactions = txSnapshot.docs.length;
      _totalSaved = income - expense;
      _isLoading = false;
    });
  }

  Future<void> _saveBudget() async {
    final double? budget = double.tryParse(_budgetController.text);
    if (budget == null || budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid budget amount")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('budget')
        .set({'monthly': budget});

    setState(() {
      _currentBudget = budget;
      _editingBudget = false;
    });

    widget.onBudgetUpdated?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Budget saved!")),
    );
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name cannot be empty")),
      );
      return;
    }

    setState(() => _isSavingName = true);

    try {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
      setState(() {
        _editingName = false;
        _isSavingName = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name updated!")),
      );
    } catch (e) {
      setState(() => _isSavingName = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update name: $e")),
      );
    }
  }

  Future<void> _toggleDarkMode(bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Provider.of<ThemeProvider>(context, listen: false).setDark(value);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('theme')
        .set({'darkMode': value});
  }

  void _showChangePasswordDialog() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text("Change Password",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _passwordField(
                controller: _currentPasswordController,
                hint: "Current password",
                obscure: _obscureCurrent,
                onToggle: () => setDialogState(
                    () => _obscureCurrent = !_obscureCurrent),
              ),
              const SizedBox(height: 12),
              _passwordField(
                controller: _newPasswordController,
                hint: "New password",
                obscure: _obscureNew,
                onToggle: () =>
                    setDialogState(() => _obscureNew = !_obscureNew),
              ),
              const SizedBox(height: 12),
              _passwordField(
                controller: _confirmPasswordController,
                hint: "Confirm new password",
                obscure: _obscureConfirm,
                onToggle: () => setDialogState(
                    () => _obscureConfirm = !_obscureConfirm),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: _isSavingPassword
                  ? null
                  : () async {
                      if (_newPasswordController.text !=
                          _confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Passwords don't match")),
                        );
                        return;
                      }
                      if (_newPasswordController.text.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Password must be at least 6 characters")),
                        );
                        return;
                      }

                      setState(() => _isSavingPassword = true);

                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        final cred = EmailAuthProvider.credential(
                          email: user!.email!,
                          password: _currentPasswordController.text,
                        );
                        await user.reauthenticateWithCredential(cred);
                        await user
                            .updatePassword(_newPasswordController.text);

                        setState(() => _isSavingPassword = false);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Password changed!")),
                        );
                      } catch (e) {
                        setState(() => _isSavingPassword = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Incorrect current password")),
                        );
                      }
                    },
              child: const Text("Save",
                  style: TextStyle(
                      color: Color(0xFF00C853),
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final TextEditingController confirmController =
        TextEditingController();
    final TextEditingController passwordController =
        TextEditingController();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text("Delete Account",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.red)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "This will permanently delete your account and ALL your data. This cannot be undone.",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _passwordField(
                controller: passwordController,
                hint: "Enter your password to confirm",
                obscure: obscurePassword,
                onToggle: () => setDialogState(
                    () => obscurePassword = !obscurePassword),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                decoration: InputDecoration(
                  hintText: "Type DELETE to confirm",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                if (confirmController.text != "DELETE") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Type DELETE to confirm")),
                  );
                  return;
                }

                try {
                  final user = FirebaseAuth.instance.currentUser;
                  final cred = EmailAuthProvider.credential(
                    email: user!.email!,
                    password: passwordController.text,
                  );
                  await user.reauthenticateWithCredential(cred);

                  final txSnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('transactions')
                      .get();
                  for (final doc in txSnapshot.docs) {
                    await doc.reference.delete();
                  }

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('settings')
                      .doc('budget')
                      .delete();

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('categories')
                      .doc('custom')
                      .delete();

                  await user.delete();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Incorrect password")),
                  );
                }
              },
              child: const Text("Delete",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF00C853),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              const Text("Logout",
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                "Are you sure you want to logout\nfrom your account?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    elevation: 0,
                  ),
                  child: const Text("Yes, Logout",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: Colors.grey, width: 1.2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text("Cancel",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey),
          onPressed: onToggle,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? "No name set";
    final String email = user?.email ?? "No email";
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(color: Color(0xFF00C853)),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              CircleAvatar(
                radius: 55,
                backgroundColor:
                    const Color(0xFF00C853).withValues(alpha: 0.15),
                child: Text(
                  displayName.isNotEmpty
                      ? displayName[0].toUpperCase()
                      : "?",
                  style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00C853)),
                ),
              ),
              const SizedBox(height: 12),
              Text(displayName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(email,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 8),
              Text("Member since $_memberSince",
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      label: "Transactions",
                      value: "$_totalTransactions",
                      icon: Icons.receipt_long,
                      color: const Color(0xFF00C853),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      label: "Net Savings",
                      value:
                          "${_totalSaved >= 0 ? '+' : ''}${_totalSaved.toStringAsFixed(0)} ETB",
                      icon: Icons.savings,
                      color: _totalSaved >= 0
                          ? const Color(0xFF00C853)
                          : const Color(0xFFEF5350),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Edit name
              _sectionLabel("Full Name"),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2A2A2A)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _editingName
                          ? TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                  border: InputBorder.none),
                              style:
                                  const TextStyle(fontSize: 15),
                            )
                          : Align(
                              alignment: Alignment.centerLeft,
                              child: Text(displayName,
                                  style: const TextStyle(
                                      fontSize: 15)),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      if (_editingName) {
                        _saveName();
                      } else {
                        setState(() => _editingName = true);
                      }
                    },
                    child: _isSavingName
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF00C853)),
                          )
                        : Text(
                            _editingName ? "Save" : "Edit",
                            style: const TextStyle(
                                color: Color(0xFF00C853),
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Email
              _sectionLabel("Email"),
              const SizedBox(height: 8),
              _readOnlyField(email, isDark),
              const SizedBox(height: 20),

              // Budget
              _sectionLabel("Monthly Budget"),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2A2A2A)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _editingBudget
                          ? TextField(
                              controller: _budgetController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                suffixText: "ETB",
                              ),
                              style:
                                  const TextStyle(fontSize: 15),
                            )
                          : Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _currentBudget == null
                                    ? "No budget set"
                                    : "${_currentBudget!.toStringAsFixed(0)} ETB / month",
                                style: const TextStyle(
                                    fontSize: 15),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      if (_editingBudget) {
                        _saveBudget();
                      } else {
                        setState(() => _editingBudget = true);
                      }
                    },
                    child: Text(
                      _editingBudget ? "Save" : "Edit",
                      style: const TextStyle(
                          color: Color(0xFF00C853),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Dark mode toggle
              _sectionLabel("Appearance"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.dark_mode_outlined,
                            color: Color(0xFF00C853), size: 20),
                        SizedBox(width: 10),
                        Text("Dark Mode",
                            style: TextStyle(fontSize: 15)),
                      ],
                    ),
                    Switch(
                      value: isDark,
                      onChanged: _toggleDarkMode,
                      activeTrackColor: const Color(0xFF00C853),
                      activeThumbColor: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _actionButton(
                label: "Change Password",
                icon: Icons.lock_outline,
                color: Colors.grey[700]!,
                onTap: _showChangePasswordDialog,
              ),
              const SizedBox(height: 12),
              _actionButton(
                label: "Logout",
                icon: Icons.logout,
                color: Colors.grey[700]!,
                onTap: _showLogoutDialog,
              ),
              const SizedBox(height: 12),
              _actionButton(
                label: "Delete Account",
                icon: Icons.delete_forever_outlined,
                color: Colors.red,
                onTap: _showDeleteAccountDialog,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(label,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }

  Widget _readOnlyField(String value, bool isDark) {
    return Container(
      width: double.infinity,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color:
            isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child:
            Text(value, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          border: Border.all(
              color: color == Colors.red
                  ? Colors.red.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}