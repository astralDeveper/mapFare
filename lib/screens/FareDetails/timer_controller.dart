import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class TimerController extends GetxController with WidgetsBindingObserver {
  var isRunning = false.obs;
  var elapsedTime = 0.obs;
  Timer? timer;
  RxBool isDay = false.obs;
  RxString fare = "0.0".obs;
  RxDouble extraCharges = 0.0 .obs;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if(state == AppLifecycleState.resumed) {
      isDay.value = isDayTime();
    }
  }


  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    isDay.value = isDayTime();
    fare.value = "0.0";
    WidgetsBinding.instance.addObserver(this);
  }



  bool isDayTime() {
    final now = DateTime.now();
    final currentHour = now.hour;

    log(now.toString());
    log(currentHour.toString());
    // Daytime is between 5:00 AM and 10:00 PM
    if (currentHour >= 5 && currentHour < 22) {
      log("Day");
      return true; // Daytime
    } else {
      log("Night");
      return false; // Nighttime
    }
  }

  void calculateFare({required double distance, required double baseFare}) {
    if (isDay.value) {
      if(distance > 1.5) {
        extraCharges.value = ( 17 * distance).roundToDouble();
      }
      if(elapsedTime.value > 60) {

        extraCharges.value += ( 1 * (elapsedTime.value/60)).roundToDouble();
      }
      log("Extra Charges: ${extraCharges.value}");
      fare.value = (baseFare + extraCharges.value).toStringAsFixed(2);
      log("Day Fare: ${fare.value}");
    } else {
      if(distance > 1.5) {
        extraCharges.value = ( 17 * distance * 1.5).roundToDouble();
      }
      if(elapsedTime.value > 60) {

        extraCharges.value += ( 1 * (elapsedTime.value/60)).roundToDouble();
      }
      log("Extra Charges: ${extraCharges.value}");
      fare.value = (baseFare+extraCharges.value).toStringAsFixed(2);
      log("Night Fare: ${fare.value}");
    }

  }
  void startTimer() {
    if (!isRunning.value) {
      isRunning.value = true;
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        elapsedTime.value= elapsedTime.value + 1;
      });
    }
  }

  void stopTimer() {
    if (isRunning.value) {
      isRunning.value = false;
      log(elapsedTime.value.toString());
      timer?.cancel();
    }
  }

  void resetTimer() {
    stopTimer();
    elapsedTime.value = 0;
  }

  @override
  void dispose() {
    log("TimerController disposed");
    timer?.cancel();
    fare.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
