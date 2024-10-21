import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('This is the Login Page'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the HomePage
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text('Login to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
