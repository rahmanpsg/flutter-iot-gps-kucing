import 'package:get/get.dart';
import 'package:iot_gps_kucing/app/modules/lokasi/controllers/lokasi_controller.dart';

import '../controllers/landing_controller.dart';

class LandingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LandingController>(
      () => LandingController(),
    );
    Get.lazyPut<LokasiController>(
      () => LokasiController(),
    );
  }
}
