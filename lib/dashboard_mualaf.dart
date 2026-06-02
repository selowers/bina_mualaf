import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

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
  Key _avatarKey = UniqueKey();

  final List<String> _achievementItems = [
    'Niat & Bacaan Sholat',
    'Ayat Kursi',
    'Rukun Iman & Islam',
    'Doa Keseharian',
    'Murotal',
  ];

  int _achievementChecked = 0;
  int _achievementTotal = 0;
  Map<String, int> _pageChecked = {};
  Map<String, int> _pageTotal = {};

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
        _avatarKey = UniqueKey();
      });
      await _loadAchievementProgress();
    }
  }

  int _countTrue(dynamic value) {
    if (value is bool) {
      return value ? 1 : 0;
    }
    if (value is List) {
      return value.fold(0, (sum, element) => sum + _countTrue(element));
    }
    return 0;
  }

  Future<int> _getCheckedCount(SharedPreferences prefs, String key) async {
    final jsonString = prefs.getString(key);
    if (jsonString == null) return 0;
    final decoded = json.decode(jsonString);
    return _countTrue(decoded);
  }

  Future<int> _getAssetItemCount(String assetPath) async {
    final jsonString = await rootBundle.rootBundle.loadString(assetPath);
    final decoded = json.decode(jsonString);
    if (decoded is List) {
      return decoded.length;
    }
    return 0;
  }

  Future<void> _loadAchievementProgress() async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    final userId = _currentUser!.id;

    final niatTotal = await _getAssetItemCount('assets/niatshalat.json');
    final bacaanTotal = await _getAssetItemCount('assets/bacaanshalat.json');
    final rukunTotal = await _getAssetItemCount('assets/rukunimanislam.json');
    final doaTotal = await _getAssetItemCount('assets/doakeseharian.json');
    final murotalTotal = await _getAssetItemCount('assets/murotal.json');
    const ayatKursiTotal = 1;

    final niatChecked = await _getCheckedCount(
      prefs,
      'niat_sholat_checked_$userId',
    );
    final rukunChecked = await _getCheckedCount(
      prefs,
      'rukun_iman_islam_checked_$userId',
    );
    final doaChecked = await _getCheckedCount(
      prefs,
      'doa_keseharian_checked_$userId',
    );
    final murotalChecked = await _getCheckedCount(
      prefs,
      'murotal_checked_$userId',
    );
    final ayatKursiChecked = await _getCheckedCount(
      prefs,
      'ayat_kursi_checked_$userId',
    );

    setState(() {
      _pageTotal = {
        'Niat & Bacaan Sholat': niatTotal + bacaanTotal,
        'Ayat Kursi': ayatKursiTotal,
        'Rukun Iman & Islam': rukunTotal,
        'Doa Keseharian': doaTotal,
        'Murotal': murotalTotal,
      };
      _pageChecked = {
        'Niat & Bacaan Sholat': niatChecked,
        'Ayat Kursi': ayatKursiChecked,
        'Rukun Iman & Islam': rukunChecked,
        'Doa Keseharian': doaChecked,
        'Murotal': murotalChecked,
      };
      _achievementTotal = _pageTotal.values.fold(0, (sum, item) => sum + item);
      _achievementChecked = _pageChecked.values.fold(
        0,
        (sum, item) => sum + item,
      );
    });
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

    final progress = _achievementTotal == 0
        ? 0.0
        : _achievementChecked / _achievementTotal;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Dashboard Calon Mualaf'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Akun',
            icon: _buildAvatarIcon(),
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit Profil'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditProfilePage(currentUser: _currentUser!),
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A8CF7), Color(0xFF5ED5FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(
                  title: 'Selamat Datang, ${_currentUser!.nama}',
                  subtitle:
                      'Jelajahi materi dan pelajari setiap langkah dengan penuh semangat!',
                  icon: Icons.star,
                ),
                const SizedBox(height: 24),
                _buildAchievementSection(progress),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    buildMenu(
                      imageAsset: 'assets/icniat.png',
                      title: 'Niat & Bacaan Sholat',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NiatSholat(userId: _currentUser!.id),
                          ),
                        ).then((_) => _loadAchievementProgress());
                      },
                    ),
                    buildMenu(
                      imageAsset: 'assets/icbacaan.png',
                      title: 'Ayat Kursi',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AyatKursi(userId: _currentUser!.id),
                          ),
                        ).then((_) => _loadAchievementProgress());
                      },
                    ),
                    buildMenu(
                      imageAsset: 'assets/informasi.png',
                      title: 'Informasi',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Informasi()),
                        ).then((_) => _loadAchievementProgress());
                      },
                    ),
                    buildMenu(
                      imageAsset: 'assets/suratpendek.png',
                      title: 'Rukun Iman & Islam',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RukunImanIslam(userId: _currentUser!.id),
                          ),
                        ).then((_) => _loadAchievementProgress());
                      },
                    ),
                    buildMenu(
                      imageAsset: 'assets/do_akeseharian.png',
                      title: "Do'a Keseharian",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DoaKeseharian(userId: _currentUser!.id),
                          ),
                        ).then((_) => _loadAchievementProgress());
                      },
                    ),
                    buildMenu(
                      imageAsset: 'assets/murotal.png',
                      title: 'Murotal',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Murotal(userId: _currentUser!.id),
                          ),
                        ).then((_) => _loadAchievementProgress());
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
      padding: const EdgeInsets.all(20),
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
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.star, color: Color(0xFF4A8CF7), size: 38),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
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

  Widget _buildAchievementSection(double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pencapaian Belajar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Progres ditentukan dari centang di setiap halaman materi.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  color: const Color(0xFF4A8CF7),
                  backgroundColor: const Color(0xFFE3F1FF),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A8CF7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Selesai $_achievementChecked dari $_achievementTotal kegiatan.',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _achievementItems.map((item) {
              final checked = _pageChecked[item] ?? 0;
              final total = _pageTotal[item] ?? 0;
              return Chip(
                label: Text('$item: $checked/$total'),
                backgroundColor: const Color(0xFFF1F8FF),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarIcon() {
    final hasValidAvatar =
        _currentUser!.avatarPath.isNotEmpty &&
        File(_currentUser!.avatarPath).existsSync();
    return CircleAvatar(
      key: _avatarKey,
      radius: 18,
      backgroundColor: Colors.white,
      backgroundImage: hasValidAvatar
          ? FileImage(File(_currentUser!.avatarPath)) as ImageProvider
          : null,
      child: !hasValidAvatar
          ? const Icon(Icons.person, color: Color(0xFF4A8CF7))
          : null,
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
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 92,
                  width: 92,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6FF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Image.asset(imageAsset),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172B4D),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sentuh untuk mulai',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
