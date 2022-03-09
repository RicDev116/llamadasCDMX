import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
//DESARROLLADOS POR NOSOTROS
import 'package:login_template/global_data/global_controller/global_controller.dart';
import 'package:login_template/global_data/providers/api_provider.dart';
import 'package:login_template/global_data/providers/db_provider.dart';
import 'package:login_template/models/user_model.dart';
import 'package:login_template/src/data/Preferences.dart';
import 'package:login_template/src/widgets/app_dialogs.dart';
import 'package:login_template/src/Utils/utils.dart' as utils;

class LoginController extends GetxController {

  bool showPassword = false;
  final _apiProvider = Get.find<API>();
  final globalController = Get.find<GlobalController>();

  final formKey = GlobalKey<FormState>();

  final TextEditingController emailController = new TextEditingController(/*text: '1000'*/);
  final TextEditingController passwordController = new TextEditingController(/*text: '9999'*/);
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
        AppDialogs.loadDialog('Semanal Territorial', 'Iniciando sesión');
        print("Login en curso...");
        final LocationData _location = await utils.getLocation();
        sharedPrefs.preferencesSaveLocation(
            _location.longitude, _location.latitude);
        Map<String, dynamic> data = {
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
          // 'imei': sharedPrefs.imei,
          'imei': await utils.getImei(),
          'latitude': _location.latitude.toString(),
          'longitude': _location.longitude.toString(),
        };
        try {
          Response _response =
              await _apiProvider.call("post", "login", data, null);
          print(_response.body["response"]);
          Get.back();
          if (_response.status.hasError ||_response.body["response"]["code"] == '1') {
            print("Error");
            AppDialogs.alertDialog(
              "Error al Iniciar Sesión",
              (_response.body["response"]["validation"].toString() == "[]")
                  ? _response.body["response"]["msg"].toString()
                  : _response.body["response"]["validation"]["email"]
                      .toString()
                      .replaceAll(RegExp(r"[^\s\w]"), ""),
            );
          } else if (_response.isOk) {
            print("Ok");
            sharedPrefs.preferencesSaveData(_response.body);
            if (await utils.checkVersion()) {
              await DBProvider.db.deleteOldRegisters();
              print(_response.body["data"]);
              isLoadingDB = true;
              final userModel = new UserModel.fromJson(_response.body["data"]["user"]);
              isLoadingDB = false;
              await DBProvider.db.nuevoUsuario(userModel);
              globalController.getEncuestasToMakeAnMap();
              globalController.login = true;
              Get.offAllNamed("/home");
            }
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
      } else {
        DBProvider.db.getAllRegisters().then((user) {
          if (user.isEmpty) {
            AppDialogs.alertDialog("¡Atención!",
                "Debes iniciar sesión en línea por lo menos una vez al día");
          } else {
            if (emailController.text != user[0]["email"]) {
              AppDialogs.alertDialog("Error al Iniciar Sesión",
                  "El correo ingresado no coincide con el último registro.\n\nSi quieres acceder con una cuenta distinta, inicia sesión en línea");
            } else {
              AppDialogs.loadDialog('Semanal Territorial', 'Iniciando sesión');
              Map adicionales = json.decode(user[0]['adicionales']);
              Map data = {
                'data': {
                  'access_token': user[0]['access_token'],
                  'user': {
                    'user_id': user[0]['user_id'],
                    'email': user[0]['email'],
                    'name': user[0]['name'],
                    'paterno': user[0]['paterno'],
                    'materno': user[0]['materno'],
                    'adicionales': adicionales,
                  }
                }
              };
              sharedPrefs.preferencesSaveData(data);
              globalController.getEncuestasToMakeAnMap();
              globalController.login = true;
              Get.offAllNamed("/home");
            }
          }
        });
      }
    }
  }
}
