import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('This is the Login Page'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the HomePage
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Text('Login to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
