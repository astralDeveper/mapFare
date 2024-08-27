import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:latlong2/latlong.dart' as lat;
import 'package:google_map/res/colors.dart';
import 'package:google_map/screens/MapScreen/map_screen_widgets.dart';
import 'package:google_map/screens/fare_details.dart';
import 'package:google_map/screens/MapScreen/map_screen_controller.dart';

import '../widgets/custom_snackbar.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  // final Set<gmaps.Polyline> _polyline = {}; // Initialize polyline set

  MyMapController controller = Get.find<MyMapController>();
  final FocusNode fromFocusNode = FocusNode();
  final FocusNode toFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.mapController!.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log("from lat: ${controller.fromLatLong.value.latitude} from lon: ${controller.fromLatLong.value.longitude}");
    return Scaffold(
      backgroundColor: AppColors.appColor,
      body: Obx(() {
        return SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Image.asset(
                'assets/logo.png',
                height: 40,
              ),
              _buildSearchField(
                focusNode: fromFocusNode,
                controller: controller.fromController.value,
                hintText: 'From: ',
                onChanged: (value) {
                  controller.isUserselectedFromPlace.value = false;
                  controller.getFromPlaceSuggestions(value);
                },
                onTap: () {
                  controller.fromControllerStatus.value = true;
                },
                onSubmitted: (p0) {
                  if (controller.isUserselectedFromPlace.isFalse) {
                    controller.fromController.value.text = "";
                    CustomSnackBar.showSnackBar(
                      title: 'Error',
                      message: "Please select a location from the suggestions",
                      icon: Icons.error,
                    );
                  } else {
                    if (controller.isUserselectedToPlace.isTrue) {
                    } else {
                      toFocusNode.requestFocus();
                    }
                  }
                },
              ),
              _buildSearchField(
                focusNode: toFocusNode,
                controller: controller.toController.value,
                hintText: 'To: ',
                onChanged: (value) {
                  controller.isUserselectedToPlace.value = false;
                  controller.getToPlaceSuggestions(value);
                },
                onSubmitted: (p0) {
                  if (controller.isUserselectedToPlace.isFalse) {
                    controller.toController.value.text = "";
                    CustomSnackBar.showSnackBar(
                      title: 'Error',
                      message: "Please select a location from the suggestions",
                      icon: Icons.error,
                    );
                  }
                },
                onTap: () {
                  if (controller.isUserselectedFromPlace.isFalse) {
                    fromFocusNode.requestFocus();
                    controller.fromController.value.text = "";
                    CustomSnackBar.showSnackBar(
                      title: 'Error',
                      message: "Please select valid 'From' location first",
                      icon: Icons.error,
                    );
                    return;
                  }
                  controller.toControllerStatus.value = true;
                },
              ),
              SizedBox(
                height: 10,
              ),
              if (controller.toPlaceList.isNotEmpty)
                _buildPlaceSuggestions(controller.toPlaceList, (index) async {
                  toFocusNode.unfocus();
                  controller.toController.value.text = controller
                      .toPlaceList[index]['structured_formatting']['main_text'];
                  if (controller.polyline.isNotEmpty) {
                    controller.polyline.clear();
                  }
                  if (controller.toLatLong.value != const gmaps.LatLng(0, 0)) {
                    controller.toLatLong.value = const gmaps.LatLng(0, 0);
                  }
                  controller.isUserselectedToPlace.value = true;

                  log('hehe:${controller.toPlaceList[index]['structured_formatting']['main_text']}');
                  controller
                      .getToPlaceCoordinates(
                          controller.toPlaceList[index]['place_id'])
                      .then(
                    (value) {
                      if (controller.isUserselectedFromPlace.isTrue) {
                        if (controller.polyline.isNotEmpty) {
                          controller.polyline.clear();
                          // _drawPolyline();
                          _getRoute(
                              fromlat: controller.fromLatLong.value,
                              toLat: value);
                          setState(() {});
                        } else {
                          // _drawPolyline();
                          _getRoute(
                              fromlat: controller.fromLatLong.value,
                              toLat: value);
                          setState(() {});
                        }
                      }
                    },
                  );
                  controller.toPlaceList.clear();
                }),
              if (controller.fromPlaceList.isNotEmpty)
                _buildPlaceSuggestions(controller.fromPlaceList, (index) async {
                  fromFocusNode.unfocus();
                  if (controller.polyline.isNotEmpty) {
                    controller.polyline.clear();
                  }

                  if (controller.fromLatLong.value !=
                      const gmaps.LatLng(0, 0)) {
                    controller.fromLatLong.value = const gmaps.LatLng(0, 0);
                  }
                  controller.isUserselectedFromPlace.value = true;

                  controller.fromController.value.text =
                      controller.fromPlaceList[index]['structured_formatting']
                          ['main_text'];
                  controller
                      .getFromPlaceCoordinates(
                          controller.fromPlaceList[index]['place_id'])
                      .then(
                    (value) {
                      if (controller.isUserselectedToPlace.isTrue) {
                        if (controller.polyline.isNotEmpty) {
                          controller.polyline.clear();
                          // _drawPolyline();
                          _getRoute(
                              fromlat: value,
                              toLat: controller.toLatLong.value);
                          setState(() {});
                        } else {
                          // _drawPolyline();
                          _getRoute(
                              fromlat: value,
                              toLat: controller.toLatLong.value);
                          setState(() {});
                        }
                      }
                    },
                  );
                  controller.fromPlaceList.clear();
                }),
              if (controller.currentPosition.value != null)
                controller.isgettingsuggestion.isFalse ?
                Expanded(
                  child: Obx(
                    () {
                      return Stack(
                        children: [
                          gmaps.GoogleMap(
                            onMapCreated: controller.onMapCreated,
                            initialCameraPosition: gmaps.CameraPosition(
                              target: controller.currentPosition.value != null
                                  ? controller.currentPosition.value!
                                  : const gmaps.LatLng(30.3753, 69.3451),
                              zoom: 14.0,
                            ),
                            polylines: controller
                                .polyline, // Set the polyline to the map
                            markers: _buildMarkers(),
                          ),
                          if (controller.isButtonLoading.value)
                            const Center(
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      );
                    },
                  ),
                )
                :SizedBox(),
              RoundedButton(
                title: "Go",
                isDisabled: controller.isUserselectedFromPlace.isFalse ||
                    controller.isUserselectedToPlace.isFalse ||
                    controller.polyline.isEmpty,
                onTap: () {
                  if (controller.polyline.isEmpty) {
                    CustomSnackBar.showSnackBar(
                      title: 'Error',
                      message: "Please select valid From and To locations",
                      icon: Icons.error,
                    );
                    return;
                  }
                  if (controller.fromController.value.text.isEmpty ||
                      controller.toController.value.text.isEmpty) {
                    CustomSnackBar.showSnackBar(
                      title: 'Error',
                      message: 'Please enter both "From" and "To" locations',
                      icon: Icons.error,
                    );
                    return;
                  }
                  double distance = calculateDistance(
                      controller.fromLatLong.value, controller.toLatLong.value);
                  log("Km: $distance");
                  Get.to(FareDetailsScreen(
                    distance: distance,
                    fromLocation: controller.fromController.value.text,
                    toLocation: controller.toController.value.text,
                  ));
                  // _drawPolyline(); // Draw the polyline when 'Go' is tapped
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _getRoute(
      {required gmaps.LatLng toLat, required gmaps.LatLng fromlat}) async {
    // Replace with your Google API Key
    controller.isButtonLoading.value = true;
    String googleAPIKey = 'AIzaSyChc3ppAhseCxXlilWVV-lbJmeo5cX6HL4';
    log("getroute: from lat: ${fromlat.latitude} from lon: ${fromlat.longitude}");
    log("getroute: to lat: ${toLat.latitude} from lon: ${toLat.longitude}");
    String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${fromlat.latitude},${fromlat.longitude}&'
        'destination=${toLat.latitude},${toLat.longitude}&'
        'key=$googleAPIKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        controller.isButtonLoading.value = false;
      });
      final data = json.decode(response.body);
      log(response.body);
      final points =
          _decodePolyline(data['routes'][0]['overview_polyline']['points']);
      _addPolyline(points);
      controller.currentPosition.value =
          gmaps.LatLng(fromlat.latitude, fromlat.longitude);
    } else {
      log('Failed to load route');
    }
  }

  void _addPolyline(List<gmaps.LatLng> points) {
    final polyline = gmaps.Polyline(
      polylineId: const gmaps.PolylineId('route'),
      points: points,
      color: Colors.blue,
      width: 5,
    );
    setState(() {
      controller.isButtonLoading.value = false;
      controller.polyline.add(polyline);
    });
  }

  // Helper function to decode polyline
  List<gmaps.LatLng> _decodePolyline(String encoded) {
    List<gmaps.LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(gmaps.LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }

  double calculateDistance(
      gmaps.LatLng currentLocation, gmaps.LatLng destination) {
    final lat.LatLng startLatlong = googleToLatlong(currentLocation);
    final lat.LatLng endLatlong = googleToLatlong(destination);
    final lat.Distance distance = const lat.Distance();
    final double distanceInMeters = distance(startLatlong, endLatlong);
    return distanceInMeters / 1000;
  }

  lat.LatLng googleToLatlong(gmaps.LatLng googleLatLng) {
    return lat.LatLng(googleLatLng.latitude, googleLatLng.longitude);
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hintText,
    required Function(String) onChanged,
    required Function() onTap,
    required FocusNode focusNode,
    required Function(String) onSubmitted,
  }) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 50,
        width: 300,
        //color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Background color of the TextField
            borderRadius: BorderRadius.circular(15), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // Shadow color
                spreadRadius: 2, // Spread radius of the shadow
                blurRadius: 5, // Blur radius of the shadow
                offset: Offset(0, 3), // Offset of the shadow
              ),
            ],
          ),
          child: TextField(
            focusNode: focusNode,
            onChanged: onChanged,
            style: const TextStyle(
              color: Colors.black, // Text color
              fontSize: 14, // Slightly larger font size for better readability
            ),
            onTap: onTap,
            onSubmitted: onSubmitted,
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,

              hintStyle: TextStyle(
                color: Colors.grey[500], // Hint text color
                fontSize: 13, // Hint text size
              ),
              suffixIcon: Icon(
                Icons.location_on_outlined,
                color: const Color.fromARGB(
                    255, 218, 198, 26), // Icon color for visual appeal
              ),
              border: InputBorder.none,
              fillColor: Colors.amber, // Remove default border
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 16.0), // Padding inside the TextField
            ),
          ),
        ));
  }

  Widget _buildPlaceSuggestions(
      RxList<dynamic> placeList, Function(int) onTap) {
    return Expanded(
      child: Obx(
        () {
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: placeList.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.location_on_rounded),
                subtitle: Text(placeList[index]['description'],
                    style: const TextStyle(fontSize: 12),),
                title: Text(placeList[index]['structured_formatting']['main_text'],
                    style: const TextStyle(fontSize: 14)),
                onTap: () {
                  onTap(index);
                  controller.isgettingsuggestion.value = false;
                },
              );
            },
          );
        },
      ),
    );
  }

  Set<gmaps.Marker> _buildMarkers() {
    return {
      if (controller.currentPosition.value != null &&
          controller.toLatLong.value == const gmaps.LatLng(0, 0) &&
          controller.fromLatLong.value == const gmaps.LatLng(0, 0))
        gmaps.Marker(
          markerId: const gmaps.MarkerId('currentLocation'),
          position: controller.currentPosition.value!,
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
              gmaps.BitmapDescriptor.hueRed),
        ),
      if (controller.toLatLong.value != const gmaps.LatLng(0, 0))
        gmaps.Marker(
          markerId: const gmaps.MarkerId('To'),
          position: controller.toLatLong.value,
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
              gmaps.BitmapDescriptor.hueRed),
        ),
      if (controller.fromLatLong.value != const gmaps.LatLng(0, 0))
        gmaps.Marker(
          markerId: const gmaps.MarkerId('From'),
          position: controller.fromLatLong.value,
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
              gmaps.BitmapDescriptor.hueGreen),
        ),
    };
  }
}
