import 'package:flutter/material.dart';

import 'map_screen_controller.dart';
import 'package:get/get.dart';

MyMapController _mapGetxController = Get.find<MyMapController>();

Widget RoundedButton(
    {required String title,
      bool isDisabled = false,
    required VoidCallback onTap}) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: SizedBox(
      width: double.infinity,
      child: Obx(
        () {
          return ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDisabled ? const Color.fromRGBO(229,229,229,0.5) :Colors.yellow[700],
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: !_mapGetxController.isButtonLoading.value
                ? Text(
                    title,
                    style: TextStyle(fontSize: 18.0, color:isDisabled ? Colors.white : Colors.black ),
                  )
                : const CircularProgressIndicator(),
          );
        },
      ),
    ),
  );
}

Widget textForm({
  required TextEditingController controller,
  required String label,
  required bool currentLocationStatus,
  String? address,
  VoidCallback? onTap,
  ValueChanged<String>? onChanged,
}) {
  return Container(
    height: 36,
    width: 300,
    child: Center(
      child: TextField(
        onTap: onTap,
        onChanged: onChanged,
        controller: controller,
        decoration: InputDecoration(
          labelText: currentLocationStatus ? "$label $address" : "$label ",
          suffixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
          enabledBorder:
              const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    ),
  );
}
