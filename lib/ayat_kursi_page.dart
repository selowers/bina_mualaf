// ignore_for_file: prefer_const_constructors, duplicate_ignore

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AyatKursi extends StatefulWidget {
  final String userId;
  final bool enableCrud;

  const AyatKursi({super.key, String? userId, this.enableCrud = false})
    : userId = userId ?? 'guest';

  @override
  // ignore: library_private_types_in_public_api
  _AyatKursiState createState() => _AyatKursiState();
}

class _AyatKursiState extends State<AyatKursi> {
  late String _prefsKey;
  late String _contentKey;
  bool _checked = false;
  String _tafsir =
      '''Allah adalah Tuhan Yang Maha Esa, tidak ada tuhan selain Dia, dan hanya Dia yang berhak untuk disembah. Adapun tuhan-tuhan yang lain yang disembah oleh sebagian manusia dengan alasan yang tidak benar, memang banyak jumlahnya. Akan tetapi Tuhan yang sebenarnya hanyalah Allah. Hanya Dialah Yang hidup abadi, yang ada dengan sendiri-Nya, dan Dia pulalah yang selalu mengatur makhluk-Nya tanpa ada kelalaian sedikit pun.

Kemudian ditegaskan lagi bahwa Allah tidak pernah mengantuk. Orang yang berada dalam keadaan mengantuk tentu hilang kesadarannya, sehingga dia tidak akan dapat melakukan pekerjaannya dengan baik, padahal Allah swt senantiasa mengurus dan memelihara makhluk-Nya dengan baik, tidak pernah kehilangan kesadaran atau pun lalai.

Karena Allah tidak pernah mengantuk, sudah tentu Dia tidak pernah tidur, karena mengantuk adalah permulaan dari proses tidur. Orang yang tidur lebih banyak kehilangan kesadaran daripada orang yang mengantuk. Orang yang tidur lebih banyak kehilangan kesadaran daripada orang yang mengantuk. Karena Allah tidak pernah mengantuk, sudah tentu Dia tidak pernah tidur.''';
  String _ayatText =
      'اَللّٰهُ لَآ اِلٰهَ اِلَّا هُوَۚ اَلْحَيُّ الْقَيُّوْمُ ەۚ لَا تَأْخُذُهٗ سِنَةٌ وَّلَا نَوْمٌۗ  لَهٗ مَا فِى السَّمٰوٰتِ وَمَا فِى الْاَرْضِۗ مَنْ ذَا الَّذِيْ يَشْفَعُ عِنْدَهٗٓ اِلَّا بِاِذْنِهٖۗ يَعْلَمُ مَا بَيْنَ اَيْدِيْهِمْ وَمَا خَلْفَهُمْۚ وَلَا يُحِيْطُوْنَ بِشَيْءٍ مِّنْ عِلْمِهٖٓ اِلَّا بِمَا شَآءَۚ وَسِعَ كُرْسِيُّهُ السَّمٰوٰتِ وَالْاَرْضِۚ وَلَا يَـُٔوْدُهٗ حِفْظُهُمَاۚ وَهُوَ الْعَلِيُّ الْعَظِيْمُ';
  String _latin =
      'Allaahu laa ilaaha illaa huwal hayyul qoyyuum, laa ta’khudzuhuu sinatuw walaa naum. Lahuu maa fissamaawaati wa maa fil ardli man dzal ladzii yasyfa’u ‘indahuu illaa biidznih, ya’lamu maa baina aidiihim wa maa kholfahum wa laa yuhiithuuna bisyai’im min ‘ilmihii illaa bimaa syaa’ wasi’a kursiyyuhus samaawaati wal ardlo walaa ya’uuduhuu hifdhuhumaa wahuwal ‘aliyyul ‘adhiim.';
  String _translation =
      'Allah adalah Tuhan Yang Maha Hidup dan terus-menerus mengurus makhluk-Nya. Dia tidak mengantuk dan tidak pernah letih; segala sesuatu di langit dan di bumi berada dalam kekuasaan-Nya. Tidak ada yang dapat memberi syafaat kecuali dengan izin-Nya, dan ilmu-Nya meliputi segala sesuatu.';

  @override
  void initState() {
    super.initState();
    _prefsKey = 'ayat_kursi_checked_${widget.userId}';
    _contentKey = 'ayat_kursi_content';
    _loadChecked();
    _loadContent();
  }

  Future<void> _loadContent() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_contentKey);
    if (jsonString != null) {
      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      setState(() {
        _ayatText = decoded['ayat'] ?? _ayatText;
        _latin = decoded['latin'] ?? _latin;
        _translation = decoded['translation'] ?? _translation;
        _tafsir = decoded['tafsir'] ?? _tafsir;
      });
    }
  }

  Future<void> _saveContent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _contentKey,
      json.encode({
        'ayat': _ayatText,
        'latin': _latin,
        'translation': _translation,
        'tafsir': _tafsir,
      }),
    );
  }

  Future<void> _resetContent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_contentKey);
    await _loadContent();
  }

  Future<void> _loadChecked() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      final decoded = json.decode(jsonString);
      if (decoded is List && decoded.isNotEmpty && decoded[0] is bool) {
        setState(() {
          _checked = decoded[0] as bool;
        });
      }
    }
  }

  Future<void> _saveChecked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode([_checked]));
  }

  void _openAyatEditDialog() {
    final ayatController = TextEditingController(text: _ayatText);
    final latinController = TextEditingController(text: _latin);
    final translationController = TextEditingController(text: _translation);
    final tafsirController = TextEditingController(text: _tafsir);

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Ayat Kursi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ayatController,
                  maxLines: null,
                  decoration: const InputDecoration(labelText: 'Ayat (Arab)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: latinController,
                  maxLines: null,
                  decoration: const InputDecoration(labelText: 'Latin'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: translationController,
                  maxLines: null,
                  decoration: const InputDecoration(labelText: 'Terjemahan'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tafsirController,
                  maxLines: null,
                  decoration: const InputDecoration(labelText: 'Tafsir'),
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
                setState(() {
                  _ayatText = ayatController.text;
                  _latin = latinController.text;
                  _translation = translationController.text;
                  _tafsir = tafsirController.text;
                });
                await _saveContent();
                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayat Kursi'),
        backgroundColor: const Color(0xFFE0F7FA),
        actions: [
          if (widget.enableCrud)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _openAyatEditDialog,
              tooltip: 'Ubah Data',
            ),
          if (widget.enableCrud)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirmed =
                    await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Hapus Data'),
                        content: const Text(
                          'Reset konten Ayat Kursi ke versi bawaan?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    ) ??
                    false;
                if (confirmed) {
                  await _resetContent();
                }
              },
              tooltip: 'Reset Data',
            ),
        ],
      ),
      backgroundColor: const Color(0xFFE0F7FA),
      // floatingActionButton: widget.enableCrud
      //     ? FloatingActionButton.extended(
      //         onPressed: _openAyatEditDialog,
      //         label: const Text('Tambah / Ubah'),
      //         icon: const Icon(Icons.add),
      //         backgroundColor: const Color(0xff0e1446),
      //       )
      //     : null,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                // Align(
                //   alignment: Alignment.topLeft,
                //   child: IconButton(
                //     onPressed: () => Navigator.of(context).pop(),
                //     icon: const Icon(
                //       Icons.arrow_back,
                //       color: Color.fromARGB(255, 34, 26, 148),
                //     ),
                //   ),
                // ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.only(top: 80),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: const Color(0xFFB2EBF2),
                    ),
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      margin: const EdgeInsets.only(top: 120, left: 20),
                      // ignore: prefer_const_constructors
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        // ignore: prefer_const_literals_to_create_immutables
                        children: [
                          const Text(
                            "Ayat Kursi",
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Bacaan Ayat Kursi dengan tafsirnya",
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: ClipRRect(
                    // ignore: prefer_const_constructors
                    borderRadius: BorderRadius.only(
                      // ignore: prefer_const_constructors
                      topLeft: Radius.circular(30),
                      // ignore: prefer_const_constructors
                      bottomLeft: Radius.circular(30),
                      // ignore: prefer_const_constructors
                      bottomRight: Radius.circular(30),
                    ),
                    child: Image.asset(
                      "assets/bgquran.png",
                      width: 250,
                      height: 200,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Positioned(
                  top: 140,
                  left: 16,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Checkbox(
                        value: _checked,
                        onChanged: (value) {
                          setState(() {
                            _checked = value ?? false;
                          });
                          _saveChecked();
                        },
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 250, right: 20),
                    child: Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 120,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0e1446),
                        ),
                        child: Material(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.amber,
                            borderRadius: BorderRadius.circular(50),
                            onTap: () {
                              showDialog(
                                context: context,
                                // ignore: prefer_const_constructors
                                builder: (_) => AlertDialog(
                                  title: const Center(
                                    child: Text("Tafsir Ayat Kursi"),
                                  ),
                                  // ignore: prefer_const_constructors
                                  content: SingleChildScrollView(
                                    // ignore: prefer_const_constructors
                                    child: Text(
                                      _tafsir,
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Center(
                              child: Text(
                                "Tafsir",
                                style: TextStyle(
                                  letterSpacing: 2,
                                  fontSize: 18,
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                child: ListView(
                  children: [
                    Center(
                      child: Text(
                        "بِسْمِ اللَّـهِ الرَّحْمَـٰنِ الرَّحِيمِ",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Dengan menyebut nama Allah Yang Maha Pemurah lagi Maha Penyayang",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SelectableText(
                      "اَللّٰهُ لَآ اِلٰهَ اِلَّا هُوَۚ اَلْحَيُّ الْقَيٌّوْمُ ەۚ لَا تَأْخُذُهٗ سِنَةٌ وَّلَا نَوْمٌۗ  لَهٗ مَا فِى السَّمٰوٰتِ وَمَا فِى الْاَرْضِۗ مَنْ ذَا الَّذِيْ يَشْفَعُ عِنْدَهٗٓ اِلَّا بِاِذْنِهٖۗ يَعْلَمُ مَا بَيْنَ اَيْدِيْهِمْ وَمَا خَلْفَهُمْۚ وَلَا يُحِيْطُوْنَ بِشَيْءٍ مِّنْ عِلْمِهٖٓ اِلَّا بِمَا شَآءَۚ وَسِعَ كُرْسِيُّهُ السَّمٰوٰتِ وَالْاَرْضِۚ وَلَا يَـُٔوْدُهٗ حِفْظُهُمَاۚ وَهُوَ الْعَلِيُّ الْعَظِيْمُ",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      child: SelectableText(
                        "Allaahu laa ilaaha illaa huwal hayyul qoyyuum, laa ta’khudzuhuu sinatuw walaa naum. Lahuu maa fissamaawaati wa maa fil ardli man dzal ladzii yasyfa’u ‘indahuu illaa biidznih, ya’lamu maa baina aidiihim wamaa kholfahum wa laa yuhiithuuna bisyai’im min ‘ilmihii illaa bimaa syaa’ wasi’a kursiyyuhus samaawaati wal ardlo walaa ya’uuduhuu hifdhuhumaa wahuwal ‘aliyyul ‘adhiim.",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      child: SelectableText(
                        "Terjemahan : Allah, tidak ada tuhan selain dia. Yang Mahahidup, Yang terus menerus mengurus (makhluk-Nya), tidak mengantuk dan tidak tidur. Milik-Nya apa yang ada di langit dan apa yang ada di bumi. Tidak ada yang dapat memberi syafaat di sisi-Nya tanpa izin-Nya. Dia mengetahui apa yang di hadapan mereka dan apa yang di belakang mereka, dan mereka tidak mengetahui sesuatu apa pun tentang ilmu-Nya melainkan apa yang Dia kehendaki. Kursi-Nya meliputi langit dan bumi. Dan Dia tidak merasa berat memelihara keduanya, dan Dia Mahatinggi, Mahabesar.",
                        style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 14),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
