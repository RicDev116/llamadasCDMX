import 'package:get/get.dart';
import 'package:login_template/src/modules/app_version/controllers/app_version_controller.dart';
import 'package:login_template/src/modules/home/controllers/home_controller.dart';
import 'package:login_template/src/modules/login/controllers/login_controller.dart';

  //* Inicializacion de todos los controladores que son 
//* requeridos al momento de iniciar la aplicacion
class InitialBindings extends Bindings {

  @override
  void dependencies() {

    Get.lazyPut<LoginController>(
      () => LoginController(),
      fenix: true
    );
    
    Get.lazyPut<HomeController>(
      () => HomeController(),
      fenix: true
    );

    Get.lazyPut<AppVersionController>(
      () => AppVersionController(),
      fenix: true
    );
  }

}
