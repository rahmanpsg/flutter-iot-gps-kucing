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
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:syncfusion_officechart/officechart.dart';
import 'package:url_launcher/url_launcher.dart';

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

        markers.add(
          Marker(
              markerId: MarkerId("posisi_${entries.key}"),
              position: LatLng(
                _lat,
                _lng,
              ),
              icon: entries.key == 0 ? markerIcon : circleIcon,
              onTap: () {
                Get.bottomSheet(
                  Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.all(12),
                    width: double.infinity,
                    height: 110,
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
                        Text("Waktu : $_waktu"),
                        Text("Latitude :$_lat"),
                        Text("Longitude :$_lng"),
                        OutlineButton.icon(
                          onPressed: () {
                            navigateTo(_lat, _lng);
                          },
                          icon: Icon(
                            Icons.navigation_sharp,
                            color: Colors.black,
                          ),
                          label: Text(
                            "Navigasi",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }),
        );
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
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];

      // Header
      xlsio.Style headerStyle = workbook.styles.add("style");
      headerStyle.backColor = '#FFE699';
      headerStyle.bold = true;
      headerStyle.borders.all.lineStyle = xlsio.LineStyle.thin;

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

      final List<Map<String, String>> listKeterangan = [
        {"jarak": "<= 10 Meter", "warna": "#32a868", "total": "0"},
        {"jarak": "<= 20 Meter", "warna": "#89a832", "total": "0"},
        {"jarak": "<= 30 Meter", "warna": "#f5d016", "total": "0"},
        {"jarak": "<= 40 Meter", "warna": "#f5a716", "total": "0"},
        {"jarak": "<= 50 Meter", "warna": "#f57316", "total": "0"},
        {"jarak": "> 50 Meter", "warna": "#f51616", "total": "0"},
      ];

      // header
      for (var entries in headers.asMap().entries) {
        final xlsio.Range range = sheet.getRangeByIndex(1, entries.key + 1);
        range.cellStyle = headerStyle;
        range.cellStyle.wrapText = true;
        range.setText(entries.value);
      }

      xlsio.Style style = workbook.styles.add("bodyStyle");
      style.backColor = '#ffffff';
      style.borders.all.lineStyle = xlsio.LineStyle.thin;

      // body
      for (var entries in listLokasi.asMap().entries) {
        var lokasi = entries.value.toJson();

        int rowIndex = entries.key + 2;
        int columnIndex = 1;

        final xlsio.Range rangeNomor =
            sheet.getRangeByIndex(rowIndex, columnIndex);
        rangeNomor.cellStyle = style;
        rangeNomor.cellStyle.wrapText = true;
        rangeNomor.setText((entries.key + 1).toString());
        rangeNomor.autoFitRows();

        for (var item in lokasi.entries) {
          var value = item.value;

          style.backColor = '#ffffff';

          if (item.key == 'jarak' || item.key == 'radius') {
            // klasifikasi warna
            if (item.key == 'jarak') {
              if (value <= 10) {
                style.backColor = listKeterangan[0]['warna']!;
                listKeterangan[0]['total'] =
                    (int.parse(listKeterangan[0]['total']!) + 1).toString();
              } else if (value <= 20) {
                style.backColor = listKeterangan[1]['warna']!;
                listKeterangan[1]['total'] =
                    (int.parse(listKeterangan[1]['total']!) + 1).toString();
              } else if (value <= 30) {
                style.backColor = listKeterangan[2]['warna']!;
                listKeterangan[2]['total'] =
                    (int.parse(listKeterangan[2]['total']!) + 1).toString();
              } else if (value <= 40) {
                style.backColor = listKeterangan[3]['warna']!;
                listKeterangan[3]['total'] =
                    (int.parse(listKeterangan[3]['total']!) + 1).toString();
              } else if (value <= 50) {
                style.backColor = listKeterangan[4]['warna']!;
                listKeterangan[4]['total'] =
                    (int.parse(listKeterangan[4]['total']!) + 1).toString();
              } else {
                style.backColor = listKeterangan[5]['warna']!;
                listKeterangan[5]['total'] =
                    (int.parse(listKeterangan[5]['total']!) + 1).toString();
              }
            }
            value = (value as double).toStringAsFixed(2) + ' M';
          } else if (item.key == 'suhu') {
            value = (value as double).toStringAsFixed(2) + ' C';
          }

          if (item.key == 'waktu') {
            String tanggal = value.toString().split(' ')[0];
            String jam = value.toString().split(' ')[1];

            final xlsio.Range rangeJam =
                sheet.getRangeByIndex(rowIndex, ++columnIndex);
            rangeJam.cellStyle = style;
            rangeJam.cellStyle.wrapText = true;

            rangeJam.setText(jam);
            rangeJam.autoFitColumns();

            value = tanggal;
          }

          final xlsio.Range range =
              sheet.getRangeByIndex(rowIndex, ++columnIndex);
          range.cellStyle = style;
          range.cellStyle.wrapText = true;

          range.setText(value.toString());
          range.autoFitColumns();
        }
      }

      // Keterangan
      xlsio.Style styleKet = workbook.styles.add("ketStyle");

      styleKet.borders.all.lineStyle = xlsio.LineStyle.thin;

      final xlsio.Range range = sheet.getRangeByName("J1");
      range.setText("Keterangan");
      range.cellStyle = styleKet;

      final xlsio.Range rangeTotal = sheet.getRangeByName("K1");
      rangeTotal.setText("Total");
      rangeTotal.cellStyle = styleKet;

      for (var entries in listKeterangan.asMap().entries) {
        styleKet.backColor = entries.value['warna']!;

        final xlsio.Range range = sheet.getRangeByIndex(entries.key + 2, 10);
        range.setText(entries.value['jarak']);
        range.autoFitColumns();
        range.cellStyle = styleKet;

        final xlsio.Range rangeTotal =
            sheet.getRangeByIndex(entries.key + 2, 11);
        rangeTotal.setNumber(double.parse(entries.value['total']!));

        rangeTotal.cellStyle = styleKet;
      }

      // Create an instances of chart collection.
      final ChartCollection charts = ChartCollection(sheet);

// Add the chart.
      final Chart chart = charts.add();

// Set Chart Type.
      chart.chartType = ExcelChartType.bar;

// Set data range in the worksheet.
      chart.dataRange = sheet.getRangeByName('J1:K7');
      chart.isSeriesInRows = false;
// set charts to worksheet.
      sheet.charts = charts;

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

  void navigateTo(double lat, double lng) async {
    var uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw 'Could not launch ${uri.toString()}';
    }
  }
}
