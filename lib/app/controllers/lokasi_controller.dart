import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iot_gps_kucing/app/data/models/lokasi_model.dart';
import 'package:iot_gps_kucing/app/data/models/pengaturan_model.dart';
import 'package:iot_gps_kucing/app/themes/app_colors.dart';

class LokasiController extends GetxController {
  late Completer<GoogleMapController> gmapController;
  late FirebaseDatabase database;
  late DatabaseReference refPengaturan;
  late DatabaseReference refLokasi;

  RxBool loading = true.obs;

  // Lokasi Alat
  Rx<LokasiModel> lokasi = LokasiModel().obs;

  // Koordinat Rumah
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;

  late Circle circle;
  late Marker marker;
  late Marker markerPengaturan;

  RxDouble radius = 0.0.obs;

  @override
  void onInit() async {
    super.onInit();

    gmapController = Completer();
    database = FirebaseDatabase.instance;

    refPengaturan = database.ref("pengaturan");
    refLokasi = database.ref("data");

    await initDataPengaturan();
    streamDataLokasi();

    loading.value = false;
  }

  void onMapCreated(GoogleMapController c) {
    if (!gmapController.isCompleted) gmapController.complete(c);
  }

  Future initDataPengaturan() async {
    DatabaseEvent event = await refPengaturan.once();

    Map<dynamic, dynamic> values =
        event.snapshot.value as Map<dynamic, dynamic>;

    PengaturanModel _pengaturan = PengaturanModel.fromMap(values);

    latitude.value = _pengaturan.latitude;
    longitude.value = _pengaturan.longitude;

    radius.value = _pengaturan.radius;

    initCircleMarker();
  }

  void initCircleMarker() {
    circle = Circle(
      circleId: CircleId('rumah'),
      center: LatLng(latitude.value, longitude.value),
      radius: radius.value,
      fillColor: secondaryColor.withOpacity(.5),
      strokeColor: primaryColor,
      strokeWidth: 3,
    );

    marker = Marker(
      markerId: MarkerId('posisi'),
      position: LatLng(
        lokasi.value.latitude ?? 0.0,
        lokasi.value.longitude ?? 0.0,
      ),
      infoWindow: InfoWindow(
        title: 'Lokasi Kucing',
        snippet: '${latitude.value}, ${longitude.value}',
      ),
    );

    markerPengaturan = Marker(
      markerId: MarkerId('rumah'),
      position: LatLng(latitude.value, longitude.value),
      draggable: true,
      onDragEnd: changeTitikKoordinat,
    );
  }

  void streamDataLokasi() {
    Stream<DatabaseEvent> stream = refLokasi.onValue;

    stream.listen((DatabaseEvent event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> values =
            event.snapshot.value as Map<dynamic, dynamic>;

        LokasiModel _lokasi = LokasiModel.fromMap(values);

        lokasi.update((val) {
          val!.latitude = _lokasi.latitude;
          val.longitude = _lokasi.longitude;
          val.suhu = _lokasi.suhu;
          val.waktu = _lokasi.waktu;
        });

        initCircleMarker();
      }
    });
  }

  void changeTitikKoordinat(LatLng? val) {
    latitude.value = val!.latitude;
    longitude.value = val.longitude;

    refPengaturan.update({
      "latitude": latitude.value,
      "longitude": longitude.value,
    });

    initCircleMarker();
    changeCamera();

    Get.snackbar(
      "Informasi",
      "Titik Koordinat berhasil disimpan",
      backgroundColor: primaryColor,
    );
  }

  void changeRadius(double val) {
    radius.value = double.parse(val.toStringAsFixed(0));

    refPengaturan.update({
      "radius": radius.value,
    });

    initCircleMarker();

    Get.snackbar(
      "Informasi",
      "Radius berhasil disimpan",
      backgroundColor: primaryColor,
    );
  }

  void changeCamera() async {
    final GoogleMapController c = await gmapController.future;

    c.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude.value, longitude.value),
          zoom: 18,
        ),
      ),
    );
  }
}
