// ignore_for_file: depend_on_referenced_packages, library_prefixes, prefer_const_constructors, avoid_unnecessary_containers, duplicate_ignore, prefer_const_literals_to_create_immutables, use_super_parameters, unused_import

import 'dart:async';
import 'dart:convert';

import 'package:bina_mualaf/model/model_murotal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class Murotal extends StatefulWidget {
  final String userId;
  final bool enableCrud;

  const Murotal({Key? key, String? userId, this.enableCrud = false})
    : userId = userId ?? 'guest',
      super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MurotalState createState() => _MurotalState();
}

class _MurotalState extends State<Murotal> {
  late String _prefsKey;
  late AudioPlayer player = AudioPlayer();
  PlayerState? _playerState;
  List<bool> _checked = [];
  late Future<List<ModelBacaanSuara>> _itemsFuture;
  late String _contentKey;

  @override
  void initState() {
    super.initState();
    _prefsKey = 'murotal_checked_${widget.userId}';
    _itemsFuture = _loadItems();

    // Create the audio player.
    player = AudioPlayer();

    // Set the release mode to keep the source after playback has completed.
    player.setReleaseMode(ReleaseMode.stop);

    player.getDuration().then(
      (value) => setState(() {
        _duration = value;
      }),
    );
    player.getCurrentPosition().then(
      (value) => setState(() {
        _position = value;
      }),
    );
    _initStreams();
  }

  Future<List<ModelBacaanSuara>> _loadItems() async {
    final items = await readJsonData();
    _contentKey = 'murotal_content_${widget.userId}';
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_contentKey);
    if (jsonString != null) {
      try {
        final decoded = json.decode(jsonString) as List<dynamic>;
        final loaded = decoded
            .map((e) => ModelBacaanSuara.fromJson(e as Map<String, dynamic>))
            .toList();
        await _loadChecked(loaded.length);
        return loaded;
      } catch (_) {}
    }
    await _loadChecked(items.length);
    return items;
  }

  Future<void> _saveItems(List<ModelBacaanSuara> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _contentKey,
      json.encode(items.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _ensureCheckedLength(int count) async {
    if (_checked.length < count) {
      _checked.addAll(List<bool>.filled(count - _checked.length, false));
    } else if (_checked.length > count) {
      _checked = _checked.sublist(0, count);
    }
    await _saveChecked();
  }

  void _openEditDialog([int? index]) {
    _itemsFuture.then((items) {
      final ModelBacaanSuara? item = (index != null) ? items[index] : null;
      final nameCtrl = TextEditingController(text: item?.name ?? '');
      final suaraCtrl = TextEditingController(text: item?.suara ?? '');
      showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(item == null ? 'Tambah' : 'Ubah'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Judul'),
                ),
                TextField(
                  controller: suaraCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Asset suara (path)',
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  final newItem = ModelBacaanSuara(
                    id: item?.id ?? DateTime.now().millisecondsSinceEpoch,
                    name: nameCtrl.text,
                    latin: item?.latin ?? '',
                    suara: suaraCtrl.text,
                  );
                  if (index == null) {
                    items.add(newItem);
                  } else {
                    items[index] = newItem;
                  }
                });
                await _saveItems(items);
                await _ensureCheckedLength(items.length);
                Navigator.pop(c);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _deleteItem(int index) async {
    _itemsFuture.then((items) async {
      setState(() {
        items.removeAt(index);
      });
      await _saveItems(items);
      await _ensureCheckedLength(items.length);
    });
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

  Duration? _position;
  Duration? _duration;
  bool get _isPlaying => _playerState == PlayerState.playing;
  bool get _isPaused => _playerState == PlayerState.paused;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  Future<List<ModelBacaanSuara>> readJsonData() async {
    final jsondata = await rootBundle.rootBundle.loadString(
      'assets/murotal.json',
    );
    final list = json.decode(jsondata) as List<dynamic>;
    return list.map((e) => ModelBacaanSuara.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
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
                        children: [
                          const Text(
                            "murotal penyejuk hati",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "lantunan musik penyejuk hati",
                            style: TextStyle(
                              color: Color.fromARGB(255, 236, 247, 246),
                              fontSize: 16,
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
                      "assets/isimurotal.png",
                      width: 200,
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
                  builder:
                      (context, AsyncSnapshot<List<ModelBacaanSuara>> data) {
                        if (data.hasError) {
                          return Center(child: Text("${data.error}"));
                        } else if (data.hasData) {
                          var items = data.data!;

                          return ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final player = AudioPlayer();
                              player.setSource(
                                AssetSource(items[index].suara.toString()),
                              );
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
                                      if (widget.enableCrud)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Color(0xFF4A8CF7),
                                              ),
                                              onPressed: () =>
                                                  _openEditDialog(index),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.redAccent,
                                              ),
                                              onPressed: () =>
                                                  _deleteItem(index),
                                            ),
                                          ],
                                        ),
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
                                                padding: EdgeInsets.only(
                                                  bottom: 8,
                                                ),
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
                                                        items[index].suara
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        left: 8,
                                                        right: 8,
                                                        top: 5,
                                                      ),
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          _isPlaying
                                                              ? null
                                                              : _play;
                                                          player.play(
                                                            AssetSource(
                                                              items[index].suara
                                                                  .toString(),
                                                            ),
                                                          );
                                                        },
                                                        child: Text("Play"),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        player.stop();
                                                      },
                                                      child: Text("Stop"),
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
      floatingActionButton: widget.enableCrud
          ? FloatingActionButton(
              onPressed: () => _openEditDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _initStreams() {
    _durationSubscription = player.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = player.onPositionChanged.listen(
      (p) => setState(() => _position = p),
    );

    _playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration.zero;
      });
    });

    _playerStateChangeSubscription = player.onPlayerStateChanged.listen((
      state,
    ) {
      setState(() {
        _playerState = state;
      });
    });
  }

  Future<void> _play() async {
    await player.resume();
    setState(() => _playerState = PlayerState.playing);
  }

  Future<void> _pause() async {
    await player.pause();
    setState(() => _playerState = PlayerState.paused);
  }

  Future<void> _stop() async {
    await player.stop();
    setState(() {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
    });
  }
}
