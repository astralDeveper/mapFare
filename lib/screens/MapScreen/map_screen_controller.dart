import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as g;
import 'package:latlong2/latlong.dart' as lat;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class MyMapController extends GetxController with WidgetsBindingObserver{
  Completer<g.GoogleMapController> mapControllerCompleter = Completer();
  g.GoogleMapController? mapController;
  var fromController = TextEditingController().obs;
  var toController = TextEditingController().obs;
  var sessionToken = ''.obs;
  var toPlaceList = [].obs;
  var fromPlaceList = [].obs;
  var currentPosition = Rxn<g.LatLng>();
  var destinationPosition = Rxn<g.LatLng>();
  RxBool isButtonLoading = false.obs;
  RxBool fromControllerStatus = false.obs;
  RxBool toControllerStatus = false.obs;
  RxBool isUserselectedFromPlace = false.obs;
  RxBool isUserselectedToPlace = false.obs;
  RxBool isgettingsuggestion = false.obs;

  RxDouble distanceInKm = 0.0.obs;
  Rx<g.LatLng> toLatLong = g.LatLng(0, 0).obs;
  Rx<g.LatLng> fromLatLong = g.LatLng(0, 0).obs;
  final RxSet<g.Polyline> polyline = RxSet<g.Polyline>();
  // var polyline = <g.Polyline>{}.obs; // This is an RxSet<g.Polyline>


  @override
  void onInit() {
    WidgetsBinding.instance.addObserver(this);
    fetchCurrentLocation();
    super.onInit();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if(state == AppLifecycleState.resumed) {
      fetchCurrentLocation();
    }
  }

  void onMapCreated(g.GoogleMapController  controller) {
    if (!mapControllerCompleter.isCompleted) {
      mapControllerCompleter.complete(controller);
    }
  }


  Future<void> fetchCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(fromController.value.text.isNotEmpty) {
      return;
    }
    if (!serviceEnabled) {
      showLocationServicesDialog();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Location Permission Denied', 'Please grant location permission.');

        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Location Permission Permanently Denied',
          'Please grant location permission from settings.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    log("latitude: ${position.latitude}");
    log("longitude: ${position.longitude}");
    currentPosition.value = g.LatLng(position.latitude, position.longitude);
    await getLocationName(position.latitude, position.longitude);
  }
  Future<void> showLocationServicesDialog() async {
    Get.dialog(
      barrierDismissible: false,
      useSafeArea: true,
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Row(
          children: [
            Icon(
              Icons.location_off,
              color: Colors.redAccent,
            ),
            SizedBox(width: 10),
            Text(
              'Enable Location Services',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Location services are disabled. Please enable them in the settings to continue.',
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.redAccent),
            ),
            onPressed: () {
              Get.back();
            },
          ),
          TextButton(
            child: Text(
              'Settings',
              style: TextStyle(color: Colors.blueAccent),
            ),
            onPressed: () {
              Get.back();
              Geolocator.openLocationSettings();
            },
          ),
        ],
      ),
    );
  }

  Future<void> getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        log("Place: $place");
        String locationName = '${place.name}, ${place.subLocality}, ${place.locality}, ${place.country}';
        log("Location Name: $locationName");
        fromController.value.text = locationName;
        isUserselectedFromPlace.value = true;
        fromLatLong.value = g.LatLng(latitude, longitude);
        // You can update a variable or use the locationName as needed in your app
      } else {
        log("No placemarks found for the given coordinates.");
      }
    } catch (e) {
      log("Error retrieving location name: $e");
    }
  }
  Future<void> getToPlaceSuggestions(String input) async {
    isgettingsuggestion.value = true;
    if (sessionToken.value.isEmpty) {
      sessionToken.value = Uuid().v4();
    }

    if (input.isEmpty) return;
    const String apiKey = 'AIzaSyChc3ppAhseCxXlilWVV-lbJmeo5cX6HL4';
    String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$baseURL?input=$input&key=$apiKey&sessiontoken=${sessionToken.value}';

    try {
      final response = await http.get(Uri.parse(request));
      final data = json.decode(response.body);
      log("getToPlaceSuggestions: ${data.toString()}");
      if (data['status'] == 'OK') {
        //log("Data: ${data}");
        toPlaceList.value = data['predictions'];
      } else {
        toPlaceList.clear();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch suggestions');
    }
  }

  Future<void> getFromPlaceSuggestions(String input) async {
isgettingsuggestion.value = true;
    if (sessionToken.value.isEmpty) {
      sessionToken.value = Uuid().v4();
    }

    if (input.isEmpty) return;
    const String apiKey = 'AIzaSyChc3ppAhseCxXlilWVV-lbJmeo5cX6HL4';
    String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$baseURL?input=$input&key=$apiKey&sessiontoken=${sessionToken.value}';

    try {
      final response = await http.get(Uri.parse(request));
      final data = json.decode(response.body);
      log("Data: ${data.toString()}");
      if (data['status'] == 'OK') {
        fromPlaceList.value = data['predictions'];
      } else {
        fromPlaceList.clear();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch suggestions');
    }
  }

  Future<g.LatLng> getToPlaceCoordinates(String placeId) async {
    final apiKey = 'AIzaSyChc3ppAhseCxXlilWVV-lbJmeo5cX6HL4';

      final detailsUrl = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

      // Get place details
      final detailsResponse = await http.get(Uri.parse(detailsUrl));
      if (detailsResponse.statusCode == 200) {
        final details = jsonDecode(detailsResponse.body);
        final location = details['result']['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];
        toLatLong.value = g.LatLng(lat, lng);
        log('TO Latitude: $lat, Longitude: $lng');
        return g.LatLng(lat, lng);
      } else {
        log('Failed to fetch place details');
        return g.LatLng(0, 0);
      }
    }

  Future<g.LatLng> getFromPlaceCoordinates(String placeId) async {
    final apiKey = 'AIzaSyChc3ppAhseCxXlilWVV-lbJmeo5cX6HL4';

    final detailsUrl = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    // Get place details
    final detailsResponse = await http.get(Uri.parse(detailsUrl));
    if (detailsResponse.statusCode == 200) {
      final details = jsonDecode(detailsResponse.body);
      final location = details['result']['geometry']['location'];

      final lat = location['lat'];
      final lng = location['lng'];
      fromLatLong.value = g.LatLng(lat, lng);
      log('From Latitude: $lat, Longitude: $lng');
      return g.LatLng(lat, lng);
    } else {
      log('Failed to fetch place details');
      return g.LatLng(0, 0);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  }