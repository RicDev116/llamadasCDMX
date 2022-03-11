import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
//DESARROLLADOS POR NOSOTROS
import 'package:login_template/global_data/global_controller/global_controller.dart';
import 'package:login_template/global_data/providers/api_provider.dart';
import 'package:login_template/src/data/Preferences.dart';
import 'package:login_template/src/widgets/app_dialogs.dart';
import 'package:login_template/src/Utils/utils.dart' as utils;

class LoginController extends GetxController {

  bool showPassword = false;
  final _apiProvider = Get.find<API>();
  final globalController = Get.find<GlobalController>();

  final formKey = GlobalKey<FormState>();

  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  bool isLoadingDB = false;

  @override
  void onInit() async {
    globalController.tablasEncuestas.clear();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }


  void changeValueShowPassword(){
    showPassword = !showPassword;
    update(["password"]);
  }

  void login(context) async {
    if(await utils.permissionsWereAcepted() == false){
      return;
    }
    if (!formKey.currentState.validate()) {
      print("Error de formulario");
    } else {
      if (globalController.connectionStatus != ConnectivityResult.none) {
        await utils.initGeolocation();
        AppDialogs.loadDialog('Llamadas', 'Iniciando sesión');
        print("Login en curso...");
        final LocationData _location = await utils.getLocation();
        sharedPrefs.preferencesSaveLocation(_location.longitude, _location.latitude);
        Map<String, dynamic> data = {
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
          // 'imei': sharedPrefs.imei,
          // 'imei': await utils.getImei(),
          // 'latitude': _location.latitude.toString(),
          // 'longitude': _location.longitude.toString(),
        };
        try {
          Response _response =await _apiProvider.call("get", "login", data, null).timeout(const Duration(seconds: 10));
          // print(_response.body["response"]);
          Get.back(); 
          if (_response.status.hasError ||_response.body["error"] != 0) {
            print("Error");
            AppDialogs.alertDialog(
              "Inicio de sesión",
              _response.body["message"],
            );
          } else if (_response.isOk) {
            print("Ok");
            sharedPrefs.saveData(emailController.text.trim(),_response.body["api_token"]);
            globalController.login = true;
            Get.offAllNamed("/home");
            // if (await utils.checkVersion()) {
            //   // await DBProvider.db.deleteOldRegisters();
            //   // print(_response.body["data"]);
            //   // isLoadingDB = true;
            //   // final userModel = new UserModel.fromJson(_response.body["data"]["user"]);
            //   // isLoadingDB = false;
            //   // await DBProvider.db.nuevoUsuario(userModel);
            //   // globalController.getEncuestasToMakeAnMap();
            //   globalController.login = true;
            //   Get.offAllNamed("/home");
            // }
          }
        } on TimeoutException catch (e) {
          print('Timeout: $e');
          Navigator.pop(context);
          AppDialogs.alertDialog("Tiempo de Espera Agotado",
              "Verifique que su conexión a internet sea estable e intente nuevamente");
        } on Error catch (e) {
          print('Error: $e');
          Navigator.pop(context);
          AppDialogs.alertDialog(
              "Error al Iniciar Sesión", "Ocurrió un error al iniciar sesión intente nuevamente más tarde");
        }
      }else{
        AppDialogs.alertDialog(
          "Inicio de sesión",
          "No tienes conexión a internet, comprueba tu conexión y intentalo más tarde",
        );
      }
    }
  }
}
