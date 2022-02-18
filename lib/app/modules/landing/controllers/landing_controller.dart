import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iot_gps_kucing/app/themes/app_colors.dart';

class LandingController extends GetxController {
  late FirebaseMessaging firebaseMessaging;
  var currentIndex = 0.obs;

  @override
  void onInit() async {
    super.onInit();

    firebaseMessaging = FirebaseMessaging.instance;

    String? token = await firebaseMessaging.getToken();

    print(token);

    firebaseMessaging.subscribeToTopic("esp32");

    FirebaseMessaging.onMessage.listen((event) {
      Get.snackbar(
        event.notification!.title ?? "Informasi",
        event.notification!.body ?? "Kucing anda keluar dari radius",
        backgroundColor: dangerColor,
        icon: Icon(Icons.warning),
      );
    });
  }

  void changePage(int index) {
    currentIndex.value = index;
  }
}
