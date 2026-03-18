import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_driver/core/constants/color_manager.dart';
import 'package:go_driver/core/constants/font_manager.dart';
import 'package:go_driver/core/di/service_locator.dart';
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
            body: SafeArea(
              child: Stack(
                children: [
                  const Map(),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: CircleAvatar(
                      backgroundColor: ColorManager.navyLight,
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
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: state.isOnline
                            ? Colors.transparent
                            : ColorManager.error,
                      ),
                      child: SwitchListTile(
                        value: state.isOnline,
                        onChanged: (_) => cubit.toggleStatus(),
                        title: Text(
                          state.isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: state.isOnline
                                ? ColorManager.greenAccent
                                : Colors.white,
                            fontWeight: FontWeightManager.semiBold,
                          ),
                        ),
                        activeThumbColor: ColorManager.greenAccent,
                        inactiveThumbColor: ColorManager.error,
                      ),
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
                        child: state.isOnline
                            ? SingleChildScrollView(
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
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: state.orders?.length ?? 0,
                                      itemBuilder: (context, index) {
                                        return OrderItem(
                                          order: state.orders![index],
                                          distanceToPassenger: cubit
                                              .getDistanceToPassenger(
                                                state.orders![index],
                                              ),
                                          onReject: () => {},
                                          onAccept: () => {},
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              )
                            : Center(child: Text('Offline Mode')),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
