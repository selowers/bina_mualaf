// ignore_for_file: depend_on_referenced_packages, library_prefixes, prefer_const_constructors, avoid_unnecessary_containers, duplicate_ignore, prefer_const_literals_to_create_immutables, use_super_parameters, unused_import

import 'dart:async';
import 'dart:convert';

import 'package:bina_mualaf/model/model_murotal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:audioplayers/audioplayers.dart';

class Murotal extends StatefulWidget {
  const Murotal({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MurotalState createState() => _MurotalState();
}

class _MurotalState extends State<Murotal> {
  late AudioPlayer player = AudioPlayer();
  PlayerState? _playerState;
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
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 56, 168),
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
                      color: const Color.fromARGB(255, 97, 236, 236),
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
                  future: readJsonData(),
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
