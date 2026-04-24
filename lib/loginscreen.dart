import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // This is where you would normally navigate to your HomeScreen
            print("Login Button Clicked");
          },
          child: const Text("Go to Dashboard"),
        ),
      ),
    );
  }
}
