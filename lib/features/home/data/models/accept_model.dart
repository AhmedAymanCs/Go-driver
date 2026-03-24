import 'package:go_driver/core/constants/trip_keywords.dart';

class AcceptModel {
  final String? status;
  final String driverId;
  final String driverName;
  final String driverPhone;

  const AcceptModel({
    this.status = TripKeywords.accepted,
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
