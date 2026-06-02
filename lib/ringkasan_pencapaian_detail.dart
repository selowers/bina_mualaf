import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import 'model/user.dart';

class RingkasanPencapaianDetail extends StatefulWidget {
  final User calon;
  final List<String> achievementItems;
  final Map<String, bool> achievementStatus;

  const RingkasanPencapaianDetail({
    super.key,
    required this.calon,
    required this.achievementItems,
    required this.achievementStatus,
  });

  @override
  State<RingkasanPencapaianDetail> createState() =>
      _RingkasanPencapaianDetailState();
}

class _RingkasanPencapaianDetailState extends State<RingkasanPencapaianDetail> {
  late Future<List<_GroupProgress>> _groupProgressFuture;

  @override
  void initState() {
    super.initState();
    _groupProgressFuture = _loadGroupProgress();
  }

  Future<List<_GroupProgress>> _loadGroupProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final niatTotal = await _getAssetItemCount('assets/niatshalat.json');

    return [
      _GroupProgress(
        title: 'Niat & Bacaan Sholat',
        subgroups: [
          await _loadSubgroup(
            title: 'Niat Sholat',
            assetPath: 'assets/niatshalat.json',
            prefsKey: 'niat_sholat_checked_${widget.calon.id}',
            prefs: prefs,
            offset: 0,
          ),
          await _loadSubgroup(
            title: 'Bacaan Sholat',
            assetPath: 'assets/bacaanshalat.json',
            prefsKey: 'niat_sholat_checked_${widget.calon.id}',
            prefs: prefs,
            offset: niatTotal,
            fallbackPrefsKey: 'bacaan_sholat_checked',
          ),
        ],
      ),
      _GroupProgress(
        title: 'Ayat Kursi',
        subgroups: [await _loadAyatKursi(prefs)],
      ),
      _GroupProgress(
        title: 'Rukun Iman & Islam',
        subgroups: [
          await _loadSubgroup(
            title: 'Rukun Iman & Islam',
            assetPath: 'assets/rukunimanislam.json',
            prefsKey: 'rukun_iman_islam_checked_${widget.calon.id}',
            prefs: prefs,
          ),
        ],
      ),
      _GroupProgress(
        title: 'Doa Keseharian',
        subgroups: [
          await _loadSubgroup(
            title: 'Doa Keseharian',
            assetPath: 'assets/doakeseharian.json',
            prefsKey: 'doa_keseharian_checked_${widget.calon.id}',
            prefs: prefs,
          ),
        ],
      ),
      _GroupProgress(
        title: 'Murotal',
        subgroups: [
          await _loadSubgroup(
            title: 'Murotal',
            assetPath: 'assets/murotal.json',
            prefsKey: 'murotal_checked_${widget.calon.id}',
            prefs: prefs,
          ),
        ],
      ),
    ];
  }

  Future<_SubgroupProgress> _loadSubgroup({
    required String title,
    required String assetPath,
    required String prefsKey,
    required SharedPreferences prefs,
    int offset = 0,
    String? fallbackPrefsKey,
  }) async {
    final titles = await _loadAssetTitles(assetPath);
    final keyToUse = prefs.containsKey(prefsKey)
        ? prefsKey
        : (fallbackPrefsKey ?? prefsKey);
    final useOffset = keyToUse == fallbackPrefsKey ? offset : 0;
    final statuses = await _loadCheckedStatuses(
      prefs,
      keyToUse,
      titles.length,
      useOffset,
    );
    final checkedCount = statuses.where((isChecked) => isChecked).length;
    return _SubgroupProgress(
      title: title,
      checkedCount: checkedCount,
      totalCount: titles.length,
      itemTitles: titles,
      itemStatuses: statuses,
    );
  }

  Future<_SubgroupProgress> _loadAyatKursi(SharedPreferences prefs) async {
    final statuses = await _loadCheckedStatuses(
      prefs,
      'ayat_kursi_checked_${widget.calon.id}',
      1,
    );
    final checkedCount = statuses.where((isChecked) => isChecked).length;
    return _SubgroupProgress(
      title: 'Ayat Kursi',
      checkedCount: checkedCount,
      totalCount: 1,
      itemTitles: ['Ayat Kursi'],
      itemStatuses: statuses,
    );
  }

  Future<List<String>> _loadAssetTitles(String assetPath) async {
    final jsonString = await rootBundle.rootBundle.loadString(assetPath);
    final decoded = json.decode(jsonString);
    if (decoded is List) {
      return decoded.map((item) {
        if (item is Map<String, dynamic>) {
          return item['name']?.toString() ??
              item['title']?.toString() ??
              item['arabic']?.toString() ??
              'Materi';
        }
        return item.toString();
      }).toList();
    }
    return [];
  }

  Future<int> _getAssetItemCount(String assetPath) async {
    final jsonString = await rootBundle.rootBundle.loadString(assetPath);
    final decoded = json.decode(jsonString);
    if (decoded is List) {
      return decoded.length;
    }
    return 0;
  }

  Future<int> _getCheckedCount(SharedPreferences prefs, String key) async {
    final jsonString = prefs.getString(key);
    if (jsonString == null) return 0;
    final decoded = json.decode(jsonString);
    return _countTrue(decoded);
  }

  Future<List<bool>> _loadCheckedStatuses(
    SharedPreferences prefs,
    String key,
    int length, [
    int offset = 0,
  ]) async {
    final jsonString = prefs.getString(key);
    if (jsonString == null) {
      return List<bool>.filled(length, false);
    }

    final decoded = json.decode(jsonString);
    final flattened = _flattenBooleans(decoded);
    final statuses = List<bool>.filled(length, false);
    for (var i = 0; i < length; i++) {
      final flatIndex = offset + i;
      if (flatIndex < flattened.length) {
        statuses[i] = flattened[flatIndex];
      }
    }
    return statuses;
  }

  List<bool> _flattenBooleans(dynamic decoded) {
    if (decoded is bool) {
      return [decoded];
    }
    if (decoded is num) {
      return [decoded != 0];
    }
    if (decoded is String) {
      return [decoded.toLowerCase() == 'true'];
    }
    if (decoded is List) {
      return decoded.expand((item) => _flattenBooleans(item)).toList();
    }
    if (decoded is Map) {
      return decoded.values.expand((item) => _flattenBooleans(item)).toList();
    }
    return [];
  }

  int _countTrue(dynamic value) {
    if (value is bool) {
      return value ? 1 : 0;
    }
    if (value is List) {
      return value.fold(0, (sum, element) => sum + _countTrue(element));
    }
    if (value is Map) {
      return value.values.fold(0, (sum, element) => sum + _countTrue(element));
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pencapaian'),
        backgroundColor: const Color(0xFF4A8CF7),
      ),
      body: SafeArea(
        child: FutureBuilder<List<_GroupProgress>>(
          future: _groupProgressFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Gagal memuat detail progres: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final groups = snapshot.data ?? [];
            final totalSubItems = groups.fold<int>(
              0,
              (sum, group) => sum + group.totalCount,
            );
            final completedSubItems = groups.fold<int>(
              0,
              (sum, group) => sum + group.checkedCount,
            );
            final overallPercent = totalSubItems == 0
                ? 0.0
                : completedSubItems / totalSubItems;
            final overallPercentDisplay =
                overallPercent > 0 && overallPercent < 0.01
                ? 0.01
                : overallPercent;
            final overallPercentLabel = overallPercent == 0
                ? '0%'
                : '${(overallPercent * 100).ceil()}%';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFF4A8CF7),
                        child: Text(
                          widget.calon.nama.isNotEmpty
                              ? widget.calon.nama[0].toUpperCase()
                              : 'C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.calon.nama,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.calon.email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        overallPercentLabel,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A8CF7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Ringkasan Progres',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: overallPercentDisplay,
                      minHeight: 12,
                      backgroundColor: const Color(0xFFE3F1FF),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF4A8CF7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Selesai $completedSubItems dari $totalSubItems sub-materi',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sub-materi selesai $completedSubItems dari $totalSubItems',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Detail Materi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...groups.map((group) => _buildGroupCard(group)).toList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGroupCard(_GroupProgress group) {
    final done = group.isComplete;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: done ? const Color(0xFFE8F7FF) : const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done ? const Color(0xFF4A8CF7) : const Color(0xFFDADADA),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Text(
          group.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: done ? const Color(0xFF0F3A7D) : Colors.black87,
          ),
        ),
        subtitle: Text(
          '${group.checkedCount} dari ${group.totalCount} sub-materi selesai',
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: Icon(
          done ? Icons.check_circle : Icons.expand_more,
          color: done ? const Color(0xFF4A8CF7) : Colors.black54,
        ),
        children: group.subgroups.map(_buildSubgroupCard).toList(),
      ),
    );
  }

  Widget _buildSubgroupCard(_SubgroupProgress subgroup) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            subgroup.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          '${subgroup.checkedCount} dari ${subgroup.totalCount} sub-materi selesai',
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        ...subgroup.itemTitles.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final isChecked =
              index < subgroup.itemStatuses.length &&
              subgroup.itemStatuses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: null,
                  activeColor: const Color(0xFF4A8CF7),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isChecked ? Colors.black87 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isChecked
                            ? 'Tercentang oleh mualaf'
                            : 'Belum dicentang oleh mualaf',
                        style: TextStyle(
                          fontSize: 12,
                          color: isChecked
                              ? const Color(0xFF4A8CF7)
                              : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _GroupProgress {
  final String title;
  final List<_SubgroupProgress> subgroups;

  _GroupProgress({required this.title, required this.subgroups});

  int get checkedCount =>
      subgroups.fold(0, (sum, subgroup) => sum + subgroup.checkedCount);

  int get totalCount =>
      subgroups.fold(0, (sum, subgroup) => sum + subgroup.totalCount);

  bool get isComplete => totalCount > 0 && checkedCount >= totalCount;
}

class _SubgroupProgress {
  final String title;
  final int checkedCount;
  final int totalCount;
  final List<String> itemTitles;
  final List<bool> itemStatuses;

  _SubgroupProgress({
    required this.title,
    required this.checkedCount,
    required this.totalCount,
    required this.itemTitles,
    required this.itemStatuses,
  });
}
