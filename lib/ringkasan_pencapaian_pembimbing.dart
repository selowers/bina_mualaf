import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import 'model/user.dart';
import 'ringkasan_pencapaian_detail.dart';

class RingkasanPencapaianPembimbing extends StatefulWidget {
  const RingkasanPencapaianPembimbing({super.key});

  @override
  _RingkasanPencapaianPembimbingState createState() =>
      _RingkasanPencapaianPembimbingState();
}

class _RingkasanPencapaianPembimbingState
    extends State<RingkasanPencapaianPembimbing>
    with WidgetsBindingObserver {
  final List<String> _achievementItems = [
    'Niat & Bacaan Sholat',
    'Ayat Kursi',
    'Rukun Iman & Islam',
    'Doa Keseharian',
    'Murotal',
    'Wudhu',
  ];

  List<User> _calonMualaf = [];
  Map<String, Map<String, bool>> _achievementStatus = {};
  final Map<String, int> _subItemCompletedCount = {};
  final Map<String, int> _subItemTotalCount = {};
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAchievementSummaries();
  }

  Future<void> _loadAchievementSummaries() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users') ?? '[]';
    final users = (json.decode(usersJson) as List<dynamic>)
        .map((e) => User.fromJson(e))
        .toList();

    final calonUsers = users
        .where((user) => user.role == 'calon_mualaf')
        .toList();
    final statuses = <String, Map<String, bool>>{};

    final niatTotal = await _getAssetItemCount('assets/niatshalat.json');
    final bacaanTotal = await _getAssetItemCount('assets/bacaanshalat.json');
    final rukunTotal = await _getAssetItemCount('assets/rukunimanislam.json');
    final doaTotal = await _getAssetItemCount('assets/doakeseharian.json');
    final murotalTotal = await _getAssetItemCount('assets/murotal.json');
    const ayatKursiTotal = 1;

    for (final calon in calonUsers) {
      final niatChecked = await _getCheckedCount(
        prefs,
        'niat_sholat_checked_${calon.id}',
      );
      final bacaanChecked = await _getCheckedCount(
        prefs,
        'bacaan_sholat_checked',
      );
      final ayatKursiChecked = await _getCheckedCount(
        prefs,
        'ayat_kursi_checked_${calon.id}',
      );
      final rukunChecked = await _getCheckedCount(
        prefs,
        'rukun_iman_islam_checked_${calon.id}',
      );
      final doaChecked = await _getCheckedCount(
        prefs,
        'doa_keseharian_checked_${calon.id}',
      );
      final murotalChecked = await _getCheckedCount(
        prefs,
        'murotal_checked_${calon.id}',
      );
      final wudhuChecked = await _getCheckedCount(
        prefs,
        'wudhu_checked_${calon.id}',
      );

      final completedSubItems =
          niatChecked +
          bacaanChecked +
          ayatKursiChecked +
          rukunChecked +
          doaChecked +
          murotalChecked +
          wudhuChecked;
      final totalSubItems =
          niatTotal +
          bacaanTotal +
          ayatKursiTotal +
          rukunTotal +
          doaTotal +
          murotalTotal +
          1;

      statuses[calon.id] = {
        'Niat & Bacaan Sholat':
            niatChecked + bacaanChecked >= niatTotal + bacaanTotal,
        'Ayat Kursi': ayatKursiChecked >= ayatKursiTotal,
        'Rukun Iman & Islam': rukunChecked >= rukunTotal,
        'Doa Keseharian': doaChecked >= doaTotal,
        'Murotal': murotalChecked >= murotalTotal,
        'Wudhu': wudhuChecked >= 1,
      };
      _subItemCompletedCount[calon.id] = completedSubItems;
      _subItemTotalCount[calon.id] = totalSubItems;
    }

    setState(() {
      _calonMualaf = calonUsers;
      _achievementStatus = statuses;
      _isLoading = false;
    });
  }

  int _completedCount(String userId) {
    final status = _achievementStatus[userId];
    if (status == null) return 0;
    return status.values.where((value) => value).length;
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadAchievementSummaries();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCalon = _searchQuery.isEmpty
        ? _calonMualaf
        : _calonMualaf.where((calon) {
            final query = _searchQuery.toLowerCase();
            return calon.nama.toLowerCase().contains(query) ||
                calon.email.toLowerCase().contains(query);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Pencapaian'),
        backgroundColor: const Color(0xFF4A8CF7),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _calonMualaf.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Belum ada calon mualaf terdaftar. Pencapaian akan muncul setelah calon mualaf mengakses dan mencentang materi mereka.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari calon mualaf...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: filteredCalon.isEmpty
                        ? const Center(
                            child: Text(
                              'Tidak ada calon mualaf sesuai pencarian.',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredCalon.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final calon = filteredCalon[index];
                              final completed =
                                  _subItemCompletedCount[calon.id] ?? 0;
                              final total =
                                  _subItemTotalCount[calon.id] ??
                                  _achievementItems.length;
                              final percent = total == 0
                                  ? 0.0
                                  : (completed / total);
                              final percentDisplay =
                                  percent > 0 && percent < 0.01
                                  ? 0.01
                                  : percent;
                              final percentLabel = percent == 0
                                  ? '0%'
                                  : '${(percent * 100).ceil()}%';

                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    _createRoute(
                                      RingkasanPencapaianDetail(
                                        calon: calon,
                                        achievementItems: _achievementItems,
                                        achievementStatus:
                                            _achievementStatus[calon.id] ?? {},
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: const Color(
                                                0xFF4A8CF7,
                                              ),
                                              child: Text(
                                                calon.nama.isNotEmpty
                                                    ? calon.nama[0]
                                                          .toUpperCase()
                                                    : 'C',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    calon.nama,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    calon.email,
                                                    style: const TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              percentLabel,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF4A8CF7),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: percentDisplay,
                                            minHeight: 10,
                                            backgroundColor: const Color(
                                              0xFFE3F1FF,
                                            ),
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  const Color(0xFF4A8CF7),
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        Wrap(
                                          runSpacing: 8,
                                          spacing: 8,
                                          children: _achievementItems.map((
                                            item,
                                          ) {
                                            final done =
                                                _achievementStatus[calon
                                                    .id]?[item] ??
                                                false;
                                            return Chip(
                                              label: Text(item),
                                              backgroundColor: done
                                                  ? const Color(0xFFE8F7FF)
                                                  : const Color(0xFFF5F5F5),
                                              avatar: Icon(
                                                done
                                                    ? Icons.check_circle
                                                    : Icons.circle_outlined,
                                                size: 18,
                                                color: done
                                                    ? const Color(0xFF4A8CF7)
                                                    : Colors.black38,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Selesai $completed dari $total sub-materi',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
