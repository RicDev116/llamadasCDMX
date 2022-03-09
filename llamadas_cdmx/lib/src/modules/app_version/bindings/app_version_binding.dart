
import 'package:get/get.dart';

class AppVersionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppVersionBinding>(
      () => AppVersionBinding(),
      fenix: true
    );
  }
}
