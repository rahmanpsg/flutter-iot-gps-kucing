import 'package:get/get.dart';

import '../controllers/lokasi_controller.dart';

class LokasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LokasiController>(
      () => LokasiController(),
    );
  }
}
