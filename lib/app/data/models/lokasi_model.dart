import 'package:intl/intl.dart';

class LokasiModel {
  late double? latitude;
  late double? longitude;
  late double? suhu;
  late String? waktu;

  LokasiModel({
    this.latitude,
    this.longitude,
    this.suhu,
    this.waktu,
  });

  LokasiModel.fromMap(Map<dynamic, dynamic> map) {
    latitude = map['latitude'].runtimeType == double
        ? map['latitude']
        : (map['latitude'] as int).toDouble();
    longitude = map['longitude'].runtimeType == double
        ? map['longitude']
        : (map['longitude'] as int).toDouble();
    suhu = map['suhu'].runtimeType == double
        ? map['suhu']
        : (map['suhu'] as int).toDouble();

    waktu = DateFormat("dd-MM-yyyy HH:mm:ss")
        .format(DateTime.fromMillisecondsSinceEpoch(map['waktu']));
  }
}
