import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_driver/core/constants/color_manager.dart';
import 'package:go_driver/core/di/service_locator.dart';
import 'package:go_driver/features/home/data/models/order_model.dart';
import 'package:go_driver/features/home/data/repository/repo.dart';
import 'package:go_driver/features/home/logic/cubit.dart';
import 'package:go_driver/features/home/logic/states.dart';
import 'package:go_driver/features/home/presentation/shared_widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _destinationController;

  @override
  void initState() {
    super.initState();
    _destinationController = TextEditingController();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(getIt<HomeRepository>())..init(context),
      child: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state.status == HomeStatus.error) {
            Fluttertoast.showToast(msg: state.error);
          }
        },
        builder: (context, state) {
          final cubit = context.read<HomeCubit>();
          return Scaffold(
            body: Stack(
              children: [
                const Map(),
                Positioned(
                  top: 10,
                  left: 10,
                  child: IconButton(
                    onPressed: () => cubit.moveTo(
                      LatLng(
                        state.position!.latitude,
                        state.position!.longitude,
                      ),
                      isCurrentLocation: true,
                      zoom: 17,
                    ),
                    icon: Icon(Icons.gps_fixed, color: Colors.white),
                  ),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  minChildSize: 0.25,
                  builder: (context, scrollController) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: ColorManager.backgroundWhite,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: ColorManager.gray500,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 1,
                              itemBuilder: (context, index) {
                                return OrderItem(
                                  order:
                                      state.order ??
                                      OrderModel(
                                        id: '123456',
                                        destination: 'Cairo',
                                        distanceKm: 54,
                                        durationMin: 55,
                                        price: 350,
                                        destinationLat: 30.046361,
                                        destinationLng: 31.234922,
                                        passengerId: '30.046361',
                                      ),
                                  onReject: () => {},
                                  onAccept: () => {},
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
