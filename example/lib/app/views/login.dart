import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers for email and password fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Password visibility toggle
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Login Page'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding around the form
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Make elements fill the width
            children: <Widget>[
              const Text(
                'Silahkan Login',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Email field
              // TextField(
              //   controller: _emailController,
              //   decoration: const InputDecoration(
              //     labelText: 'Email',
              //     border: OutlineInputBorder(),
              //   ),
              //   keyboardType: TextInputType.emailAddress,
              // ),
              // const SizedBox(height: 20),

              // // Password field with show/hide functionality
              // TextField(
              //   controller: _passwordController,
              //   obscureText: !_isPasswordVisible,
              //   decoration: InputDecoration(
              //     labelText: 'Password',
              //     border: const OutlineInputBorder(),
              //     suffixIcon: IconButton(
              //       icon: Icon(
              //         _isPasswordVisible
              //             ? Icons.visibility
              //             : Icons.visibility_off,
              //       ),
              //       onPressed: () {
              //         setState(() {
              //           _isPasswordVisible = !_isPasswordVisible;
              //         });
              //       },
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 20),

              // // Remember Me Checkbox
              // Row(
              //   children: [
              //     Checkbox(
              //       value: _rememberMe,
              //       onChanged: (bool? value) {
              //         setState(() {
              //           _rememberMe = value ?? false;
              //         });
              //       },
              //     ),
              //     const Text('Remember Me'),
              //   ],
              // ),
              // const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  // Handle form submission logic here
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
