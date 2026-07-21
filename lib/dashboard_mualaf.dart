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
import 'page/quiz_page.dart';
import 'ayat_kursi_page.dart';
import 'information.dart';
import 'tata_cara_wudhu_page.dart';
import 'edit_profile_page.dart';
import 'ringkasan_pencapaian_detail.dart';

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
    'Wudhu',
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
    final wudhuChecked = await _getCheckedCount(prefs, 'wudhu_checked_$userId');

    setState(() {
      _pageTotal = {
        'Niat & Bacaan Sholat': niatTotal + bacaanTotal,
        'Ayat Kursi': ayatKursiTotal,
        'Rukun Iman & Islam': rukunTotal,
        'Doa Keseharian': doaTotal,
        'Murotal': murotalTotal,
        'Wudhu': 1,
      };
      _pageChecked = {
        'Niat & Bacaan Sholat': niatChecked,
        'Ayat Kursi': ayatKursiChecked,
        'Rukun Iman & Islam': rukunChecked,
        'Doa Keseharian': doaChecked,
        'Murotal': murotalChecked,
        'Wudhu': wudhuChecked,
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
        title: const Text('Dashboard Mualaf'),
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
                      imageAsset: 'assets/quiz.png',
                      title: 'Quiz',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QuizPage(userId: _currentUser!.id),
                          ),
                        );
                      },
                    ),
                    buildMenu(
                      imageAsset: 'assets/pencapaian.png',
                      title: 'Ringkasan Pencapaian',
                      onPressed: () {
                        Navigator.push(
                          context,
                          _createRoute(
                            RingkasanPencapaianDetail(
                              calon: _currentUser!,
                              achievementItems: _achievementItems,
                              achievementStatus: _buildAchievementStatus(),
                            ),
                          ),
                        );
                      },
                    ),
                    buildMenu(
                      imageAsset: 'assets/wudu.png',
                      title: "Tata Cara Wudhu'",
                      onPressed: () {
                        Navigator.push(
                          context,
                          _createRoute(const TataCaraWudhuPage()),
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
    final percent = (progress * 100).round();

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
            'Lihat perkembanganmu dengan grafik interaktif dan ringkasan setiap materi.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 134,
                height: 134,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A8CF7), Color(0xFF5ED5FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 14,
                        color: Colors.white,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Dicapai',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_achievementChecked dari $_achievementTotal materi selesai',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildStatItem(
                      title: 'Materi lengkap',
                      value: '$_achievementChecked/$_achievementTotal',
                    ),
                    _buildStatItem(title: 'Perkembangan', value: '$percent%'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Pencapaian per materi',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                _createRoute(
                  RingkasanPencapaianDetail(
                    calon: _currentUser!,
                    achievementItems: _achievementItems,
                    achievementStatus: _buildAchievementStatus(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.timeline, size: 18),
            label: const Text('Lihat Ringkasan Lengkap'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A8CF7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 18),
          Column(
            children: _achievementItems.map((item) {
              final checked = _pageChecked[item] ?? 0;
              final total = _pageTotal[item] ?? 0;
              final itemProgress = total == 0 ? 0.0 : checked / total;
              final itemPercent = (itemProgress * 100).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E9FF)),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A8CF7).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$itemPercent%',
                              style: const TextStyle(
                                color: Color(0xFF4A8CF7),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            Container(
                              height: 10,
                              color: const Color(0xFFE3F1FF),
                            ),
                            FractionallySizedBox(
                              widthFactor: itemProgress.clamp(0.0, 1.0),
                              child: Container(
                                height: 10,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF4A8CF7),
                                      Color(0xFF80D7FF),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            '$checked dari $total langkah',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            total == 0
                                ? 'Belum tersedia'
                                : itemProgress >= 1.0
                                ? 'Selesai'
                                : 'Dalam proses',
                            style: TextStyle(
                              color: itemProgress >= 1.0
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFF4A8CF7),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A8CF7),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, bool> _buildAchievementStatus() {
    return {
      for (final item in _achievementItems)
        item:
            (_pageTotal[item] ?? 0) > 0 &&
            (_pageChecked[item] ?? 0) >= (_pageTotal[item] ?? 0),
    };
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

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.2, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 360),
    );
  }

  Color _menuAccentColor(String title) {
    switch (title) {
      case 'Niat & Bacaan Sholat':
        return const Color(0xFFDDE9FF);
      case 'Ayat Kursi':
        return const Color(0xFFE8F5E9);
      case 'Informasi':
        return const Color(0xFFFFF3E0);
      case 'Quiz':
        return const Color(0xFFFFF9C4);
      case "Tata Cara Wudhu'":
        return const Color(0xFFE0F7FA);
      case 'Ringkasan Pencapaian':
        return const Color(0xFFEDE7F6);
      case 'Rukun Iman & Islam':
        return const Color(0xFFFCE4EC);
      case "Do'a Keseharian":
        return const Color(0xFFE0F2F1);
      case 'Murotal':
        return const Color(0xFFF3E5F5);
      default:
        return const Color(0xFFF4F6FF);
    }
  }

  Widget buildMenu({
    required String imageAsset,
    required String title,
    required VoidCallback onPressed,
  }) {
    final itemWidth = (MediaQuery.of(context).size.width - 56) / 2;
    final accentColor = _menuAccentColor(title);
    return SizedBox(
      width: itemWidth.clamp(150, 240),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(22),
        color: accentColor.withOpacity(0.28),
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
                    color: accentColor.withOpacity(0.42),
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
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[900],
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
