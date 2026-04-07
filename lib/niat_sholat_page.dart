// ignore_for_file: depend_on_referenced_packages, library_prefixes, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers

import 'dart:convert';

// ignore: duplicate_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import 'model/model_niat.dart';

class SholatSection {
  final String title;
  final List<ModelNiat> items;

  SholatSection({required this.title, required this.items});
}

class NiatSholat extends StatefulWidget {
  final String userId;

  const NiatSholat({super.key, String? userId}) : userId = userId ?? 'guest';

  @override
  // ignore: library_private_types_in_public_api
  _NiatSholatState createState() => _NiatSholatState();
}

class _NiatSholatState extends State<NiatSholat> {
  late String _prefsKey;
  late Future<List<SholatSection>> _sectionsFuture;
  List<List<bool>> _sectionChecked = [];

  @override
  void initState() {
    super.initState();
    _prefsKey = 'niat_sholat_checked_${widget.userId}';
    _sectionsFuture = _loadSections();
  }

  Future<List<SholatSection>> _loadSections() async {
    final sections = await readJsonData();
    await _loadSectionChecks(sections);
    return sections;
  }

  Future<void> _loadSectionChecks(List<SholatSection> sections) async {
    final prefs = await SharedPreferences.getInstance();
    _sectionChecked = sections
        .map((section) => List<bool>.filled(section.items.length, false))
        .toList();

    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      final decoded = json.decode(jsonString) as List<dynamic>;
      for (var i = 0; i < decoded.length && i < sections.length; i++) {
        final sectionList = decoded[i] as List<dynamic>;
        for (
          var j = 0;
          j < sectionList.length && j < sections[i].items.length;
          j++
        ) {
          if (sectionList[j] is bool) {
            _sectionChecked[i][j] = sectionList[j] as bool;
          }
        }
      }
    }
  }

  Future<void> _saveSectionChecks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(_sectionChecked));
  }

  void _ensureChecked(List<SholatSection> sections) {
    var shouldInit = _sectionChecked.length != sections.length;
    if (!shouldInit) {
      for (var i = 0; i < sections.length; i++) {
        if (_sectionChecked[i].length != sections[i].items.length) {
          shouldInit = true;
          break;
        }
      }
    }
    if (shouldInit) {
      _sectionChecked = sections
          .map((section) => List<bool>.filled(section.items.length, false))
          .toList();
    }
  }

  Future<List<SholatSection>> readJsonData() async {
    final niatJson = await rootBundle.rootBundle.loadString(
      'assets/niatshalat.json',
    );
    final bacaanJson = await rootBundle.rootBundle.loadString(
      'assets/bacaanshalat.json',
    );

    final niatList = (json.decode(niatJson) as List<dynamic>)
        .map((e) => ModelNiat.fromJson(e))
        .toList();
    final bacaanList = (json.decode(bacaanJson) as List<dynamic>)
        .map((e) => ModelNiat.fromJson(e))
        .toList();

    return [
      SholatSection(title: 'Niat Sholat', items: niatList),
      SholatSection(title: 'Bacaan Sholat', items: bacaanList),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 114, 89, 224),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: EdgeInsets.only(top: 80),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Color.fromARGB(255, 95, 207, 235),
                    ),
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      margin: EdgeInsets.only(top: 120, left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Niat dan Bacaan Sholat",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Kumpulan niat dan bacaan sholat dalam satu halaman",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
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
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Image.asset(
                      "assets/bgsholat.png",
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                child: FutureBuilder(
                  future: _sectionsFuture,
                  builder: (context, data) {
                    if (data.hasError) {
                      return Center(child: Text("${data.error}"));
                    } else if (data.hasData) {
                      var sections = data.data as List<SholatSection>;
                      _ensureChecked(sections);
                      final childrenWidgets = <Widget>[];

                      for (
                        var sectionIndex = 0;
                        sectionIndex < sections.length;
                        sectionIndex++
                      ) {
                        final section = sections[sectionIndex];
                        childrenWidgets.add(
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            child: Text(
                              section.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );

                        for (
                          var itemIndex = 0;
                          itemIndex < section.items.length;
                          itemIndex++
                        ) {
                          final item = section.items[itemIndex];
                          childrenWidgets.add(
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                              margin: EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 8,
                              ),
                              child: Theme(
                                data: Theme.of(
                                  context,
                                ).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  leading: Checkbox(
                                    value:
                                        _sectionChecked[sectionIndex][itemIndex],
                                    onChanged: (value) {
                                      setState(() {
                                        _sectionChecked[sectionIndex][itemIndex] =
                                            value ?? false;
                                      });
                                      _saveSectionChecks();
                                    },
                                  ),
                                  title: Text(
                                    item.name.toString(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              item.arabic.toString(),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 6,
                                            ),
                                            child: Text(
                                              item.latin.toString(),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              item.terjemahan.toString(),
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      }

                      return ListView(children: childrenWidgets);
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
