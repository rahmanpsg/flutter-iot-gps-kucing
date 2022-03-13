import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iot_gps_kucing/app/data/models/lokasi_model.dart';
import 'package:iot_gps_kucing/app/data/models/pengaturan_model.dart';
import 'package:iot_gps_kucing/app/themes/app_colors.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_table/responsive_table.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class LokasiController extends GetxController {
  late final Completer<GoogleMapController> gmapController;

  // Cloud Firestore
  late final FirebaseFirestore firestore;
  late final CollectionReference refData;

  // Real Time DataBase
  late final FirebaseDatabase database;
  late final DatabaseReference refPengaturan;
  late final DatabaseReference refLokasi;

  RxBool loading = true.obs;

  RxDouble radius = 0.0.obs;

  // Lokasi Alat
  // Rx<LokasiModel> lokasi = LokasiModel().obs;

  // List lokasi alat
  RxList<LokasiModel> listLokasi = <LokasiModel>[].obs;

  // Koordinat Rumah
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;

  // Map
  late final Set<Marker> markers = <Marker>{}.obs;
  late final Set<Polyline> polyline = <Polyline>{}.obs;

  late Circle circle;
  late Marker marker;
  late Marker markerPengaturan;

  late final BitmapDescriptor markerIcon;
  late final BitmapDescriptor circleIcon;

  // Tabel histori
  late final List<DatatableHeader> headerDataTable;

  double get lat => listLokasi.isEmpty ? 0 : listLokasi.first.latitude;

  double get lng => listLokasi.isEmpty ? 0 : listLokasi.first.longitude;

  double get jarak => listLokasi.isEmpty ? 0 : listLokasi.first.jarak;

  double get suhu => listLokasi.isEmpty ? 0 : listLokasi.first.suhu;

  String get waktu => listLokasi.isEmpty ? "-" : listLokasi.first.waktu;

  // double get

  @override
  void onInit() async {
    super.onInit();

    gmapController = Completer();
    firestore = FirebaseFirestore.instance;
    database = FirebaseDatabase.instance;

    refData = firestore.collection("data");
    refPengaturan = database.ref("pengaturan");
    refLokasi = database.ref("data");

    await loadMarkerImage();

    listLokasi.listen(onListLokasiUpdate);

    await streamListLokasi();

    await initDataPengaturan();

    initDataTable();

    loading.value = false;
  }

  void onMapCreated(GoogleMapController c) {
    if (!gmapController.isCompleted) gmapController.complete(c);
  }

  Future<void> streamListLokasi() async {
    try {
      Stream<QuerySnapshot> snapshot = refData.orderBy("waktu").snapshots();

      snapshot.forEach((data) {
        List<LokasiModel> _listLokasi = [];

        for (var doc in data.docs) {
          _listLokasi.insert(
            0,
            LokasiModel.fromMap(
              {
                "id": doc.id,
                ...doc.data() as Map,
              },
            ),
          );
        }

        listLokasi.clear();
        listLokasi.addAll(_listLokasi);
      });
    } catch (e) {
      log(e.toString());
    }
  }

  void onListLokasiUpdate(List<LokasiModel> _listLokasi) {
    try {
      markers.clear();

      // double _prevLat = 0, _prevLng = 0;

      for (var entries in _listLokasi.asMap().entries) {
        double _lat = entries.value.latitude;
        double _lng = entries.value.longitude;
        String _waktu = entries.value.waktu;

        if (entries.key == 0) {
          markers.add(Marker(
            markerId: MarkerId('posisi'),
            position: LatLng(
              _lat,
              _lng,
            ),
            infoWindow: InfoWindow(
              title: 'Lokasi Kucing',
              snippet: _waktu,
            ),
            icon: markerIcon,
          ));
        } else {
          // if (_prevLat == _lat && _prevLng == _lng) {
          //   markers.last.infoWindow.snippet.toString();
          // }

          markers.add(
            Marker(
              markerId: MarkerId("posisi_${entries.key}"),
              position: LatLng(
                _lat,
                _lng,
              ),
              infoWindow: InfoWindow(
                title: 'Lokasi Kucing',
                snippet: _waktu,
              ),
              icon: circleIcon,
            ),
          );
        }
      }

      polyline.add(Polyline(
        polylineId: PolylineId("poly"),
        color: Color.fromARGB(255, 40, 122, 198),
        width: 5,
        points: _listLokasi
            .map(
              (lokasi) => LatLng(lokasi.latitude, lokasi.longitude),
            )
            .toList(),
      ));
    } catch (e) {
      log(e.toString());
    }
  }

  void resetListLokasi() {
    Get.defaultDialog(
        title: "Informasi",
        middleText: "Semua data akan dihapus?!",
        textCancel: "Batal",
        textConfirm: "Oke",
        confirmTextColor: dangerColor,
        buttonColor: primaryColor,
        cancelTextColor: warningColor,
        onConfirm: () {
          refData.get().then((value) {
            for (var snapshot in value.docs) {
              snapshot.reference.delete();
            }
          });

          Get.back();
        });
  }

  Future initDataPengaturan() async {
    DatabaseEvent event = await refPengaturan.once();

    Map<dynamic, dynamic> values =
        event.snapshot.value as Map<dynamic, dynamic>;

    PengaturanModel _pengaturan = PengaturanModel.fromMap(values);

    latitude.value = _pengaturan.latitude;
    longitude.value = _pengaturan.longitude;

    radius.value = _pengaturan.radius;

    initCircleAndMarker();
  }

  Future<void> loadMarkerImage() async {
    // markerIcon = await BitmapDescriptor.fromAssetImage(
    //   ImageConfiguration(devicePixelRatio: 2.5),
    //   'assets/images/marker.png',
    // );
    // circleIcon = await BitmapDescriptor.fromAssetImage(
    //   ImageConfiguration(
    //     devicePixelRatio: 1,
    //   ),
    //   'assets/images/circle.png',
    // );

    final Uint8List markerAsset =
        await getBytesFromAsset('assets/images/marker.png', 60);
    final Uint8List circleAsset =
        await getBytesFromAsset('assets/images/circle.png', 30);

    markerIcon = BitmapDescriptor.fromBytes(markerAsset);
    circleIcon = BitmapDescriptor.fromBytes(circleAsset);
  }

  void initCircleAndMarker() async {
    try {
      circle = Circle(
        circleId: CircleId('rumah'),
        center: LatLng(latitude.value, longitude.value),
        radius: radius.value,
        fillColor: secondaryColor.withOpacity(.5),
        strokeColor: primaryColor,
        strokeWidth: 3,
      );

      markerPengaturan = Marker(
        markerId: MarkerId('rumah'),
        position: LatLng(latitude.value, longitude.value),
        draggable: true,
        onDragEnd: changeTitikKoordinat,
      );
    } catch (e) {
      log(e.toString());
    }
  }

  void changeTitikKoordinat(LatLng? val) {
    try {
      latitude.value = val!.latitude;
      longitude.value = val.longitude;

      refPengaturan.update({
        "latitude": latitude.value,
        "longitude": longitude.value,
      });

      initCircleAndMarker();
      changeCamera();

      Get.snackbar(
        "Informasi",
        "Titik Koordinat berhasil disimpan",
        backgroundColor: Colors.greenAccent,
      );
    } catch (e) {
      log(e.toString());
    }
  }

  void changeRadius(double val) {
    radius.value = double.parse(val.toStringAsFixed(0));

    refPengaturan.update({
      "radius": radius.value,
    });

    initCircleAndMarker();

    Get.snackbar(
      "Informasi",
      "Radius berhasil disimpan",
      backgroundColor: Colors.greenAccent,
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

  void initDataTable() {
    headerDataTable = [
      DatatableHeader(
        text: "Nomor",
        value: "no",
      ),
      DatatableHeader(
        text: "Waktu",
        value: "waktu",
        sortable: true,
      ),
      DatatableHeader(
        text: "Latitude",
        value: "latitude",
      ),
      DatatableHeader(
        text: "Longitude",
        value: "longitude",
      ),
      DatatableHeader(
        text: "Jarak",
        value: "jarak",
        sourceBuilder: (value, row) {
          return Text("$value M");
        },
      ),
      DatatableHeader(
        text: "Radius",
        value: "radius",
        sourceBuilder: (value, row) {
          return Text("$value M");
        },
      ),
      DatatableHeader(
        text: "Suhu",
        value: "suhu",
        sourceBuilder: (value, row) {
          return Text("$value C");
        },
      ),
    ];
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> exportToExcel() async {
    try {
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];

      // Header
      Style headerStyle = workbook.styles.add("style");
      headerStyle.backColor = '#FFE699';
      headerStyle.bold = true;
      headerStyle.borders.all.lineStyle = LineStyle.thin;

      final List<String> headers = [
        "Nomor",
        "Tanggal",
        "Jam",
        "Latitude",
        "Longitude",
        "Jarak",
        "Radius",
        "Suhu"
      ];

      // header
      for (var entries in headers.asMap().entries) {
        final Range range = sheet.getRangeByIndex(1, entries.key + 1);
        range.cellStyle = headerStyle;
        range.cellStyle.wrapText = true;
        range.setText(entries.value);
      }

      Style style = workbook.styles.add("bodyStyle");
      style.backColor = '#FFE699';
      style.borders.all.lineStyle = LineStyle.thin;

      // body
      for (var entries in listLokasi.asMap().entries) {
        var lokasi = entries.value.toJson();

        int rowIndex = entries.key + 2;
        int columnIndex = 1;

        final Range rangeNomor = sheet.getRangeByIndex(rowIndex, columnIndex);
        rangeNomor.cellStyle = style;
        rangeNomor.cellStyle.wrapText = true;
        rangeNomor.setText((entries.key + 1).toString());
        rangeNomor.autoFitRows();

        for (var item in lokasi.entries) {
          final Range range = sheet.getRangeByIndex(rowIndex, ++columnIndex);
          range.cellStyle = style;
          range.cellStyle.wrapText = true;

          var value = item.value;

          if (item.key == 'jarak' || item.key == 'radius') {
            value = (value as double).toStringAsFixed(2) + ' M';
          } else if (item.key == 'suhu') {
            value = (value as double).toStringAsFixed(2) + ' C';
          }

          if (item.key == 'waktu') {
            String tanggal = value.toString().split(' ')[0];
            String jam = value.toString().split(' ')[1];

            final Range rangeJam =
                sheet.getRangeByIndex(rowIndex, ++columnIndex);
            rangeJam.cellStyle = style;
            rangeJam.cellStyle.wrapText = true;

            rangeJam.setText(jam);
            rangeJam.autoFitColumns();

            value = tanggal;
          }
          range.setText(value.toString());
          range.autoFitColumns();
        }
      }

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      String path = (await getExternalStorageDirectory())!.path;
      String fileName = "$path/histori_kucing.xlsx";

      print(fileName);

      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);
    } catch (e) {
      log(e.toString());
    }
  }
}
