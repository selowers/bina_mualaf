import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'model/user.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _message = '';

  Future<void> _changePassword() async {
    final email = _emailController.text.trim();
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _message = 'Semua kolom harus diisi.';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _message = 'Password baru dan konfirmasi tidak cocok.';
      });
      return;
    }

    if (newPassword.length < 6) {
      setState(() {
        _message = 'Password baru minimal 6 karakter.';
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users') ?? '[]';
    final users = (json.decode(usersJson) as List<dynamic>)
        .map((e) => User.fromJson(e))
        .toList();

    final userIndex = users.indexWhere((u) => u.email == email && u.password == oldPassword);
    if (userIndex == -1) {
      setState(() {
        _message = 'Email atau password lama salah.';
      });
      return;
    }

    final updatedUser = User(
      id: users[userIndex].id,
      nama: users[userIndex].nama,
      email: users[userIndex].email,
      password: newPassword,
      role: users[userIndex].role,
      avatarPath: users[userIndex].avatarPath,
    );

    users[userIndex] = updatedUser;
    await prefs.setString('users', json.encode(users.map((u) => u.toJson()).toList()));

    final currentUserJson = prefs.getString('current_user');
    if (currentUserJson != null) {
      final currentUser = User.fromJson(json.decode(currentUserJson));
      if (currentUser.email == email) {
        await prefs.setString('current_user', json.encode(updatedUser.toJson()));
      }
    }

    setState(() {
      _message = 'Password berhasil diperbarui.';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password baru telah tersimpan. Silakan masuk kembali.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ganti Password'),
        backgroundColor: Color(0xFF4A8CF7),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A8CF7), Color(0xFF5ED5FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Ganti Password',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172B4D),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _oldPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password Lama',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password Baru',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    SizedBox(height: 16),
                    if (_message.isNotEmpty)
                      Text(_message, style: TextStyle(color: Colors.red.shade700)),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4A8CF7),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Ubah Password', style: TextStyle(fontSize: 16)),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Kembali ke Login', style: TextStyle(color: Color(0xFF4A8CF7))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
