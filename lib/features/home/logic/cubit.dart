import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_driver/core/constants/app_constants.dart';
import 'package:go_driver/core/constants/color_manager.dart';
import 'package:go_driver/core/constants/image_manager.dart';
import 'package:go_driver/core/constants/styles_manager.dart';
import 'package:go_driver/core/constants/trip_keywords.dart';
import 'package:go_driver/core/models/user_model.dart';
import 'package:go_driver/features/home/data/models/accept_model.dart';
import 'package:go_driver/features/home/data/models/location_model.dart';
import 'package:go_driver/features/home/data/models/order_model.dart';
import 'package:go_driver/features/home/data/models/route_prams.dart';
import 'package:go_driver/features/home/data/repository/repo.dart';
import 'package:go_driver/features/home/logic/states.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository;
  final FlutterSecureStorage _secureStorage;
  HomeCubit(this._homeRepository, this._secureStorage) : super(HomeState());

  StreamSubscription<Position>?
  _positionStream; //for get current location stream
  StreamSubscription<List<OrderModel>>?
  _ordersSubscription; //for listen to orders stream

  void init(BuildContext context) async {
    final mapStyle = await setMapStyle(context);
    emit(state.copyWith(mapStyle: mapStyle));
    listenToOrders();
  }

  Future<String> setMapStyle(BuildContext context) async {
    return await DefaultAssetBundle.of(
      context,
    ).loadString(StylesManager.mapStyles);
  }

  void onMapCreated(GoogleMapController controller) async {
    emit(state.copyWith(controller: controller));
    await _loadCurrentLocationIcon();
    await getCurrentStreamLocation();
  }

  void moveTo(
    LatLng destination, {
    bool isCurrentLocation = false,
    double zoom = 16,
  }) {
    state.controller!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: destination, zoom: zoom),
      ),
    );
    if (isCurrentLocation) {
      _updateMarker();
    } else {
      addMarker(destination);
    }
  }

  void addMarker(LatLng latLng) {
    final markers = {
      Marker(markerId: const MarkerId('destination'), position: latLng),
    };
    emit(state.copyWith(markers: markers));
  }

  Future<void> _checkPermission() async {
    final PermissionStatus permission = await Permission.location.request();
    if (permission == PermissionStatus.granted) {
      emit(state.copyWith(isPermissionGranted: true));
    } else {
      emit(state.copyWith(isPermissionGranted: false));
    }
  }

  Future<void> getCurrentStreamLocation() async {
    await _checkPermission();
    if (state.isPermissionGranted) {
      _positionStream = Geolocator.getPositionStream().listen((position) {
        final bool alreadyMoved = state.hasMoved;
        emit(state.copyWith(position: position, hasMoved: true));
        _updateMarker();
        if (!alreadyMoved) {
          state.controller?.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(position.latitude, position.longitude),
            ),
          );
        }
        if (state.currentOrder != null) {
          _homeRepository.updateLocation(
            LocationModel(
              latitude: position.latitude,
              longitude: position.longitude,
              driverHeading: position.heading,
            ),
            state.currentOrder!.id!,
          );
        }
      });
    }
  }

  Future<void> _loadCurrentLocationIcon() async {
    final icon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(28, 28), devicePixelRatio: 2.0),
      ImageManager.currentLocation,
    );
    emit(state.copyWith(currentLocationIcon: icon));
  }

  void _updateMarker() {
    if (state.position == null) return;

    final latLng = LatLng(state.position!.latitude, state.position!.longitude);

    final updatedMarkers = {
      ...state.markers,
      Marker(
        markerId: const MarkerId('current_location'),
        position: latLng,
        icon: state.currentLocationIcon,
        anchor: const Offset(0.5, 0.5),
      ),
    };

    emit(state.copyWith(markers: updatedMarkers));
  }

  Future<void> drawRoute(LatLng destination, {bool move = true}) async {
    if (state.position == null) return;
    emit(state.copyWith(polylines: {}));
    if (move) {
      moveTo(destination, zoom: 14);
    }
    final res = await _homeRepository.getRouteCoordinates(
      RoutePrams(
        destination: destination,
        position: LatLng(state.position!.latitude, state.position!.longitude),
      ),
    );
    res.fold(
      (error) => emit(state.copyWith(error: error)),
      (coordinates) => emit(
        state.copyWith(
          polylines: {
            Polyline(
              polylineId: const PolylineId('route'),
              points: coordinates.points,
              color: ColorManager.greenAccent,
              width: 5,
            ),
          },
          route: coordinates,
        ),
      ),
    );
  }

  void toggleStatus() {
    emit(state.copyWith(isOnline: !state.isOnline));
    if (state.isOnline) {
      listenToOrders();
      getCurrentStreamLocation();
    } else {
      _ordersSubscription?.cancel();
      _positionStream?.cancel();
      emit(state.copyWith(orders: []));
    }
  }

  void listenToOrders() async {
    final res = await _homeRepository.getOrders();
    res.fold(
      (error) => emit(state.copyWith(error: error, status: HomeStatus.error)),
      (stream) {
        _ordersSubscription = stream.listen((orders) {
          emit(state.copyWith(orders: orders, status: HomeStatus.success));
        });
      },
    );
  }

  double getDistanceToPassenger(OrderModel order) {
    if (state.position == null) return 0;
    final distanceInMeters = Geolocator.distanceBetween(
      state.position!.latitude,
      state.position!.longitude,
      order.passengerLat,
      order.passengerLng,
    );
    return distanceInMeters / 1000;
  }

  Future<void> acceptOrder(OrderModel order) async {
    final userSession = await _secureStorage.read(
      key: AppConstants.userSession,
    );
    final user = UserModel.fromJson(jsonDecode(userSession!));
    final res = await _homeRepository.acceptOrder(
      orderId: order.id!,
      acceptModel: AcceptModel(
        driverId: user.uId ?? '',
        driverName: user.name ?? '',
        driverPhone: user.phone ?? '',
      ),
    );
    res.fold(
      (error) => emit(state.copyWith(error: error, status: HomeStatus.error)),
      (_) {
        drawRoute(LatLng(order.passengerLat, order.passengerLng));
        emit(
          state.copyWith(
            tripActionStatus: TripActionStatus.goingToPassenger,
            currentOrder: order,
          ),
        );
      },
    );
  }

  void rejectOrder(OrderModel order) {
    final updatedOrders = state.orders!.where((o) => o.id != order.id).toList();
    emit(state.copyWith(orders: updatedOrders));
  }

  Future<void> tripAction() async {
    final orderId = state.currentOrder?.id;
    if (orderId == null) return;

    switch (state.tripActionStatus) {
      case TripActionStatus.initial:
        break;
      case TripActionStatus.goingToPassenger:
        await _homeRepository.updateTripStatus(
          TripKeywords.driverArrived,
          orderId,
        );
        emit(state.copyWith(tripActionStatus: TripActionStatus.arrived));
        break;

      case TripActionStatus.arrived:
        await _homeRepository.updateTripStatus(
          TripKeywords.inProgress,
          orderId,
        );
        drawRoute(
          LatLng(
            state.currentOrder!.destinationLat,
            state.currentOrder!.destinationLng,
          ),
          move: false,
        );
        emit(state.copyWith(tripActionStatus: TripActionStatus.inProgress));
        break;

      case TripActionStatus.inProgress:
        await _homeRepository.updateTripStatus(TripKeywords.ended, orderId);
        emit(
          state.copyWith(
            tripActionStatus: TripActionStatus.initial,
            currentOrder: null,
            polylines: {},
            markers: {state.markers.last},
          ),
        );
        break;
    }
  }

  @override
  Future<void> close() {
    _positionStream?.cancel();
    _ordersSubscription?.cancel();
    return super.close();
  }
}
