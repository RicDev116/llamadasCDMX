import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';

import 'package:login_template/global_data/global_controller/global_controller.dart';
import 'package:login_template/global_data/providers/api_provider.dart';
import 'package:login_template/models/encuesta_model.dart';
import 'package:login_template/src/data/Preferences.dart';
import 'package:login_template/src/widgets/app_dialogs.dart';
import 'package:login_template/src/Utils/utils.dart' as utils;
// import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class HomeController extends GetxController {

  //CONTROLADORES
  final apiProvider = Get.find<API>();
  final globalController = Get.find<GlobalController>();

  bool isLoading = false;
  Timer timer;
  LocationData _location;

  int registroId;
  String number = "";
  String tipoCaptura;
  String participara;

  Map statusId = {
    "No existe":2,
    'No contesta':3,
    'Rechazo':4,
    'Efectiva':5,
    'Abandono':6
  };

  Map statusLlamadas = {
    "total_llamadas":0,
    "efectivas":0,
    "no_existe":0,
    "no_contesta":0,
    "rechazo":0,
    "abandono":0,
  };

  @override
  void onInit() async {
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

  Future<void>solicitarNumero()async{
    this.isLoading = true;
    update(["phone-number"]);
    print("Solicitando número...");
    final Response _response = await apiProvider.call("get", "solicitar_numero",sharedPrefs.token, null);
    final jsonResponse = jsonDecode(_response.body);
    this.registroId = jsonResponse["registro_id"];
    this.number = jsonResponse["telefono"];
    this.isLoading = false;
    update(["phone-number"]);
  }

  void llamar()async{
    if(utils.isRecordingActive()){
      await FlutterPhoneDirectCaller.callNumber(this.number);
    }else{
      this._location = await utils.getLocation();
      utils.initStopWatch();
      utils.initRecording();
      this.timer = Timer.periodic(Duration(seconds: 1), (timer) {
        utils.getTime();
      });
      await FlutterPhoneDirectCaller.callNumber(this.number);
    }
  }

  void enviar()async{
    if(_location == null){
      return AppDialogs.alertDialog("Encuesta", "No haz hecho una llamada");
    }
    isLoading = true;
    update(["phone-number"]);
    print("enviando");
    final String _time = utils.getTime();
    final String _audioName = await utils.stopRecording();

    final EnucestaModel _encuesta =  EnucestaModel(
      apiToken: sharedPrefs.token, 
      registroId: registroId, 
      statusId: this.statusId[tipoCaptura],
      tiempo: _time,
      participara: participara == "Si participará" ?1:0, 
      latitud: _location.latitude.toString(), 
      longitud: _location.longitude.toString(), 
      audio: _audioName,
      respuesta1: participara,
    );
    try {
      final _resp = await apiProvider.postAudio(_encuesta).timeout(const Duration(seconds: 10));
      final jsonResponse = jsonDecode(_resp.body);
      if(_resp.statusCode == 200 && jsonResponse["message"] == "Registro insertado"){
        timer.cancel();
        print("Enviado");
        this._location = null;
        this.registroId = null;
        this.number = null;
        this.tipoCaptura = null;
        this.participara = null;
        await AppDialogs.alertDialog("Encuesta", "¡Encuesta subida con éxito!");
      }
    }on TimeoutException catch (e) {
      print(e);
      AppDialogs.alertDialog("Encuesta", "Verifica tú conexión a internet \n$e");
    }on Error catch (e){
       AppDialogs.alertDialog("Error", "$e");
      print(e);
    }
    isLoading = false;
    update(["phone-number"]);
  }

  void consultarCuotas()async{
    isLoading = true;
    update(["phone-number"]);
    try {
      final Response _resp = await apiProvider.call("get", "consultas", sharedPrefs.token, null);
      final _jsonResponse = jsonDecode(_resp.body);
      if(_resp.statusCode == 200 && _resp.bodyString.isNotEmpty){
        this.statusLlamadas["total_llamadas"] = _jsonResponse["total_llamadas"];
        this.statusLlamadas["efectivas"] = _jsonResponse["efectivas"];
        this.statusLlamadas["no_existe"] = _jsonResponse["no_existe"];
        this.statusLlamadas["no_contesta"] = _jsonResponse["no_contesta"];
        this.statusLlamadas["rechazo"] = _jsonResponse["rechazo"];
        this.statusLlamadas["abandono"] = _jsonResponse["abandono"];
      }
    }on TimeoutException catch (e) {
      print(e);
      AppDialogs.alertDialog("Encuesta", "Verifica tú conexión a internet \n$e");
    }on Error catch (e){
       AppDialogs.alertDialog("Error", "$e");
      print(e);
    }
    isLoading = false;
    update(["phone-number"]);
  }

  void changeValueDrop(String value,String id){
    if(id == "estado"){this.tipoCaptura = value;}
    if(id == "participara"){this.participara = value;}
    update(["phone-number"]);
  }

  void showAlert() async{
    await AppDialogs.welcomeDialog(
      "Bienvenido(a) ${sharedPrefs.username}",
      Text('Chi'),
      //TarjetaPresentacion(),
    );
  }

  // void getEncuestas(){
  //   final List<dynamic> encuestas =  json.decode(sharedPrefs.encuestas);
  //   for (var item in encuestas) {
  //     encuestas2.add(
  //       item,
  //     );
  //   }
  //   update(["botones"]);
  // }

  // void getId(int index){
  //   final int _id = encuestas2[index]["id"];
  //   Get.offAndToNamed("/encuesta",arguments: {"encuesta_id":_id});
  // }

  // Future updateBottons()async{
  //   registrosPendientes =  await globalController.getRegistrosPendientes();
  //   archivosPendientes =  await globalController.getArchivosPendientes();
  //   registradasHoy = await this.getRegistradasHoy();
  //   enviadasHoy = await this.getEnviadasHoy();
  //   update(['registrosPendientes','archivosPendientes','contadores']);
  // }

  // Future<void> subirRegistros()async{
  //   if(globalController.isuploadingRegisters == false){
  //     globalController.isuploadingRegisters = true;
  //     await globalController.subirEncuestasPendientes(false);
  //     globalController.isuploadingRegisters = false;
  //     updateBottons();
  //   }
  // }

  // Future<void> subirArchivos()async{
  //   if(globalController.isuploadingRegisters == false){
  //     globalController.isuploadingRegisters = true;
  //     await globalController.subirArchivosPendientes(false);
  //     globalController.isuploadingRegisters = false;
  //     updateBottons();
  //   }
  // }

  // Future<int>getRegistradasHoy() async{
  //   registradasHoy = 0;
  //   for (var i = 0; i < globalController.tablasEncuestas.length; i++) {
  //     await DBProvider.db.getEncuestasRegistradasHoy(globalController.tablasEncuestas[i],sharedPrefs.userId).then((count) {
  //       registradasHoy += count != null ? count.length : 0;
  //     });
  //    } 
  //   return registradasHoy;
  // }

  // Future<int>getEnviadasHoy() async{
  //   enviadasHoy = 0;
  //   for (var i = 0; i < globalController.tablasEncuestas.length; i++) {
  //     await DBProvider.db.getEncuestasEnviadasHoy(globalController.tablasEncuestas[i],sharedPrefs.userId).then((count) {
  //       enviadasHoy += count != null ? count.length : 0;
  //     });
  //   }
  //   return enviadasHoy;
  // }

  // Future<void> getEncuestasStatus()async{
  //   final List<Map<String, dynamic>> _mapEncuestasForStatus = await DBProvider.db.getEncuestasStatus(globalController.tablasEncuestas);
  //   for (var i = 0; i < globalController.tablasEncuestas.length; i++) {
  //     normal += _mapEncuestasForStatus[i]['normal'];
  //     abandono += _mapEncuestasForStatus[i]['abandono'];
  //     noAcepto += _mapEncuestasForStatus[i]['noAcepto'];
  //     sinContacto += _mapEncuestasForStatus[i]['sinContacto'];
  //   }
  //   print('Normales: $normal');
  //   print('Abandono: $abandono');
  //   print('No Aceptó: $noAcepto');
  //   print('Normales: $sinContacto');
  // }

}
