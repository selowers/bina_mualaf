// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class Informasi extends StatefulWidget {
  const Informasi({super.key});

  @override
  _InformasiState createState() => _InformasiState();
}

class _InformasiState extends State<Informasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff44aca0),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ... Your existing code ...

            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Center(child: Text("informasi")),
                    content: SingleChildScrollView(
                      child: Text(
                        "Aplikasi ini digunakan untuk pembelajaran anak-anak yang dipergunakan agar anak-anak memahami agama islam dan bisa mempelajari bacaan-bacaan keseharian ",
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                );
              },
              child: Center(
                child: Text(
                  "Sumber Informasi",
                  style: TextStyle(
                    letterSpacing: 2,
                    fontSize: 18,
                    color: Color.fromARGB(255, 202, 45, 45),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                child: ListView(
                  children: [
                    // ... Your existing text widgets ...
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
