import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:iot_gps_kucing/app/modules/lokasi/views/lokasi_view.dart';
import 'package:iot_gps_kucing/app/modules/pengaturan/views/pengaturan_view.dart';
import 'package:iot_gps_kucing/app/modules/profil/views/profil_view.dart';
import 'package:iot_gps_kucing/app/themes/app_colors.dart';

import '../controllers/landing_controller.dart';

class LandingView extends GetView<LandingController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: [
            ProfilView(),
            LokasiView(),
            PengaturanView(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_pin),
              label: 'Lokasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Pengaturan',
            ),
          ],
          currentIndex: controller.currentIndex.value,
          backgroundColor: primaryColor,
          selectedItemColor: Colors.black,
          unselectedItemColor: dangerColor,
          onTap: controller.changePage,
        ),
      ),
    );
  }
}
