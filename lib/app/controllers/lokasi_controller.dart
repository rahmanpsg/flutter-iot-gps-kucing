import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iot_gps_kucing/app/data/models/lokasi_model.dart';
import 'package:iot_gps_kucing/app/data/models/pengaturan_model.dart';
import 'package:iot_gps_kucing/app/themes/app_colors.dart';
import 'package:responsive_table/responsive_table.dart';

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
  Rx<LokasiModel> lokasi = LokasiModel().obs;

  // List lokasi alat
  RxList<LokasiModel> listLokasi = <LokasiModel>[].obs;

  // Koordinat Rumah
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;

  // Map
  late final Set<Marker> markers = <Marker>{}.obs;

  late Circle circle;
  late Marker marker;
  late Marker markerPengaturan;
  late Polyline polyline;

  late final BitmapDescriptor markerIcon;
  late final BitmapDescriptor circleIcon;

  // Tabel histori
  late final List<DatatableHeader> headerDataTable;

  @override
  void onInit() async {
    super.onInit();

    gmapController = Completer();
    firestore = FirebaseFirestore.instance;
    database = FirebaseDatabase.instance;

    refData = firestore.collection("data");
    refPengaturan = database.ref("pengaturan");
    refLokasi = database.ref("data");

    markerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/images/marker.png',
    );
    circleIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        devicePixelRatio: 1,
      ),
      'assets/images/circle.png',
    );

    await loadListLokasi();

    await initDataPengaturan();
    streamDataLokasi();

    initDataTable();

    loading.value = false;
  }

  void onMapCreated(GoogleMapController c) {
    c.setMapStyle(Utils.mapStyles);

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

  void initCircleMarker() async {
    circle = Circle(
      circleId: CircleId('rumah'),
      center: LatLng(latitude.value, longitude.value),
      radius: radius.value,
      fillColor: secondaryColor.withOpacity(.5),
      strokeColor: primaryColor,
      strokeWidth: 3,
    );

    markers.add(Marker(
      markerId: MarkerId('posisi'),
      position: LatLng(
        listLokasi.first.latitude ?? latitude.value,
        listLokasi.first.longitude ?? longitude.value,
      ),
      infoWindow: InfoWindow(
        title: 'Lokasi Kucing',
        snippet: '${latitude.value}, ${longitude.value}',
      ),
      icon: markerIcon,
    ));

    log(listLokasi.first.latitude.toString());

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
      backgroundColor: bgColor,
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
      backgroundColor: bgColor,
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
        text: "Suhu",
        value: "suhu",
        sourceBuilder: (value, row) {
          return Text("$value C");
        },
      ),
    ];
  }

  Future<void> loadListLokasi() async {
    try {
      Stream<QuerySnapshot> snapshot = refData.orderBy("waktu").snapshots();

      // for (var doc in snapshot.) {
      //   listLokasi.add(LokasiModel.fromMap(doc.data() as Map));
      // }

      snapshot.forEach((data) {
        for (var doc in data.docs) {
          listLokasi.insert(0, LokasiModel.fromMap(doc.data() as Map));
        }

        for (var entries in listLokasi.asMap().entries) {
          if (entries.key == 0) continue;

          markers.add(Marker(
            markerId: MarkerId("posisi_${entries.key}"),
            position: LatLng(
              entries.value.latitude ?? latitude.value,
              entries.value.longitude ?? longitude.value,
            ),
            infoWindow: InfoWindow(
              title: 'Lokasi Kucing',
              snippet: '${entries.value.waktu}',
            ),
            icon: circleIcon,
          ));
        }

        // List<LatLng> _lokasis = [];

        // for (var lokasi in listLokasi) {
        //   log(lokasi.toJson().toString());
        //   _lokasis.add(LatLng(lokasi.latitude ?? 0, lokasi.longitude ?? 0));
        // }

        polyline = Polyline(
          polylineId: PolylineId("poly"),
          color: Color.fromARGB(255, 40, 122, 198),
          width: 5,
          points: listLokasi
              .map(
                (lokasi) => LatLng(lokasi.latitude ?? 0, lokasi.longitude ?? 0),
              )
              .toList(),
        );

        log(polyline.toJson().toString());
      });
    } catch (e) {
      log(e.toString());
    }
  }
}

class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}
