import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'model/user.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  String _message = '';

  Future<void> _resetPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users') ?? '[]';
    final users = (json.decode(usersJson) as List<dynamic>)
        .map((e) => User.fromJson(e))
        .toList();

    final userIndex = users.indexWhere((u) => u.email == _emailController.text);
    if (userIndex != -1) {
      users[userIndex] = User(
        id: users[userIndex].id,
        nama: users[userIndex].nama,
        email: users[userIndex].email,
        password: '123456', // Reset to default
        role: users[userIndex].role,
        avatarPath: users[userIndex].avatarPath,
      );
      await prefs.setString(
        'users',
        json.encode(users.map((u) => u.toJson()).toList()),
      );
      setState(() {
        _message = 'Password telah direset ke 123456';
      });
    } else {
      setState(() {
        _message = 'Email tidak ditemukan';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lupa Password',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              if (_message.isNotEmpty)
                Text(_message, style: TextStyle(color: Colors.white)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resetPassword,
                child: Text('Reset Password'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Kembali ke Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
