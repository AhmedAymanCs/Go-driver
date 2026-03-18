import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_driver/core/constants/app_constants.dart';
import 'package:go_driver/core/utils/typedef.dart';
import 'package:go_driver/features/home/data/models/order_model.dart';
import 'package:go_driver/features/home/data/models/route_model.dart';
import 'package:go_driver/features/home/data/models/route_prams.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:osm_nominatim/osm_nominatim.dart';

abstract class HomeDataSource {
  //Map
  Places searchPlaces(String query);
  Future<String> reverseGeocoding(LatLng position);
  Future<RouteModel> getRouteCoordinates(RoutePrams params);

  //Firebase
  Stream<List<OrderModel>> getOrders();
}

class HomeDataSourceImpl implements HomeDataSource {
  final Nominatim nominatim;
  final OpenRouteService ors;
  final FirebaseFirestore firestore;
  HomeDataSourceImpl({
    required this.nominatim,
    required this.ors,
    required this.firestore,
  });

  @override
  Places searchPlaces(String query) async {
    return nominatim.searchByName(query: query, limit: 5, countryCodes: ['eg']);
  }

  @override
  Future<RouteModel> getRouteCoordinates(RoutePrams params) async {
    final response = await ors.directionsRouteGeoJsonGet(
      startCoordinate: ORSCoordinate(
        latitude: params.position.latitude,
        longitude: params.position.longitude,
      ),
      endCoordinate: ORSCoordinate(
        latitude: params.destination.latitude,
        longitude: params.destination.longitude,
      ),
    );

    final summary =
        response.features[0].properties['summary'] as Map<String, dynamic>;
    final double distanceKm = (summary['distance'] as num).toDouble() / 1000;
    return RouteModel(
      placeName: params.placeName,
      points: response.features[0].geometry.coordinates
          .expand((e) => e)
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList(),
      distanceKm: distanceKm,
      price: 0, //TODO: getPrice price
      durationMin: (summary['duration'] as num).toDouble() / 600,
    );
  }

  @override
  Future<String> reverseGeocoding(LatLng position) async {
    final place = await nominatim.reverseSearch(
      lat: position.latitude,
      lon: position.longitude,
      language: 'ar',
    );
    return place.displayName;
  }

  @override
  Stream<List<OrderModel>> getOrders() {
    return firestore
        .collection(AppConstants.ordersCollection)
        .where(
          AppConstants.statusConditionParam,
          isEqualTo: AppConstants.pendingStatus,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromJson(doc.data()))
              .toList(),
        );
  }
}
