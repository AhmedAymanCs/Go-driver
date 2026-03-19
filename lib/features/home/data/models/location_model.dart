class LocationModel {
  final double longitude;
  final double latitude;
  final double driverHeading;
  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.driverHeading,
  });

  Map<String, dynamic> toJson() {
    return {
      'driver_lat': latitude,
      'driver_lng': longitude,
      'driver_heading': driverHeading,
    };
  }
}
