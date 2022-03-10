import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:iot_gps_kucing/app/controllers/lokasi_controller.dart';
import 'package:iot_gps_kucing/app/themes/app_colors.dart';

import 'map_view.dart';
import 'histori_view.dart';

class LokasiView extends GetView<LokasiController> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Lokasi'),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.black,
            indicatorColor: bgColor,
            tabs: [
              Tab(
                text: "Map",
              ),
              Tab(
                text: "Histori",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MapView(),
            HistoriView(),
          ],
        ),
      ),
    );
  }
}
