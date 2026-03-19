import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_driver/features/home/data/models/order_model.dart';
import 'package:go_driver/features/home/data/models/route_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum HomeStatus { initial, loading, success, error }

enum TripActionStatus { initial, goingToPassenger, arrived, inProgress }

class HomeState extends Equatable {
  final bool isOnline;
  final HomeStatus status;
  final TripActionStatus tripActionStatus;
  final String error;
  final String mapStyle;
  final GoogleMapController? controller;
  final Set<Marker> markers;
  final Position? position;
  final bool isPermissionGranted;
  final BitmapDescriptor currentLocationIcon;
  final bool hasMoved;
  final Set<Polyline> polylines;
  final RouteModel? route;
  final List<OrderModel>? orders;
  final OrderModel? currentOrder;
  const HomeState({
    this.status = HomeStatus.initial,
    this.tripActionStatus = TripActionStatus.initial,
    this.error = '',
    this.controller,
    this.mapStyle = '',
    this.markers = const {},
    this.position,
    this.isPermissionGranted = false,
    this.currentLocationIcon = BitmapDescriptor.defaultMarker,
    this.hasMoved = false,
    this.polylines = const {},
    this.route,
    this.orders,
    this.isOnline = true,
    this.currentOrder,
  });
  HomeState copyWith({
    HomeStatus? status,
    TripActionStatus? tripActionStatus,
    String? error,
    GoogleMapController? controller,
    String? mapStyle,
    Set<Marker>? markers,
    Position? position,
    bool? isPermissionGranted,
    BitmapDescriptor? currentLocationIcon,
    bool? hasMoved,
    Set<Polyline>? polylines,
    RouteModel? route,
    List<OrderModel>? orders,
    bool? isOnline,
    OrderModel? currentOrder,
  }) {
    return HomeState(
      status: status ?? this.status,
      tripActionStatus: tripActionStatus ?? this.tripActionStatus,
      error: error ?? this.error,
      controller: controller ?? this.controller,
      mapStyle: mapStyle ?? this.mapStyle,
      markers: markers ?? this.markers,
      position: position ?? this.position,
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
      currentLocationIcon: currentLocationIcon ?? this.currentLocationIcon,
      hasMoved: hasMoved ?? this.hasMoved,
      polylines: polylines ?? this.polylines,
      route: route ?? this.route,
      orders: orders ?? this.orders,
      isOnline: isOnline ?? this.isOnline,
      currentOrder: currentOrder ?? this.currentOrder,
    );
  }

  @override
  List<Object?> get props => [
    status,
    tripActionStatus,
    error,
    controller,
    mapStyle,
    markers,
    position,
    isPermissionGranted,
    currentLocationIcon,
    hasMoved,
    polylines,
    route,
    orders,
    isOnline,
    currentOrder,
  ];
}
