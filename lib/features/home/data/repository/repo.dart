import 'package:dartz/dartz.dart';
import 'package:go_driver/core/utils/typedef.dart';
import 'package:go_driver/features/home/data/data_source/data_source.dart';
import 'package:go_driver/features/home/data/models/accept_model.dart';
import 'package:go_driver/features/home/data/models/location_model.dart';
import 'package:go_driver/features/home/data/models/order_model.dart';
import 'package:go_driver/features/home/data/models/route_model.dart';
import 'package:go_driver/features/home/data/models/route_prams.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:osm_nominatim/osm_nominatim.dart';

abstract class HomeRepository {
  //Map
  ServerResponse<List<Place>> searchPlaces(String query);
  ServerResponse<RouteModel> getRouteCoordinates(RoutePrams params);
  ServerResponse<String> reverseGeocoding(LatLng position);

  //Firebase
  ServerResponse<Stream<List<OrderModel>>> getOrders();
  ServerResponse<Unit> acceptOrder({
    required String orderId,
    required AcceptModel acceptModel,
  });
  ServerResponse<Unit> updateLocation(LocationModel position, String orderId);
}

class HomeRepositoryImpl implements HomeRepository {
  final HomeDataSource _homeDataSource;
  HomeRepositoryImpl(this._homeDataSource);

  //Map
  @override
  ServerResponse<List<Place>> searchPlaces(String query) async {
    try {
      final res = await _homeDataSource.searchPlaces(query);
      return Right(res);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  ServerResponse<RouteModel> getRouteCoordinates(RoutePrams params) async {
    try {
      final res = await _homeDataSource.getRouteCoordinates(params);
      return Right(res);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  ServerResponse<String> reverseGeocoding(LatLng position) async {
    try {
      final res = await _homeDataSource.reverseGeocoding(position);
      return Right(res);
    } catch (e) {
      return Left(e.toString());
    }
  }

  //Firebase
  @override
  ServerResponse<Stream<List<OrderModel>>> getOrders() async {
    try {
      return Right(_homeDataSource.getOrders());
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  ServerResponse<Unit> acceptOrder({
    required String orderId,
    required AcceptModel acceptModel,
  }) async {
    try {
      await _homeDataSource.acceptOrder(
        orderId: orderId,
        acceptModel: acceptModel,
      );
      return Right(unit);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  ServerResponse<Unit> updateLocation(
    LocationModel position,
    String orderId,
  ) async {
    try {
      await _homeDataSource.updateLocation(position, orderId);
      return Right(unit);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
