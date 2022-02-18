import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iot_gps_kucing/app/controllers/lokasi_controller.dart';
import 'package:iot_gps_kucing/app/themes/app_colors.dart';

class LokasiView extends GetView<LokasiController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lokasi'),
        centerTitle: true,
      ),
      body: Obx(
        () => controller.loading.value
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(12),
                    width: double.infinity,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          dense: true,
                          leading: Text("Latitude"),
                          title: Text(": ${controller.lokasi.value.latitude}"),
                          horizontalTitleGap: 30,
                        ),
                        ListTile(
                          dense: true,
                          leading: Text("Longitude"),
                          title: Text(": ${controller.lokasi.value.longitude}"),
                          horizontalTitleGap: 24,
                        ),
                        ListTile(
                          dense: true,
                          leading: Text("Suhu"),
                          title: Text(": ${controller.lokasi.value.suhu} C"),
                          horizontalTitleGap: 35,
                        ),
                        ListTile(
                          dense: true,
                          leading: Text("Waktu"),
                          title: Text(": ${controller.lokasi.value.waktu}"),
                          horizontalTitleGap: 35,
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(4),
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
                      child: GoogleMap(
                        mapType: MapType.hybrid,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            controller.latitude.value,
                            controller.longitude.value,
                          ),
                          zoom: 18,
                        ),
                        circles: {controller.circle},
                        markers: {controller.marker},
                        onMapCreated: controller.onMapCreated,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
