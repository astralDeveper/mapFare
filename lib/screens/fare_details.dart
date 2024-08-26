import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_map/res/colors.dart';
import 'package:get/get.dart';
import 'package:google_map/screens/FareDetails/timer_controller.dart';
import 'package:google_map/screens/MapScreen/map_screen_controller.dart';
import 'package:google_map/screens/widgets/custom_snackbar.dart';

class FareDetailsScreen extends StatefulWidget {
  FareDetailsScreen(
      {required this.distance,
      required this.fromLocation,
      required this.toLocation});
  String toLocation = "";
  String fromLocation = "";
  double distance = 0.0;

  @override
  State<FareDetailsScreen> createState() => _FareDetailsScreenState();
}

class _FareDetailsScreenState extends State<FareDetailsScreen> {
  TextEditingController _baseFareController = TextEditingController(text: "49");

  TimerController _timerController = Get.find<TimerController>();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    _timerController.calculateFare(
        distance: widget.distance,
        baseFare: double.parse(_baseFareController.text));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appColor,
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        automaticallyImplyLeading: true,
        title: const Text(
          'Fare Details',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                showStopwatchDialog();
              },
              icon: const Icon(Icons.watch_later_outlined))
        ],
      ),
      body: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            _timerController.resetTimer();
            _timerController.fare.value = "0.0";
            _timerController.extraCharges.value = 0.0;
          }
        },
        child: SingleChildScrollView(
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // To and From Addresses
                  Container(
                    width: Get.width,
                    child: Card(
                      color: Colors.grey[200],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('From: '),
                            Expanded(child: Text(widget.fromLocation)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: Get.width,
                    child: Card(
                      color: Colors.grey[200],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('To: '),
                            Expanded(child: Text(widget.toLocation)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Base Fare Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: Get.height * 0.07,
                        width: Get.width * 0.4,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                color: Colors.black,
                                strokeAlign: 1,
                                width: 1.5)),
                        child: Center(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            controller: _baseFareController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a base fare';
                              }
                              if (double.parse(value) < 49) {
                                return 'Base fare cannot be less than 49';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              hintText: "Base Fare",
                              border: InputBorder.none,
                              errorStyle: TextStyle(fontSize: 9.0),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: Get.height * 0.07,
                        width: Get.width * 0.4,
                        padding: const EdgeInsets.all(0),
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                color: Colors.black,
                                strokeAlign: 1,
                                width: 1.5)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 32.0, color: Colors.black),
                                Text(
                                  widget.distance.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12.0),
                            const Text(
                              "Km",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FareContainerDay(
                            isDay: _timerController.isDay.value,
                            topTitle: "Minimum Fare",
                            centerTitle: "Rs. 49",
                            bottomTitle: "Upto 1.5 Kms"),
                        FareContainer(
                            topTitle: "Beyond 1.5 Kms",
                            centerTitle: "Rs. 17",
                            bottomTitle: "per Km",
                            distance: widget.distance)
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        WaitingFareContainer(
                            topTitle: "Waiting Charges",
                            centerTitle: "Rs. 1",
                            bottomTitle: "per min",
                            waitingTime: _timerController.elapsedTime.value),
                        FareContainerNight(
                            isDay: _timerController.isDay.value,
                            topTitle: "Night Service",
                            centerTitle: "+50%",
                            bottomTitle: "10PM to 5AM")
                      ],
                    ),
                  ),

                  // Fare Calculation Result
                  Obx(() {
                    return Column(
                      children: [
                        const SizedBox(height: 8.0),
                        Text(
                          'Rs. ${_timerController.fare.value}',
                          style: const TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Base: Rs.${_baseFareController.text} + Others: Rs.${_timerController.extraCharges.value}',
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.black54),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 12),
                  // Get Fare Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            CustomSnackBar.showSnackBar(
                              title: 'Error',
                              message: 'Please enter a valid base fare',
                              icon: Icons.error,
                            );
                            return;
                          }
                          _timerController.calculateFare(
                              distance: widget.distance,
                              baseFare: double.parse(_baseFareController.text));
                          //_timerController.isDayTime();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Get Fare',
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void showStopwatchDialog() {
  Get.dialog(
    WillPopScope(
      onWillPop: () async =>
          false, // Prevent closing the dialog on back button press
      child: GetBuilder<TimerController>(
        init: TimerController(),
        builder: (controller) {
          return AlertDialog(
            title: const Center(child: Text('Waiting Time')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() => Text(
                      '${(controller.elapsedTime.value ~/ 60).toString().padLeft(2, '0')}:${(controller.elapsedTime.value % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 40),
                    )),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => controller.startTimer(),
                      child: const Text('Start'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => controller.stopTimer(),
                      child: const Text('Stop'),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  controller.stopTimer();
                  Get.back();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    ),
    barrierDismissible:
        false, // Prevent dialog from closing when clicking outside
  );
}

Widget FareContainer(
    {required String topTitle,
    required String centerTitle,
    required String bottomTitle,
    required double distance}) {
  return Container(
    height: Get.height * 0.14,
    width: Get.width * 0.4,
    padding: const EdgeInsets.all(0),
    decoration: BoxDecoration(
        color: distance > 1.5 ? AppColors.mainColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.black, strokeAlign: 1, width: 1.5)),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            topTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            centerTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          Text(bottomTitle),
        ],
      ),
    ),
  );
}

Widget WaitingFareContainer(
    {required String topTitle,
    required String centerTitle,
    required String bottomTitle,
    required int waitingTime}) {
  return Container(
    height: Get.height * 0.14,
    width: Get.width * 0.4,
    padding: const EdgeInsets.all(0),
    decoration: BoxDecoration(
        color: Duration(seconds: waitingTime).inMinutes.toString() == "0"
            ? Colors.transparent
            : AppColors.mainColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.black, strokeAlign: 1, width: 1.5)),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Waiting Mins: ${Duration(seconds: waitingTime).inMinutes.toString()}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            centerTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          Text(bottomTitle),
        ],
      ),
    ),
  );
}

Widget FareContainerDay(
    {required String topTitle,
    required String centerTitle,
    required String bottomTitle,
    required bool isDay}) {
  return Container(
    height: Get.height * 0.14,
    width: Get.width * 0.4,
    padding: const EdgeInsets.all(0),
    decoration: BoxDecoration(
        color: isDay ? AppColors.mainColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.black, strokeAlign: 1, width: 1.5)),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            topTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            centerTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          Text(bottomTitle),
        ],
      ),
    ),
  );
}

Widget FareContainerNight(
    {required String topTitle,
    required String centerTitle,
    required String bottomTitle,
    required bool isDay}) {
  return Container(
    height: Get.height * 0.14,
    width: Get.width * 0.4,
    padding: const EdgeInsets.all(0),
    decoration: BoxDecoration(
        color: !isDay ? AppColors.mainColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.black, strokeAlign: 1, width: 1.5)),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            topTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            centerTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          Text(bottomTitle),
        ],
      ),
    ),
  );
}

class FareButton extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? color;

  FareButton({
    required this.title,
    this.subtitle,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) Icon(icon, size: 32.0, color: Colors.black),
          if (icon != null) const SizedBox(height: 8.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          if (subtitle != null) const SizedBox(height: 8.0),
          if (subtitle != null)
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14.0),
            ),
        ],
      ),
    );
  }
}
