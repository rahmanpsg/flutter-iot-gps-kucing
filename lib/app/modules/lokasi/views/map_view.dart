import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iot_gps_kucing/app/controllers/lokasi_controller.dart';
import 'package:iot_gps_kucing/app/themes/app_colors.dart';

class MapView extends GetView<LokasiController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
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
                        leading: Text("Lokasi"),
                        title: Text(": ${controller.lat}, ${controller.lng}"),
                      ),
                      ListTile(
                        dense: true,
                        leading: Text("Jarak"),
                        title: Text(": ${controller.jarak} M"),
                      ),
                      ListTile(
                        dense: true,
                        leading: Text("Suhu"),
                        title: Text(": ${controller.suhu} C"),
                        // horizontalTitleGap: 35,
                      ),
                      ListTile(
                        dense: true,
                        leading: Text("Waktu"),
                        title: Text(": ${controller.waktu}"),
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
                      tiltGesturesEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          controller.latitude.value,
                          controller.longitude.value,
                        ),
                        zoom: 19,
                      ),
                      circles: {controller.circle},
                      markers: controller.markers,
                      polylines: controller.polyline,
                      onMapCreated: controller.onMapCreated,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
