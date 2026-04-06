import 'package:bina_mualaf/page/doa_keseharian_page.dart';
import 'package:bina_mualaf/page/murotal.dart';
import 'package:bina_mualaf/page/rukun_iman_islam_page.dart';
import 'package:flutter/material.dart';
import 'ayat_kursi_page.dart';
import 'bacaan_sholat_page.dart';
import 'information.dart';
import 'niat_sholat_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 115, 217, 243),
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
                    title: "Niat Sholat",
                    onPressed: () {
                      Navigator.push(
                        context,
                        // ignore: prefer_const_constructors
                        MaterialPageRoute(builder: (context) => NiatSholat()),
                      );
                    },
                  ),
                  // ignore: prefer_const_constructors
                  SizedBox(height: 40),
                  buildMenu(
                    imageAsset: "assets/icdoa.png",
                    title: "Bacaan Sholat",
                    onPressed: () {
                      Navigator.push(
                        context,
                        // ignore: prefer_const_constructors
                        MaterialPageRoute(builder: (context) => BacaanSholat()),
                      );
                    },
                  ),
                  // ignore: prefer_const_constructors
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ignore: prefer_const_constructors
                  SizedBox(height: 40),
                  buildMenu(
                    imageAsset: "assets/icbacaan.png",
                    title: "Ayat Kursi",
                    onPressed: () {
                      Navigator.push(
                        context,
                        // ignore: prefer_const_constructors
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
                  )
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
                        // ignore: prefer_const_constructors
                        MaterialPageRoute(
                            builder: (context) => RukunImanIslam()),
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
                            builder: (context) => DoaKeseharian()),
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
                        MaterialPageRoute(builder: (context) => Murotal()),
                      );
                    },
                  ),
                ],
              )
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
    return Container(
      // ignore: prefer_const_constructors
      margin: EdgeInsets.all(10),
      child: Expanded(
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: onPressed,
          child: Column(
            children: [
              Image(
                image: AssetImage(imageAsset),
                height: 100,
                width: 100,
              ),
              // ignore: prefer_const_constructors
              SizedBox(height: 10),
              Text(
                title,
                // ignore: prefer_const_constructors
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void information() {}
}
