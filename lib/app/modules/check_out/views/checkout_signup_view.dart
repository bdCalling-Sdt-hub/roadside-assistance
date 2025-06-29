import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roadside_assistance/app/modules/check_out/controllers/check_out_controller.dart';
import 'package:roadside_assistance/app/modules/check_out/controllers/vehicle_controller.dart';
import 'package:roadside_assistance/app/modules/check_out/model/vehiclelist_model.dar.dart';
import 'package:roadside_assistance/app/modules/my_location_selection/controllers/my_location_selection_controller.dart';
import 'package:roadside_assistance/app/routes/app_pages.dart';
import 'package:roadside_assistance/common/Alert_dialouge/thank_you_dialouge.dart';
import 'package:roadside_assistance/common/app_color/app_colors.dart';
import 'package:roadside_assistance/common/app_text_style/google_app_style.dart';
import 'package:roadside_assistance/common/widgets/custom_button.dart';
import 'package:roadside_assistance/common/widgets/custom_page_loading.dart';
import 'package:roadside_assistance/common/widgets/custom_text_field.dart';

class CheckoutSignupView extends StatefulWidget {
  const CheckoutSignupView({super.key});

  @override
  State<CheckoutSignupView> createState() => _CheckoutSignupViewState();
}

class _CheckoutSignupViewState extends State<CheckoutSignupView> {
  final MyLocationSelectionController _locationSelectionCtrl = Get.put(
    MyLocationSelectionController(),
  );
  final CheckOutController _checkOutController = Get.put(CheckOutController());
  final VehicleController _vehicleController = Get.put(VehicleController());
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

  GoogleMapController? mapController;

  final LatLng center = const LatLng(25.432608, -80.133209);
  LatLng? currentLocation;
  List<String> onChangeTextFieldValue = [];
  BitmapDescriptor? customIcon;

  void moveCamera(LatLng target) {
    currentLocation = target;
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 15)),
    );
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_locationSelectionCtrl.pickedNewLocation != null) {
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _locationSelectionCtrl.pickedNewLocation!),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    currentLocation = _locationSelectionCtrl.pickedNewLocation;

    WidgetsBinding.instance.addPostFrameCallback((__) async {
      await _vehicleController.fetchVehicle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ADDRESS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                //  SizedBox(height: 8.h),
                // CustomTextButtonWithIcon(
                //   padding: EdgeInsets.symmetric(horizontal: 0),
                //   width: 200,
                //   height: 35,
                //   onTap: () {},
                //   icon: const Icon(Icons.location_on, color: Colors.blue),
                //   text: 'Use my current location',
                // ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Set on map', style: GoogleFontStyles.h4()),
                    TextButton(
                      onPressed: () async {
                        final result = await Get.toNamed(Routes.MAP);
                        if (result != null && result is LatLng) {
                          setState(() {
                            currentLocation = result; // Update local state
                            _locationSelectionCtrl.pickedNewLocation = result;
                            _checkOutController.pickupAddressCtrl.text =
                                _locationSelectionCtrl.pickupLocationCtrl.text;
                          });
                          moveCamera(result); // Move map to new location
                        }
                      },
                      child: Text(
                        'View map',
                        style: GoogleFontStyles.h4(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                /// Map Placeholder
                Container(
                  height: 200.h,
                  color: Colors.grey[300],
                  child: Center(
                    child: GoogleMap(
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: true,
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: currentLocation ?? center,
                        zoom: currentLocation != null ? 15.0 : 11.0,
                      ),
                      onTap: (position) {
                        moveCamera(position);
                      },
                      myLocationEnabled: true,
                      markers: {
                        if (currentLocation != null)
                          Marker(
                            markerId: MarkerId(currentLocation.toString()),
                            position: currentLocation!,
                            onDragEnd: (newPosition) {
                              print('New position: $newPosition');
                              moveCamera(newPosition);
                            },
                          ),
                      },
                    ),
                  ),
                ),

                SizedBox(height: 16.h),
                const Text(
                  'Address',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8.h),

                /// Address Fields
                buildCustomTextField(
                  hintText: 'Enter Pickup Address',
                  controller: _checkOutController.pickupAddressCtrl,
                ),
                SizedBox(height: 8.h),
                const Text(
                  'Street no',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8.h),
                buildCustomTextField(
                  hintText: 'Street No',
                  controller: _checkOutController.streetNoCtrl,
                ),
                SizedBox(height: 16.h),

                /// Vehicle Model
                _vehicleController.selectedValue.value.isEmpty
                    ? Card(
                      child: Padding(
                        padding: EdgeInsets.all(8.0.sp),
                        child: Form(
                          key: _formKey2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vehicle Model',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              buildCustomTextField(
                                hintText: 'Enter Vehicle Model',
                                controller: _vehicleController.vehicleModelCtrl,
                              ),
                              SizedBox(height: 16.h),

                              /// Vehicle Brand
                              const Text(
                                'Vehicle Brand',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              buildCustomTextField(
                                hintText: 'Enter Vehicle Brand',
                                controller: _vehicleController.vehicleBrandCtrl,
                              ),
                              SizedBox(height: 16.h),

                              /// Vehicle Number
                              const Text(
                                'Vehicle Number',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              buildCustomTextField(
                                hintText: 'Enter Vehicle number',
                                controller:
                                    _vehicleController.vehicleNumberCtrl,
                              ),
                              SizedBox(height: 16.h),

                              /// Save Vehicle Button
                              Obx(() {
                                return CustomButton(
                                  loading: _vehicleController.isLoading2.value,
                                  width: 135.w,
                                  onTap: () async {
                                    if (_formKey2.currentState!.validate()) {
                                      await _vehicleController.addVehicle();
                                    }
                                  },
                                  text: 'Add vehicle',
                                );
                              }),
                              SizedBox(height: 16.h),
                            ],
                          ),
                        ),
                      ),
                    ) : SizedBox.shrink(),

                /// Vehicle Selection (Radio Button)
                Obx(() {
                  List<Vehicle>? vehicleListData =
                      _vehicleController.vehicleListModel.value.data;
                  if (_vehicleController.isLoading.value) {
                    return CustomPageLoading();
                  } else if (vehicleListData!.isEmpty) {
                    return Text("Vehicle isn't added yet Or looks empty");
                  }
                  return SizedBox(
                    height: 80.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: vehicleListData.length,
                      itemBuilder: (context, index) {
                        final vehicleDataIndex = vehicleListData[index];
                        return IntrinsicWidth(
                          child: RadioListTile(
                            value: vehicleDataIndex.id,
                            groupValue: _vehicleController.selectedValue.value,
                            //model
                            title: Text('${vehicleDataIndex.model}'),
                            //number
                            subtitle: Text('${vehicleDataIndex.number}'),
                            onChanged: (value) {
                              _vehicleController.selectedValue.value =
                                  value ?? '';
                              setState(() {});
                              print(_vehicleController.selectedValue.value);
                            },
                          ),
                        );
                      },
                    ),
                  );
                }),
                // Row(
                //   children: [
                //     ...List.generate(3, (index){
                //       return  Expanded(
                //           child: RadioListTile(
                //               value: 'Honda Shine',
                //               groupValue: 'asdjalsjdlkasjd',
                //               title: Text('Honda Shine'),
                //               subtitle: Text('Model-XBC123'),
                //               onChanged: (value){
                //
                //               }
                //           )
                //       );
                //     })
                //   ],
                // ),
                SizedBox(height: 16.h),

                /// Additional Note
                const Text(
                  'Additional Note',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  hintText: 'Type here...',
                  controller: _checkOutController.additionalNoteCtrl,
                  maxLine: 2,
                  validator: (value) {
                    if (value == null) {
                      return null;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                /// Book Button
                CustomButton(
                  onTap: () async {
                    print(
                      'latlang new :${_locationSelectionCtrl.pickedNewLocation}');
                    if (_formKey1.currentState!.validate() &&
                        _vehicleController.selectedValue.value.isNotEmpty &&
                        _locationSelectionCtrl.pickedNewLocation != null &&
                         _checkOutController.serviceRateList.isNotEmpty
                    ) {
                      await _checkOutController.book(
                        vehicleId: _vehicleController.selectedValue.value,
                        coordinates: _locationSelectionCtrl.pickedNewLocation,
                        callBack: () {
                          ThankYouDialog.show(context);
                        },
                      );
                    }else{
                      Get.snackbar('Incomplete Input', 'You have to complete all input for valid service booking');
                    }
                  },
                  text: 'Book',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCustomTextField({
    required String hintText,
    required TextEditingController controller,
    int? maxLines = 1,
  }) {
    return CustomTextField(
      hintText: hintText,
      contentPaddingVertical: 16.h,
      controller: controller,
      maxLine: maxLines,
    );
  }
}
