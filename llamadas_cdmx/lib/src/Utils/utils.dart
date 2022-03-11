import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart' as location;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:login_template/global_data/providers/api_provider.dart';
import 'package:login_template/src/theme/theme_app.dart';
import 'package:login_template/src/widgets/app_dialogs.dart';

import 'dart:isolate';
import 'dart:ui';
import 'package:uuid/uuid.dart' as uuid;

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/ios_settings.dart';
import 'package:background_locator/settings/locator_settings.dart';
// import 'package:location_permissions/location_permissions.dart';
import 'package:geocoder/geocoder.dart';
import 'background_locator/location_callback_handler.dart';
import 'background_locator/location_service_repository.dart';
import 'package:unique_identifier/unique_identifier.dart';

//DESARROLLADOS POR NOSOTROS :3
import 'package:login_template/src/data/Preferences.dart';
import 'package:permission_handler/permission_handler.dart';

///====================== =[Varios]=======================================
///====================FUNCIONES localizacion:============================
///=======================================================================


Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

//DA TAMAÑO A WIDTH PARA EVITAR DESBORDAMIENTO DE CONTENIDO
double porcientoW(BuildContext context, int valor) {
  final size = MediaQuery.of(context).size;
  return ((size.width / 100) * valor);
}

//DA TAMAÑO A HEIGTH PARA EVITAR DESBORDAMIENTO DE CONTENIDO
double porcientoH(BuildContext context, int valor) {
  final size = MediaQuery.of(context).size;
  return ((size.height / 100) * valor);
}

//retorna mapa de headers para peticiones api
Map<String, String> contenType() {
  final Map<String, String> _type = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    "Authorization": "Bearer ${sharedPrefs.token}"
  };
  return _type;
}

//VALIDA EMAIL ================================================
bool validarEmail(String email) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = new RegExp(pattern);
  return (regExp.hasMatch(email)) ? true : false;
}
//VALIDA QUE SE HAYA INTRODUCIDO TEXTO EN LAS PREGUNTAS:
String Function(String) validator = (value){
  if (value == null || value.isEmpty) {
    return 'El campo es obligatorio';
  }
  return null;
};

//CONCATENA NOMBRE:
String name(nombre, paterno, materno) {
  return nombre + ' ' + paterno + ' ' + materno;
}

//VERIFICA TOKEN USUARIO
Future<int> checkToken(Map response, bool isFromHome) async {
  print(response);
  if (response['response'] != null && response['response']['code'] == 9002 ||
      response['response'] != null && response['response']['code'] == 9004 ||
      response["response"] != null && response['response']['code'] == 9003) {
    Get.back();
    await AppDialogs.alertDialog("Sesión Expirada", "Vuelva a iniciar sesión");
    AppTheme.logoutOffline();
    return 0;
  } else {
    return 1;
  }
}

String getId() {
  var vUuid = uuid.Uuid().v4();
  return vUuid;
}

List<Widget> toRandomList(List<Widget> _list){
  _list.shuffle();
  return _list;
}

///====================== =[Connection]===================================
///====================FUNCIONES localizacion:============================
///=======================================================================

//StreamSubscription<ConnectivityResult> _connectivitySubscription;
ConnectivityResult connectionStatus = ConnectivityResult.none;

Future<bool> validateConnection() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    return false;
  } else {
    return true;
  }
}
///====================== =[Location]=====================================
///====================FUNCIONES localizacion:============================
///=======================================================================

//INSTANCIA DE Location
location.Location _location = new location.Location();

//Obtiene la localizacion
Future<location.LocationData> getLocation() async {
  final location = await _location.getLocation();
  print(location.longitude);
  print(location.latitude);
  print(sharedPrefs.imei);
  return location;
}

Future<void> initGeolocation() async {
  ReceivePort port = ReceivePort();

  if (IsolateNameServer.lookupPortByName(
          LocationServiceRepository.isolateName) !=
      null) {
    IsolateNameServer.removePortNameMapping(
        LocationServiceRepository.isolateName);
  }

  IsolateNameServer.registerPortWithName(
      port.sendPort, LocationServiceRepository.isolateName);

  port.listen(
    (dynamic data) async {
      print(data);
      await _updateNotificationText(data);
    },
  );

  print('Iniciando...');
  await BackgroundLocator.initialize();
  print('Iniciando listo');
  final bool isPermissionsOk = await permissionsWereAcepted();
  if (isPermissionsOk) {
    _startLocator();
    final _isRunning = await BackgroundLocator.isServiceRunning();
  } else {
    // show error
  }
}

// Future<bool> _checkLocationPermission() async {
//   final access = await LocationPermissions().checkPermissionStatus();
//   switch (access) {
//     case PermissionStatus.unknown:
//     case PermissionStatus.denied:
//     case PermissionStatus.restricted:
//       final permission = await LocationPermissions().requestPermissions(
//         permissionLevel: LocationPermissionLevel.locationAlways,
//       );
//       if (permission == PermissionStatus.granted) {
//         return true;
//       } else {
//         return false;
//       }
//       break;
//     case PermissionStatus.granted:
//       return true;
//       break;
//     default:
//       return false;
//       break;
//   }
// }

Future<void> _updateNotificationText(LocationDto data) async {
  if (data == null) {
    return;
  }

  bool isConnected = await validateConnection();
  String address;
  String msg;

  if (isConnected) {
    final coordinates = new Coordinates(data.latitude, data.longitude);
    final addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    msg = "Servicio Activado";
    address = addresses.first.addressLine;
  } else {
    msg = "Servicio Activado";
    address = 'Geolocalización';
  }

  await BackgroundLocator.updateNotificationText(
      title: "${DotEnv().env["APP_NAME"]}", msg: msg, bigMsg: address);
}

void _startLocator() {
  Map<String, dynamic> data = {'countInit': 1};
  BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
      initCallback: LocationCallbackHandler.initCallback,
      initDataCallback: data,
      disposeCallback: LocationCallbackHandler.disposeCallback,
      iosSettings:
          IOSSettings(accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 0),
      autoStop: false,
      androidSettings: AndroidSettings(
          accuracy: LocationAccuracy.NAVIGATION,
          interval: 60,
          distanceFilter: 0,
          client: LocationClient.google,
          androidNotificationSettings: AndroidNotificationSettings(
              notificationChannelName: 'Seguimiento de ubicación',
              notificationTitle: 'Iniciar seguimiento de ubicación',
              notificationMsg: 'Seguimiento de la ubicación en segundo plano',
              notificationBigMsg:
                  'La ubicación en segundo plano está activada para mantener la aplicación actualizada con su ubicación. Esto es necesario para que las funciones principales funcionen correctamente cuando la aplicación no se está ejecutando.',
              notificationIconColor: Colors.grey,
              notificationTapCallback:
                  LocationCallbackHandler.notificationCallback)));
}

Future<void> stopGeolocation() async {
  BackgroundLocator.unRegisterLocationUpdate();
  await BackgroundLocator.isServiceRunning();
}

///============================[Imei]=====================================
///====================FUNCIONES IMEI:====================================
///=======================================================================

Future<String> getImei() async {
  // String _imei = await ImeiPlugin.getImei();
  String _identifier = await UniqueIdentifier.serial;
  sharedPrefs.setData("String", "imei", _identifier);
  return _identifier;
}

///========================[StopWatch]=====================================
///====================FUNCIONES CRONOMETRO:===============================
///========================================================================
Stopwatch _stopwatch = Stopwatch();

//========================================================================
//COVIERTE MILISEGUNDOS A STRING CON HORAS, MINUTOS YY SEGUNDOS===========
String formatTime(int milliseconds) {
  var secs = milliseconds ~/ 1000;
  var hours = (secs ~/ 3600).toString().padLeft(2, '0');
  var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
  var seconds = (secs % 60).toString().padLeft(2, '0');
  return "$hours:$minutes:$seconds";
}

//INICIA CRONOMETRO
initStopWatch() {
  _stopwatch.start();
}

//ELIMINA CRONOMETRO
//ELIMINA CRONOMETRO
deleteStopWatch() {
  _stopwatch.stop();
  _stopwatch.reset();
}

//OBTIENE TIEMPO DEL CRONOMETRO:
String getTime() {
  final int _miliseconds = _stopwatch.elapsed.inMilliseconds;
  final String _time = formatTime(_miliseconds);;
  return _time;
}

///=======================[ImagePicker]====================================
///====================FUNCIONES IMAGENES==================================
///========================================================================
ImagePicker picker = ImagePicker();
PickedFile _pickedImage;

Future<dynamic> pickImage(String method) async {
  ImageSource source;
  File _foto;

  (method == "camera")
      ? source = ImageSource.camera
      : source = ImageSource.gallery;

  _pickedImage = await picker.getImage(source: source, imageQuality: 50);
  if (_pickedImage != null) {
    _foto = File(_pickedImage.path);
    return _foto;
  } else {
    _foto = null;
    return _foto;
  }
}

///============================[Permission]=================================
///====================funcion para obtener permisos de la app==============
///=========================================================================
Future<bool> permissionsWereAcepted() async {

  final List<bool> permissions = [];

  permissions.add(await requestPermissionIsDeniedOrPermanentlyDenied(Permission.location));
  permissions.add(await requestPermissionIsDeniedOrPermanentlyDenied(Permission.camera));
  permissions.add(await requestPermissionIsDeniedOrPermanentlyDenied(Permission.storage));
  permissions.add(await requestPermissionIsDeniedOrPermanentlyDenied(Permission.microphone));
  permissions.add(await requestPermissionIsDeniedOrPermanentlyDenied(Permission.locationAlways));

  final List<String> permanentlyDeniedPermissionsName = nameOfPermissionsDenied(permissions);
  if(permanentlyDeniedPermissionsName.isNotEmpty){
    await AppDialogs.alertDialog(
      "Permisos", 
      "Por favor concede los siguentes permisos y inicia sesión\n\n"+
      "\""+permanentlyDeniedPermissionsName.join(",\n")+"\"",
    );
    await openAppSettings();
    return false;
  }
  return true;
}
///["Devuelve el nombre de los permisos denegados"]
List<String> nameOfPermissionsDenied(List<bool>listPermissions){
  final List<String> _listNameOfPermissionDenied = [];
  for (var i = 0; i < listPermissions.length; i++) {
    if(listPermissions[i] == true){
      if(i == 0){_listNameOfPermissionDenied.add("Localización");}
      if(i == 1){_listNameOfPermissionDenied.add("Cámara");}
      if(i == 2){_listNameOfPermissionDenied.add("Almacenamiento");}
      if(i == 3){_listNameOfPermissionDenied.add("Micrófono");}
      if(i == 4){_listNameOfPermissionDenied.add("Localización background");}
    }
  }
  return _listNameOfPermissionDenied;
}
///["Revisa si "]
Future<bool> requestPermissionIsDeniedOrPermanentlyDenied(Permission permission)async{
  final PermissionStatus permissionStatus = await permission.request();
  if (permissionStatus != PermissionStatus.granted){
    if(permissionStatus == PermissionStatus.permanentlyDenied){
      return true;
    }else{
      return true;
    }
  }
  return false;
}

Future<bool> requestPermissionLocationIsOk()async{
  var statusLocation = await Permission.location.request();
  if (statusLocation != PermissionStatus.granted){
    if(statusLocation == PermissionStatus.permanentlyDenied){
      await AppDialogs.alertDialog("Permisos", "Habilita permisos a la app");
      await openAppSettings();
      return false;
    }
  } 
  return true;
}

///=====================[FlutterSoundRecorder]=============================
///====================funcion para obtener audio de la app ===============
///========================================================================

//INSTANCIA FLUTTER SPUND RECORDER
FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
//variable donde se guarda la grabacion
String _mPath = "path_for_seguimiento.mp3";

//Inicia grabacion:
void initRecording() async {
  final String id = DateTime.now().microsecondsSinceEpoch.toString();
  String _mPath = id + "-path_for_seguimiento.mp3";
  var status = await Permission.microphone.request();
  if (status != PermissionStatus.granted) {
    throw RecordingPermissionException('Microphone permission not granted');
  }
  await _mRecorder.openAudioSession();
  _mRecorder.startRecorder(
    toFile: _mPath,
    codec: Codec.aacADTS,
  );
}

//verifica si la grabacion esta activa:
bool isRecordingActive() {
  return _mRecorder.isRecording;
}

//DETIENE GRABACIÓN:
Future<String> stopRecording() async {
  final _path = await _mRecorder.stopRecorder();
  return _path;
}

///===========================[UpgradeApp]=================================
///========funcion para revisar si existe una actualización ===============
///========================================================================

Future <bool> checkVersion() async{

  bool _isConnected = await validateConnection();

  if(_isConnected){
      final _apiProvider = Get.find<API>();
      Response _response = await _apiProvider.call("post", "version",{}, contenType());

      int _status = await checkToken(_response.body, true);
      if (_status == 0) {
        print("Token caducado");
        return false;
      }else{

        Map _versions = _response.body['data']['versions'];

        if ('${DotEnv().env["APP_VERSION_ENV"]}' == 'Prod') {
          _versions = _versions['production'];
        } else {
          _versions = _versions['developer'];
        }

        String version = _versions['version'];
        if (version != '${DotEnv().env["APP_VERSION"]}') {
          Get.offAllNamed("/app/version", arguments: _versions);
          return false;
        } else {
          return true;
        }
      }
    }else{
      return true;
    }
}
