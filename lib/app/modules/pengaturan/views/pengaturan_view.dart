import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:iot_gps_kucing/app/themes/app_colors.dart';

import '../controllers/pengaturan_controller.dart';

class PengaturanView extends GetView<PengaturanController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTileTheme(
          iconColor: dangerColor,
          tileColor: secondaryColor,
          style: ListTileStyle.list,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.location_searching),
                title: Text("Titik Koordinat"),
                subtitle: Text("Latitude : 0.00 \nLongitude : 0.00"),
                trailing: Icon(Icons.edit_location_alt),
                isThreeLine: true,
                onTap: () {
                  print("oke");
                },
              ),
              SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.radar),
                title: Text("Radius"),
                subtitle: Text("0 Meter"),
                trailing: Icon(Icons.edit_location_alt),
                onTap: () {
                  print("oke");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
