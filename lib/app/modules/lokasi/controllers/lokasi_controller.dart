import 'dart:async';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iot_gps_kucing/app/themes/app_colors.dart';

class LokasiController extends GetxController {
  RxBool loading = false.obs;

  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;

  Completer<GoogleMapController> gmapController = Completer();

  late Circle circle;
  late Marker marker;

  RxDouble radius = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    latitude.value = -3.9843507;
    longitude.value = 119.6520053;

    radius.value = 100;

    circle = Circle(
      circleId: CircleId('kantor'),
      center: LatLng(latitude.value, longitude.value),
      radius: radius.value,
      fillColor: secondaryColor.withOpacity(.5),
      strokeColor: primaryColor,
      strokeWidth: 3,
    );

    marker = Marker(
      markerId: MarkerId('posisi'),
      position: LatLng(latitude.value, longitude.value),
      infoWindow: InfoWindow(
        title: 'Lokasi Kucing',
        snippet: '${latitude.value}, ${longitude.value}',
      ),
    );
  }

  void onMapCreated(GoogleMapController c) {
    if (!gmapController.isCompleted) gmapController.complete(c);
  }
}
