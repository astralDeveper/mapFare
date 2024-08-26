import 'package:flutter/material.dart';
import 'package:google_map/screens/FareDetails/timer_controller.dart';
import 'package:google_map/screens/MapScreen/map_screen_controller.dart';
import 'package:google_map/screens/MapScreen/placesmap.dart';
import 'package:google_map/screens/fare_details.dart';

import 'package:get/get.dart';
import 'res/routes/get_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(MyMapController());
  Get.put(TimerController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      getPages: GetAppRoutes().getAppRoutes(),
      home: GoogleMapScreen(),
    );
  }
}
