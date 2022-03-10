import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:input_slider/input_slider.dart';
import 'package:iot_gps_kucing/app/controllers/lokasi_controller.dart';
import 'package:iot_gps_kucing/app/themes/app_colors.dart';

class PengaturanView extends GetView<LokasiController> {
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
          child: Obx(
            () => Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.location_searching),
                  title: Text("Titik Koordinat"),
                  subtitle: Text(
                      "Latitude : ${controller.latitude.value} \nLongitude : ${controller.longitude.value}"),
                  trailing: Icon(Icons.edit_location_alt),
                  isThreeLine: true,
                  onTap: () {
                    Get.bottomSheet(
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            margin: const EdgeInsets.all(12),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: secondaryColor,
                              shape: BoxShape.rectangle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  offset: Offset(
                                      -5, 5), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "Silahkan Geser Marker Ke Lokasi Yang Diinginkan",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              margin: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                                bottom: 12,
                              ),
                              decoration: BoxDecoration(
                                color: secondaryColor,
                                shape: BoxShape.rectangle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    offset: Offset(
                                        -5, 5), // changes position of shadow
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
                                markers: {controller.markerPengaturan},
                                onMapCreated: controller.onMapCreated,
                              ),
                            ),
                          ),
                        ],
                      ),
                      enableDrag: false,
                    );
                  },
                ),
                SizedBox(height: 8),
                ListTile(
                  leading: Icon(Icons.radar),
                  title: Text("Radius"),
                  subtitle: Text("${controller.radius.value} Meter"),
                  trailing: Icon(
                    Icons.edit_location_alt,
                  ),
                  onTap: () {
                    Get.bottomSheet(
                      Container(
                        height: 150,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              margin: const EdgeInsets.all(12),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: secondaryColor,
                                shape: BoxShape.rectangle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    offset: Offset(
                                        -5, 5), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "Silahkan Geser Radius Yang Diinginkan",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              margin: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                                bottom: 12,
                              ),
                              decoration: BoxDecoration(
                                color: secondaryColor,
                                shape: BoxShape.rectangle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    offset: Offset(
                                        -5, 5), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: InputSlider(
                                onChangeEnd: controller.changeRadius,
                                defaultValue: controller.radius.value,
                                min: 0.0,
                                max: 50.0,
                                decimalPlaces: 0,
                                activeSliderColor: dangerColor,
                                onChange: (double) {},
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
