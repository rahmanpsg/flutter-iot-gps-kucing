class PengaturanModel {
  late double latitude;
  late double longitude;
  late double radius;

  PengaturanModel({
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  PengaturanModel.fromMap(Map<dynamic, dynamic> map) {
    latitude = map['latitude'].runtimeType == double
        ? map['latitude']
        : (map['latitude'] as int).toDouble();
    longitude = map['longitude'].runtimeType == double
        ? map['longitude']
        : (map['longitude'] as int).toDouble();
    radius = map['radius'].runtimeType == double
        ? map['radius']
        : (map['radius'] as int).toDouble();
  }
}
