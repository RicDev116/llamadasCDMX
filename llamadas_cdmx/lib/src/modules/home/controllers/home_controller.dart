import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';

import 'package:login_template/global_data/global_controller/global_controller.dart';
import 'package:login_template/global_data/providers/api_provider.dart';
import 'package:login_template/src/data/Preferences.dart';
import 'package:login_template/src/widgets/app_dialogs.dart';
import 'package:login_template/src/Utils/utils.dart' as utils;
// import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class HomeController extends GetxController {

  //CONTROLADORES
  final apiProvider = Get.find<API>();
  final globalController = Get.find<GlobalController>();

  bool isLoading = false;
  String number = "";
  String tipoCaptura;
  String participara;

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
    await Future.delayed(Duration(seconds: 10));
    print("número obtenido...");
    this.number = '5510152002';
    this.isLoading = false;
    update(["phone-number"]);
  }

  void llamar()async{
    utils.initStopWatch();
    utils.initRecording();
    await FlutterPhoneDirectCaller.callNumber(this.number);
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
