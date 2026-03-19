import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_driver/core/constants/color_manager.dart';
import 'package:go_driver/core/constants/string_manager.dart';
import 'package:go_driver/features/home/data/models/order_model.dart';
import 'package:go_driver/features/home/logic/cubit.dart';
import 'package:go_driver/features/home/logic/states.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => MapState();
}

class MapState extends State<Map> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = context.read<HomeCubit>();
        return Scaffold(
          body: GoogleMap(
            buildingsEnabled: false,
            mapType: MapType.normal,
            style: state.mapStyle,
            markers: state.markers,
            polylines: state.polylines,
            initialCameraPosition: CameraPosition(
              target: state.position != null
                  ? LatLng(state.position!.latitude, state.position!.longitude)
                  : const LatLng(30.0444, 31.2357),
              zoom: 16,
            ),
            onMapCreated: (GoogleMapController controller) =>
                cubit.onMapCreated(controller),
          ),
        );
      },
    );
  }
}

class OrderItem extends StatelessWidget {
  final OrderModel order;
  final double distanceToPassenger;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const OrderItem({
    super.key,
    required this.order,
    required this.distanceToPassenger,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorManager.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorManager.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorManager.greenSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person,
                  color: ColorManager.greenAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.passengerName ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.textPrimary,
                    ),
                  ),
                  Text(
                    order.passengerPhone ?? 'Not Found',
                    style: const TextStyle(
                      fontSize: 12,
                      color: ColorManager.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${order.price.toStringAsFixed(0)} EGP',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.greenAccent,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: ColorManager.greenAccent,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.destination,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColorManager.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.straighten,
                size: 14,
                color: ColorManager.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${order.distanceKm.toStringAsFixed(1)} km',
                style: const TextStyle(
                  fontSize: 12,
                  color: ColorManager.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.access_time,
                size: 14,
                color: ColorManager.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${order.durationMin.toStringAsFixed(0)} min',
                style: const TextStyle(
                  fontSize: 12,
                  color: ColorManager.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.near_me,
                size: 14,
                color: ColorManager.navyPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                '${distanceToPassenger.toStringAsFixed(1)} km away',
                style: const TextStyle(
                  fontSize: 12,
                  color: ColorManager.navyPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorManager.error,
                    side: const BorderSide(color: ColorManager.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(StringManager.reject),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.greenAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(StringManager.accept),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TripActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  const TripActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: ColorManager.backgroundWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    state.tripActionStatus == TripActionStatus.inProgress
                    ? ColorManager.error
                    : ColorManager.greenAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                state.tripActionStatus == TripActionStatus.goingToPassenger
                    ? 'Arrived'
                    : state.tripActionStatus == TripActionStatus.arrived
                    ? 'Start Trip'
                    : 'End Trip',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
