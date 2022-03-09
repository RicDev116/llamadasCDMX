import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:get/get.dart';
import 'package:login_template/global_data/providers/api_provider.dart';
import 'package:login_template/global_data/providers/db_provider.dart';
import 'package:login_template/models/audio_model.dart';
import 'package:login_template/src/Utils/notification_utils.dart';
import 'package:login_template/src/Utils/utils.dart' as utils;
import 'package:login_template/src/data/Preferences.dart';
import 'package:login_template/src/theme/theme_app.dart';
import 'package:login_template/src/widgets/app_dialogs.dart';
//import 'package:login_template/src/modules/login/controllers/login_controller.dart';

class GlobalController extends GetxController{

  final apiProvider = Get.put(API());

  //VARIABLES PARA SUBIDAS DE ARCHIVOS AUTOMATICA:
  bool login = false;
  bool isuploadingRegisters = false;
  bool isOnEncuestaView = false;

  //notificar de archivos enviados automaticamente:
  // int _totalEncuestasPorEnviar = 0,_ultimasEncuestasEnviadas = 0;
  // int _totalArchivosPorEnviar = 0,ultimosArchivosEnviados = 0;

  //VARIOS
  dynamic location;
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult connectionStatus = ConnectivityResult.none;

  //CONTADORES
  int registrosPendientes;
  int fotosPendientes,audiosPendientes,archivosPendientes;
  int registradasHoy, enviadasHoy, normal, abandono, noAcepto, sinContacto;

  List<String> tablasEncuestas = [];

  @override
  void onInit()async{
    initStreamConnection();
    await utils.permissionsWereAcepted();
    utils.getImei();
    await utils.stopGeolocation();
    await utils.initGeolocation();
    // this.timerToUploadEncuestas();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    closeStreamConnection();
    super.onClose();
  }

  void getEncuestasToMakeAnMap(){
    // tablasEncuestas.clear();
    final List<dynamic> _encuestas = jsonDecode(sharedPrefs.encuestas);
    for (var item in _encuestas) {
      tablasEncuestas.add(item['tabla']);
    }
  }

  void closeStreamConnection(){
    _connectivitySubscription.cancel();
  }

  // void timerToUploadEncuestas(){
  //   Timer.periodic( Duration(minutes: 15), (timer)async{ 
  //     if(login == true && connectionStatus!=ConnectivityResult.none && isuploadingRegisters == false){
  //       _ultimasEncuestasEnviadas = 0;
  //       ultimosArchivosEnviados = 0;
  //       // _totalEncuestasPorEnviar = await this.getRegistrosPendientes();
  //       _totalArchivosPorEnviar = await this.getArchivosPendientes();
  //       if(archivosPendientes > 0 || registrosPendientes > 0){
  //         await notificationsUtils.showNotification(
  //           {
  //             'channel_id':'TIMER',
  //             'channel_name':'Envio de registros',
  //             'channel_description':'Alerta mostrada en el envio automatico de archivos',
  //             'id':2,
  //             'tile':'Envío de encuestas pendientes',
  //             'body':'Encuestas pendientes enviadas de forma automática',
  //           }
  //         );
  //         isuploadingRegisters = true;
  //         HomeController homeController;
  //         if(isOnEncuestaView == false){
  //           homeController = Get.find<HomeController>();
  //           // await homeController.updateBottons();
  //         }
  //         if(registrosPendientes > 0 ){
  //           final bool _encuestasWereSend =  await this.subirEncuestasPendientes(true); 
  //           if(_encuestasWereSend ==  false){
  //             isuploadingRegisters = false;
  //             return;
  //           }
  //         }
  //         _totalArchivosPorEnviar = await this.getArchivosPendientes();
  //         if(archivosPendientes > 0 ){
  //           // final bool _archivosWereSend = await this.subirArchivosPendientes(true); 
  //           // if(_archivosWereSend ==  false){
  //           //   isuploadingRegisters = false;
  //           //   return;
  //           // }
  //         }
  //         isuploadingRegisters = false;
  //         if(isOnEncuestaView == false){
  //           // await homeController.updateBottons();
  //         }
  //         await notificationsUtils.showNotification(
  //           {
  //             'channel_id':'TIMER',
  //             'channel_name':'Envio de registros',
  //             'channel_description':'Alerta mostrada en el envio automatico de archivos',
  //             'id':2,
  //             'tile':'Encuestas enviadas',
  //             'body':'Enviadas $_ultimasEncuestasEnviadas encuestas de $_totalEncuestasPorEnviar ,' +
  //                    'Enviados $ultimosArchivosEnviados archivos de $_totalArchivosPorEnviar',
  //           }
  //         );
  //       }
  //     }
  //   });
  // }

  Future<int>getArchivosPendientes() async {
    archivosPendientes = 0;
    await DBProvider.db.getAudioPendientesEnvio().then((count) {
      audiosPendientes = count != null ? count.length : 0;
    });
    archivosPendientes = audiosPendientes;
    return archivosPendientes;
  }


  void initStreamConnection(){
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result){
      globalController.connectionStatus = result;
      print(result.toString());
      update(["Login","Home"]);
    });
  }

  Function selectEncuestaToJsonFunction(String key){
    Function _encuestaToJson;                                   
    return _encuestaToJson;
  }


  Future<bool> subirEncuestasPendientes(bool isFromTimer)async{
    bool _encuestasWereUploaded = false;

    if(globalController.connectionStatus == ConnectivityResult.none && isFromTimer == false){
      await AppDialogs.alertDialog("Encuestas", "Inténtelo de nuevo cuando tenga conexión a internet");
      _encuestasWereUploaded =  false;
    }else{
      final String _title = (isFromTimer)?'Subiendo encuestas de manera automática':'Encuestas';
      final String _subtitle = (isFromTimer)?'Por favor espere un momento...':'Subiendo encuestas...';
      if(isFromTimer == false){
        AppDialogs.loadDialog(_title, _subtitle);
      }
      // _encuestasWereUploaded = await subirEncuesta(isFromTimer);
    }
    return  _encuestasWereUploaded;
  }

} 