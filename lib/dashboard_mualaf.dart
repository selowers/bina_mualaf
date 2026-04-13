import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'model/user.dart';
import 'niat_sholat_page.dart';
import 'page/rukun_iman_islam_page.dart';
import 'page/doa_keseharian_page.dart';
import 'page/murotal.dart';
import 'ayat_kursi_page.dart';
import 'information.dart';
import 'edit_profile_page.dart';

class DashboardMualaf extends StatefulWidget {
  const DashboardMualaf({super.key});

  @override
  _DashboardMualafState createState() => _DashboardMualafState();
}

class _DashboardMualafState extends State<DashboardMualaf> {
  User? _currentUser;
  Key _avatarKey = UniqueKey(); // Untuk force refresh avatar

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      setState(() {
        _currentUser = User.fromJson(json.decode(userJson));
        _avatarKey = UniqueKey(); // Force refresh avatar saat load ulang
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Dashboard Calon Mualaf'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Akun',
            icon: _buildAvatarIcon(),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit Profil'),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(currentUser: _currentUser!),
                  ),
                ).then((_) {
                  _loadCurrentUser();
                });
              } else if (value == 'logout') {
                _logout();
              }
            },
          ),
        ],
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
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(
                  title: 'Selamat Datang, ${_currentUser!.nama}',
                  subtitle: 'Jelajahi materi dan pelajari setiap langkah dengan penuh semangat!',
                  icon: Icons.star,
                ),
                SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    buildMenu(
                      imageAsset: "assets/icniat.png",
                      title: "Niat Sholat & Bacaan",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NiatSholat(userId: _currentUser!.id),
                          ),
                        );
                      },
                    ),
                    buildMenu(
                      imageAsset: "assets/icbacaan.png",
                      title: "Ayat Kursi",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AyatKursi()),
                        );
                      },
                    ),
                    buildMenu(
                      imageAsset: "assets/informasi.png",
                      title: "Informasi",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Informasi()),
                        );
                      },
                    ),
                    buildMenu(
                      imageAsset: "assets/suratpendek.png",
                      title: "Rukun Iman & Islam",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RukunImanIslam(userId: _currentUser!.id),
                          ),
                        );
                      },
                    ),
                    buildMenu(
                      imageAsset: "assets/do_akeseharian.png",
                      title: "Do'a Keseharian",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DoaKeseharian(userId: _currentUser!.id),
                          ),
                        );
                      },
                    ),
                    buildMenu(
                      imageAsset: "assets/murotal.png",
                      title: "Murotal",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Murotal(userId: _currentUser!.id),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.28)),
      ),
      child: Row(
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Color(0xFF4A8CF7), size: 38),
          ),
          SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarIcon() {
    final hasValidAvatar = _currentUser!.avatarPath.isNotEmpty && File(_currentUser!.avatarPath).existsSync();
    return CircleAvatar(
      key: _avatarKey, // Force refresh dengan key baru
      radius: 18,
      backgroundColor: Colors.white,
      backgroundImage: hasValidAvatar ? FileImage(File(_currentUser!.avatarPath)) as ImageProvider : null,
      child: !hasValidAvatar ? Icon(Icons.person, color: Color(0xFF4A8CF7)) : null,
    );
  }

  Widget buildMenu({
    required String imageAsset,
    required String title,
    required VoidCallback onPressed,
  }) {
    final itemWidth = (MediaQuery.of(context).size.width - 56) / 2;
    return SizedBox(
      width: itemWidth.clamp(150, 240),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 92,
                  width: 92,
                  decoration: BoxDecoration(
                    color: Color(0xFFEAF6FF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Image.asset(imageAsset),
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172B4D),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Sentuh untuk mulai',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
