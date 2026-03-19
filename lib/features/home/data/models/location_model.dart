class LocationModel {
  final double longitude;
  final double latitude;
  const LocationModel({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() {
    return {'driver_lat': latitude, 'driver_lng': longitude};
  }
}
