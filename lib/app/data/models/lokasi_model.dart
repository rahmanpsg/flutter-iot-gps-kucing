import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LokasiModel {
  late double? latitude;
  late double? longitude;
  late double? jarak;
  late double? suhu;
  late String? waktu;

  LokasiModel({
    this.latitude,
    this.longitude,
    this.jarak,
    this.suhu,
    this.waktu,
  });

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "jarak": jarak,
        "suhu": suhu,
        "waktu": waktu,
      };

  LokasiModel.fromMap(Map<dynamic, dynamic> map) {
    if (map.containsKey("lokasi")) {
      latitude = (map["lokasi"] as GeoPoint).latitude;
      longitude = (map["lokasi"] as GeoPoint).longitude;
    } else {
      latitude = map['latitude'].runtimeType == double
          ? map['latitude']
          : (map['latitude'] as int).toDouble();
      longitude = map['longitude'].runtimeType == double
          ? map['longitude']
          : (map['longitude'] as int).toDouble();
    }
    jarak = map['jarak'].runtimeType == double
        ? map['jarak']
        : (map['jarak'] as int).toDouble();
    suhu = map['suhu'].runtimeType == double
        ? map['suhu']
        : (map['suhu'] as int).toDouble();

    waktu = DateFormat("dd-MM-yyyy HH:mm:ss").format(
      DateTime.fromMillisecondsSinceEpoch(map['waktu'].runtimeType == Timestamp
          ? (map['waktu'] as Timestamp).millisecondsSinceEpoch
          : map['waktu']),
    );
  }
}
