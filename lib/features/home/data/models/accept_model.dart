class AcceptModel {
  final String? status;
  final String driverId;
  final String driverName;
  final String driverPhone;

  const AcceptModel({
    this.status = 'accepted',
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'driver_id': driverId,
      'driver_name': driverName,
      'driver_phone': driverPhone,
    };
  }
}
