import 'package:flutter/material.dart';

import 'package:iot_gps_kucing/app/themes/app_colors.dart';

class ProfilView extends StatelessWidget {
  final String judul = 'IOT GPS Kucing';
  final String nama = 'Ainun Mayada';
  final String nim = '217280078';
  final String pembimbing1 = "Ade Hastuti, ST., S. Kom., MT";
  final String pembimbing2 = "Ahmad Selao, S.Tp., M.Sc";
  final String penguji1 = "Ir. Untung Suwardoyo, S.Kom., MT";
  final String penguji2 = "Ferdinsyah Saing, S.Kom., M.Kom";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('IOT GPS Kucing'),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: secondaryColor,
                shape: BoxShape.rectangle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    offset: Offset(-5, 5), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 5),
                  Center(
                    child: Text(
                      'Informasi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(
                    thickness: 2,
                    color: dangerColor,
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      judul,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: Text(
                      '$nama \n$nim',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // const Divider(thickness: 1),
                  const SizedBox(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ..._dosenInfo("Pembimbing", 1, pembimbing1),
                      ..._dosenInfo("Pembimbing", 2, pembimbing2),
                      ..._dosenInfo("Penguji", 1, penguji1),
                      ..._dosenInfo("Penguji", 2, penguji2),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

List<Widget> _dosenInfo(String jenis, int angka, String nama) {
  return [
    ListTile(
      contentPadding: const EdgeInsets.all(0),
      leading: Text("$jenis $angka"),
      title: Transform.translate(
        offset: Offset(0, -5),
        child: Text(": $nama"),
      ),
      horizontalTitleGap: (jenis == 'Pembimbing' ? 29.0 : 55.0) -
          (angka + (jenis == 'Penguji' && angka == 2 ? 2 : 0)),
    ),
    Transform.translate(
      offset: Offset(0, -15),
      child: const Divider(
        height: 0,
        thickness: 0,
        color: warningColor,
      ),
    )
  ];
}
