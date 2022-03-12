import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LokasiModel {
  late final String id;
  late final double latitude;
  late final double longitude;
  late final double jarak;
  late final double radius;
  late final double suhu;
  late final String waktu;

  LokasiModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.jarak,
    required this.radius,
    required this.suhu,
    required this.waktu,
  });

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "jarak": jarak,
        "radius": radius,
        "suhu": suhu,
        "waktu": waktu,
      };

  LokasiModel.fromMap(Map<dynamic, dynamic> map) {
    try {
      id = map['id'];

      latitude = map['latitude'].runtimeType == double
          ? map['latitude']
          : (map['latitude'] as int).toDouble();
      longitude = map['longitude'].runtimeType == double
          ? map['longitude']
          : (map['longitude'] as int).toDouble();

      jarak = map['jarak'].runtimeType == double
          ? map['jarak']
          : (map['jarak'] as int).toDouble();

      radius = map['radius'].runtimeType == double
          ? map['radius']
          : (map['radius'] as int).toDouble();

      // radius = map['radius'];

      suhu = map['suhu'].runtimeType == double
          ? map['suhu']
          : (map['suhu'] as int).toDouble();

      waktu = DateFormat("dd-MM-yyyy HH:mm:ss").format(
        DateTime.fromMillisecondsSinceEpoch(
            map['waktu'].runtimeType == Timestamp
                ? (map['waktu'] as Timestamp).millisecondsSinceEpoch
                : map['waktu']),
      );
    } catch (e) {
      log(e.toString());
    }
  }
}
