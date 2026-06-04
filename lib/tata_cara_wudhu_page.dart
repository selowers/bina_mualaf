import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/user.dart';

class WudhuStep {
  String title;
  String paragraph;
  String arabic;
  String latin;
  String? translation;

  WudhuStep({
    required this.title,
    required this.paragraph,
    required this.arabic,
    required this.latin,
    this.translation,
  });

  factory WudhuStep.fromJson(Map<String, dynamic> json) {
    return WudhuStep(
      title: json['title'] as String,
      paragraph: json['paragraph'] as String,
      arabic: json['arabic'] as String,
      latin: json['latin'] as String,
      translation: json['translation'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'paragraph': paragraph,
        'arabic': arabic,
        'latin': latin,
        'translation': translation,
      };
}

class TataCaraWudhuPage extends StatefulWidget {
  final bool enableCrud;

  const TataCaraWudhuPage({super.key, this.enableCrud = false});

  @override
  _TataCaraWudhuPageState createState() => _TataCaraWudhuPageState();
}

class _TataCaraWudhuPageState extends State<TataCaraWudhuPage> {
  User? _currentUser;
  bool _wudhuChecked = false;
  bool _isLoading = true;
  late String _prefsKey;
  late String _contentKey;
  List<WudhuStep> _steps = [];

  @override
  void initState() {
    super.initState();
    _loadUserAndState();
  }

  Future<void> _loadUserAndState() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      final currentUser = User.fromJson(json.decode(userJson));
      _prefsKey = 'wudhu_checked_${currentUser.id}';
      _contentKey = 'wudhu_steps_${currentUser.id}';
      final checkedString = prefs.getString(_prefsKey);
      final steps = await _loadSteps(_contentKey);
      setState(() {
        _currentUser = currentUser;
        _wudhuChecked = checkedString != null && json.decode(checkedString) == true;
        _steps = steps;
        _isLoading = false;
      });
    } else {
      _contentKey = 'wudhu_steps_guest';
      _steps = _defaultSteps();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveWudhuState(bool value) async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      json.encode(value),
    );
  }

  Future<List<WudhuStep>> _loadSteps(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) {
      return _defaultSteps();
    }
    final decoded = json.decode(jsonString) as List<dynamic>;
    return decoded
        .map((jsonItem) => WudhuStep.fromJson(jsonItem as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveSteps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_contentKey, json.encode(_steps.map((e) => e.toJson()).toList()));
  }

  void _openWudhuStepDialog({WudhuStep? step, int? index}) {
    final titleController = TextEditingController(text: step?.title ?? '');
    final paragraphController = TextEditingController(text: step?.paragraph ?? '');
    final arabicController = TextEditingController(text: step?.arabic ?? '');
    final latinController = TextEditingController(text: step?.latin ?? '');
    final translationController = TextEditingController(text: step?.translation ?? '');

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(step == null ? 'Tambah Langkah Wudhu' : 'Ubah Langkah Wudhu'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Judul'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: paragraphController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  maxLines: null,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: arabicController,
                  decoration: const InputDecoration(labelText: 'Teks Arab'),
                  maxLines: null,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: latinController,
                  decoration: const InputDecoration(labelText: 'Latin'),
                  maxLines: null,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: translationController,
                  decoration: const InputDecoration(labelText: 'Terjemahan (opsional)'),
                  maxLines: null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final newStep = WudhuStep(
                  title: titleController.text.trim(),
                  paragraph: paragraphController.text.trim(),
                  arabic: arabicController.text.trim(),
                  latin: latinController.text.trim(),
                  translation: translationController.text.trim().isEmpty
                      ? null
                      : translationController.text.trim(),
                );
                setState(() {
                  if (index == null) {
                    _steps.add(newStep);
                  } else {
                    _steps[index] = newStep;
                  }
                });
                await _saveSteps();
                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteWudhuStep(int index) async {
    setState(() {
      _steps.removeAt(index);
    });
    await _saveSteps();
  }

  List<WudhuStep> _defaultSteps() {
    return [
      WudhuStep(
        title: '1. Niat dan Membasuh Telapak Tangan',
        paragraph:
            'Niat: Baca niat wudhu di dalam hati bersamaan dengan membasuh wajah.',
        arabic:
            'نَوَيْتُ الْوُضُوْءَ لِرَفْعِ الْحَدَثِ اْلاَصْغَرِ فَرْضًا لِلّٰهِ تَعَالَى',
        latin:
            'Nawaitul wudhuu-a liraf\'il hadatsil ashghari fardhal lillaahi ta\'aalaa.',
        translation:
            'Saya niat berwudhu untuk menghilangkan hadas kecil, fardhu karena Allah Ta\'ala.',
      ),
      WudhuStep(
        title: '2. Berkumur dan Membersihkan Hidung',
        paragraph:
            'Berkumur: Berkumur 3 kali sambil membaca doa. Membersihkan hidung dengan istinsyaq juga 3 kali.',
        arabic:
            'اَللّٰهُمَّ أَعِنِّيْ عَلَى ذِكْرِكَ وَشُكْرِكَ، وَحُسْنِ عِبَادَتِكَ',
        latin:
            'Allaahumma a\'innii \`alaa dzikrika wa syukrika wa husni \`ibaadatik.',
      ),
      WudhuStep(
        title: '3. Membasuh Wajah',
        paragraph:
            'Basuh seluruh wajah dari tempat tumbuhnya rambut hingga bawah dagu, dan dari telinga ke telinga sebanyak 3 kali.',
        arabic:
            'اَللّٰهُمَّ بَيِّضْ وَجْهِيْ يَوْمَ تَبْيَضُّ وُجُوْهٌ وَتَسْوَدُّ وُجُوْهٌ',
        latin:
            'Allaahumma bayyidh wajhiya yauma tabyadldhu wujuuhun wa taswaddu wujuuh.',
      ),
      WudhuStep(
        title: '4. Membasuh Kedua Tangan',
        paragraph:
            'Basuh tangan kanan lalu tangan kiri hingga ke siku sebanyak 3 kali.',
        arabic: 'اَللّٰهُمَّ أَعْطِنِيْ كِتَابِيْ بِيَمِيْنِيْ',
        latin: 'Allaahumma a\'thinii kitaabii biyamiinih.',
      ),
      WudhuStep(
        title: '5. Mengusap Kepala dan Telinga',
        paragraph:
            'Usap sebagian atau seluruh rambut kepala sebanyak 3 kali sambil membaca doa.',
        arabic:
            'اَللّٰهُمَّ حَرِّمْ شَعْرِيْ وَبَشَرِيْ عَلَى النَّارِ',
        latin:
            'Allaahumma harrim sya\'rii wa basyarii \`alannar.',
      ),
      WudhuStep(
        title: '6. Membasuh Kaki',
        paragraph:
            'Membasuh kaki kanan lalu kiri hingga ke atas mata kaki sebanyak 3 kali sambil menyela-nyela jari kaki.',
        arabic:
            'اَللّٰهُمَّ ثَبِّتْ قَدَمَيَّ عَلَى الصِّرَاطِ يَوْمَ تَزِلُّ فِيهِ الْأَقْدَامُ',
        latin:
            'Allaahumma tsabbit qadamayya \`alash-shiraathi yauma tazillu fiihil aqdaam.',
      ),
      WudhuStep(
        title: '7. Doa Setelah Wudhu',
        paragraph: 'Setelah selesai, disunnahkan membaca doa berikut ini.',
        arabic:
            'أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا اللّٰهُ وَحْدَهُ لَا شَرِيْكَ لَهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُوْلُهُ. اَللّٰهُمَّ اجْعَلْنِيْ مِنَ التَّوَّابِيْنَ، وَاجْعَلْنِيْ مِنَ الْمُتَطَهِّرِيْنَ، وَاجْعَلْنِيْ مِنْ عِبَادِكَ الصَّالِحِيْنَ',
        latin:
            'Asyhadu an laa ilaaha illallaah wahdahu laa syariika lah, wa asyhadu anna muhammadan \`abduhu wa rasuuluh. Allaahummaj\'alnii minat-tawwaabiina, waj\'alnii minal mutathahhiriina, waj\'alnii min \`ibaadikash-shaalihiin.',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tata Cara Wudhu'"),
        backgroundColor: const Color(0xFF4A8CF7),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF6FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset('assets/wudu.png'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Tata Cara Wudhu'",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Panduan wudhu lengkap dengan doa untuk setiap langkah.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                color: const Color(0xFFEAF6FF),
                child: CheckboxListTile(
                  value: _wudhuChecked,
                  onChanged: (value) async {
                    if (value == null) return;
                    setState(() {
                      _wudhuChecked = value;
                    });
                    await _saveWudhuState(value);
                  },
                  title: const Text(
                    'Tandai jika sudah selesai Wudhu',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Centang untuk menghitung pencapaian Wudhu di ringkasan.',
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: const Color(0xFF4A8CF7),
                ),
              ),
                            const SizedBox(height: 20),
              for (var index = 0; index < _steps.length; index++) ...[
                _buildWudhuStepCard(_steps[index], index),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.enableCrud
          ? FloatingActionButton.extended(
              onPressed: () => _openWudhuStepDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Langkah'),
              backgroundColor: const Color(0xFF4A8CF7),
            )
          : null,
    );
  }

  Widget _buildStepCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildWudhuStepCard(WudhuStep step, int index) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  step.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              if (widget.enableCrud)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF4A8CF7)),
                      onPressed: () => _openWudhuStepDialog(step: step, index: index),
                      tooltip: 'Ubah langkah',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _deleteWudhuStep(index),
                      tooltip: 'Hapus langkah',
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 14),
          _buildParagraph(step.paragraph),
          if (step.arabic.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildQuote(
              arabic: step.arabic,
              latin: step.latin,
              translation: step.translation,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
    );
  }

  Widget _buildSubtitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4A8CF7),
      ),
    );
  }

  Widget _buildQuote({
    required String arabic,
    required String latin,
    String? translation,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            arabic,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Latin: $latin',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          if (translation != null) ...[
            const SizedBox(height: 10),
            Text(
              translation,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

