import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'model/user.dart';
import 'niat_sholat_page.dart';
import 'page/rukun_iman_islam_page.dart';
import 'page/doa_keseharian_page.dart';
import 'page/murotal.dart';
import 'ayat_kursi_page.dart';
import 'information.dart';

class DashboardMualaf extends StatefulWidget {
  const DashboardMualaf({super.key});

  @override
  _DashboardMualafState createState() => _DashboardMualafState();
}

class _DashboardMualafState extends State<DashboardMualaf> {
  User? _currentUser;

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
      });
    }
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

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 115, 217, 243),
      appBar: AppBar(
        title: Text('Dashboard Calon Mualaf - ${_currentUser!.nama}'),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: _logout)],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildMenu(
                    imageAsset: "assets/icniat.png",
                    title: "Niat Sholat dan Bacaan Sholat",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NiatSholat(userId: _currentUser!.id),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildMenu(
                    imageAsset: "assets/icbacaan.png",
                    title: "Ayat Kursi",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AyatKursi()),
                      );
                    },
                  ),
                  buildMenu(
                    imageAsset: "assets/informasi.png",
                    title: "informasi",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Informasi()),
                      );
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildMenu(
                    imageAsset: "assets/suratpendek.png",
                    title: "Rukun iman dan Islam",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RukunImanIslam(userId: _currentUser!.id),
                        ),
                      );
                    },
                  ),
                  buildMenu(
                    imageAsset: "assets/do_akeseharian.png",
                    title: "do'a keseharian",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DoaKeseharian(userId: _currentUser!.id),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildMenu(
                    imageAsset: "assets/murotal.png",
                    title: "murotal",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Murotal(userId: _currentUser!.id),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenu({
    required String imageAsset,
    required String title,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(10),
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: onPressed,
          child: Column(
            children: [
              Image(image: AssetImage(imageAsset), height: 100, width: 100),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
