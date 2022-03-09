import 'package:get/get.dart';
import 'package:login_template/src/modules/app_version/bindings/app_version_binding.dart';
import 'package:login_template/src/modules/app_version/views/app_version_view.dart';
import 'package:login_template/src/modules/home/bindings/home_binding.dart';
import 'package:login_template/src/modules/home/views/home_view.dart';
import 'package:login_template/src/modules/login/bindings/login_binding.dart';
import 'package:login_template/src/modules/login/views/login_view.dart';

part 'app_routes.dart';

class AppPages{

  AppPages._();

  static const LOGIN = Routes.LOGIN;
  static const HOME = Routes.HOME;
  static const CUOTAS = Routes.CUOTAS;
  static const ENCUESTA = Routes.ENCUESTA;
  
    static final routes = [
      GetPage(
        name: '/login', 
        page: () => LoginView(),
        binding: LoginBinding(),
      ),
      GetPage(
        name: '/home', 
        page: () => HomeView(),
        binding: HomeBinding(),
      ),
      GetPage(
        name: '/app/version', 
        page: () => AppVersionView(),
        binding: AppVersionBinding(),
      ),
      
    ];
}

//TODO agregar bindings de app 