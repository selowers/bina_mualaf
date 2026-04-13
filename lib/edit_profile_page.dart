import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'model/user.dart';

class EditProfilePage extends StatefulWidget {
  final User currentUser;

  const EditProfilePage({super.key, required this.currentUser});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late String _avatarPath;
  final ImagePicker _picker = ImagePicker();
  String _message = '';
  Key _avatarKey = UniqueKey(); // Untuk force refresh avatar

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.nama);
    _emailController = TextEditingController(text: widget.currentUser.email);
    _avatarPath = widget.currentUser.avatarPath;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      try {
        final savedPath = await _saveImagePermanently(pickedFile.path);
        setState(() {
          _avatarPath = savedPath;
          _avatarKey = UniqueKey(); // Force refresh avatar
        });
      } catch (e) {
        setState(() {
          _message = 'Gagal menyimpan gambar: $e';
        });
      }
    }
  }

  Future<String> _saveImagePermanently(String pickedFilePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${appDir.path}/profile_avatars');
    
    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }

    final fileName = '${widget.currentUser.id}_avatar.jpg';
    final savedImagePath = '${profileDir.path}/$fileName';
    
    final sourceFile = File(pickedFilePath);
    final savedFile = await sourceFile.copy(savedImagePath);
    
    return savedFile.path;
  }

  void _clearAvatar() {
    if (_avatarPath.isNotEmpty) {
      try {
        final file = File(_avatarPath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        print('Gagal menghapus file avatar: $e');
      }
    }
    setState(() {
      _avatarPath = '';
      _avatarKey = UniqueKey(); // Force refresh avatar
    });
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      setState(() {
        _message = 'Nama dan email tidak boleh kosong.';
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users') ?? '[]';
    final users = (json.decode(usersJson) as List<dynamic>)
        .map((e) => User.fromJson(e))
        .toList();

    final duplicateEmail = users.any((u) => u.email == email && u.id != widget.currentUser.id);
    if (duplicateEmail) {
      setState(() {
        _message = 'Email sudah digunakan oleh pengguna lain.';
      });
      return;
    }

    final userIndex = users.indexWhere((u) => u.id == widget.currentUser.id);
    if (userIndex == -1) {
      setState(() {
        _message = 'Pengguna tidak ditemukan.';
      });
      return;
    }

    final updatedUser = User(
      id: widget.currentUser.id,
      nama: name,
      email: email,
      password: widget.currentUser.password,
      role: widget.currentUser.role,
      avatarPath: _avatarPath,
    );

    users[userIndex] = updatedUser;
    await prefs.setString('users', json.encode(users.map((u) => u.toJson()).toList()));
    await prefs.setString('current_user', json.encode(updatedUser.toJson()));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil berhasil diperbarui!')),
      );

      // Langsung kembali ke dashboard tanpa delay
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profil'),
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
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            key: _avatarKey, // Force refresh dengan key baru
                            radius: 54,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _avatarPath.isNotEmpty && File(_avatarPath).existsSync() 
                                ? FileImage(File(_avatarPath)) as ImageProvider 
                                : null,
                            child: _avatarPath.isEmpty || !File(_avatarPath).existsSync()
                                ? Icon(Icons.person, size: 56, color: Color(0xFF4A8CF7))
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _pickImage,
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.camera_alt, color: Color(0xFF4A8CF7), size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    if (_avatarPath.isNotEmpty && File(_avatarPath).existsSync())
                      TextButton.icon(
                        onPressed: _clearAvatar,
                        icon: Icon(Icons.delete_outline, color: Color(0xFF4A8CF7)),
                        label: Text('Hapus Foto', style: TextStyle(color: Color(0xFF4A8CF7))),
                      ),
                    Text(
                      'Perbarui Informasi Profil',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172B4D),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.grey.shade100,
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
                    Text(
                      'Role: ${widget.currentUser.role == 'pembimbing' ? 'Pembimbing' : 'Calon Mualaf'}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    SizedBox(height: 20),
                    if (_message.isNotEmpty)
                      Text(_message, style: TextStyle(color: Colors.red.shade700)),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4A8CF7),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Simpan Perubahan', style: TextStyle(fontSize: 16)),
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
