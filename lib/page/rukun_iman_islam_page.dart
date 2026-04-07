// ignore_for_file: depend_on_referenced_packages, library_prefixes, prefer_const_constructors, avoid_unnecessary_containers, duplicate_ignore, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:bina_mualaf/model/model_bacaan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class RukunImanIslam extends StatefulWidget {
  final String userId;

  const RukunImanIslam({super.key, String? userId}) : userId = userId ?? 'guest';

  @override
  // ignore: library_private_types_in_public_api
  _RukunImanIslamState createState() => _RukunImanIslamState();
}

class _RukunImanIslamState extends State<RukunImanIslam> {
  late String _prefsKey;
  late Future<List<ModelBacaan>> _itemsFuture;
  List<bool> _checked = [];

  @override
  void initState() {
    super.initState();
    _prefsKey = 'rukun_iman_islam_checked_${widget.userId}';
    _itemsFuture = _loadItems();
  }

  Future<List<ModelBacaan>> _loadItems() async {
    final items = await readJsonData();
    await _loadChecked(items.length);
    return items;
  }

  Future<void> _loadChecked(int count) async {
    final prefs = await SharedPreferences.getInstance();
    _checked = List<bool>.filled(count, false);
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      final list = json.decode(jsonString) as List<dynamic>;
      for (var i = 0; i < list.length && i < count; i++) {
        if (list[i] is bool) {
          _checked[i] = list[i] as bool;
        }
      }
    }
  }

  Future<void> _saveChecked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(_checked));
  }

  Future<List<ModelBacaan>> readJsonData() async {
    final jsondata = await rootBundle.rootBundle.loadString(
      'assets/rukunimanislam.json',
    );
    final list = json.decode(jsondata) as List<dynamic>;
    return list.map((e) => ModelBacaan.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(228, 47, 15, 1),
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
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.only(top: 80),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: const Color.fromARGB(255, 235, 225, 93),
                    ),
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      margin: const EdgeInsets.only(top: 120, left: 20),
                      // ignore: prefer_const_constructors
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Rukun Iman dan Islam",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Makna dan Penjelasan Rukun Iman dan Islam",
                            style: TextStyle(
                              color: Colors.white,
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
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Image.asset(
                      "assets/isisuratpendek.png",
                      width: 250,
                      height: 200,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                child: FutureBuilder(
                  future: _itemsFuture,
                  builder: (context, AsyncSnapshot<List<ModelBacaan>> data) {
                    if (data.hasError) {
                      return Center(child: Text("${data.error}"));
                    } else if (data.hasData) {
                      var items = data.data!;
                      return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                            margin: EdgeInsets.all(15),
                            child: Theme(
                              data: Theme.of(
                                context,
                              ).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                leading: Checkbox(
                                  value: _checked[index],
                                  onChanged: (value) {
                                    setState(() {
                                      _checked[index] = value ?? false;
                                    });
                                    _saveChecked();
                                  },
                                ),
                                title: Text(
                                  items[index].name.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(bottom: 8),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 8,
                                                    right: 8,
                                                  ),
                                                  child: Text(
                                                    items[index].latin
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 8,
                                                    right: 8,
                                                    top: 5,
                                                  ),
                                                  child: Text(
                                                    items[index].terjemahan
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
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
