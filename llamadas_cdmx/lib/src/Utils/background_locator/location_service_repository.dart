import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoder/geocoder.dart';
// import 'package:get/get.dart';
import 'package:http/http.dart' as http;
// import 'package:login_template/global_data/global_controller/global_controller.dart';
// import 'package:login_template/global_data/providers/db_provider.dart';
import 'package:login_template/models/location_Inf_model.dart';
import 'package:login_template/src/Utils/utils.dart' as utils;
// import 'package:login_template/src/modules/login/controllers/login_controller.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:background_locator/location_dto.dart';
import 'file_manager.dart';
import 'package:path/path.dart';

class LocationServiceRepository {
  static LocationServiceRepository _instance = LocationServiceRepository._();
  // final _apiProvider = Get.find<API>();

  LocationServiceRepository._();

  factory LocationServiceRepository() {
    return _instance;
  }

  static const String isolateName = 'LocatorIsolate';

  int _count = -1;

  Future<void> init(Map<dynamic, dynamic> params) async {
    print("***********Init callback handler");
    if (params.containsKey('countInit')) {
      dynamic tmpCount = params['countInit'];
      if (tmpCount is double) {
        _count = tmpCount.toInt();
      } else if (tmpCount is String) {
        _count = int.parse(tmpCount);
      } else if (tmpCount is int) {
        _count = tmpCount;
      } else {
        _count = -2;
      }
    } else {
      _count = 0;
    }
    print("$_count");
    await setLogLabel("start");
    final SendPort send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> dispose() async {
    print("***********Dispose callback handler");
    print("$_count");
    await setLogLabel("end");
    final SendPort send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> callback(LocationDto locationDto) async {
    print('$_count location in dart: ${locationDto.toString()}');
    await setLogPosition(_count, locationDto);
    final SendPort send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(locationDto);
    _count++;
  }

  static Future<void> setLogLabel(String label) async {
    final date = DateTime.now();
    await FileManager.writeToLogFile(
        '------------\n$label: ${formatDateLog(date)}\n------------\n');
  }

  static Future<void> setLogPosition(int count, LocationDto data) async {

    await DotEnv().load('.env');
    bool isConnected = await utils.validateConnection();
    final documentsDirectory = await getApplicationDocumentsDirectory();
    String nameDB = DotEnv().env["APP_NAME"] + '.db';
    final String path = join(documentsDirectory.path, nameDB);
     //final GlobalController _loginController = Get.find<GlobalController>();
    if (isConnected) {
      String identifier = await UniqueIdentifier.serial;
      // String imei = await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
      // print(identifier);
      final coordinates = new Coordinates(data.latitude, data.longitude);
      final addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      final address = addresses.first.addressLine;
      LocationInf _info = new LocationInf(
        token: '${DotEnv().env["API_WEB_SERVICE"]}', 
        imei: identifier, 
        latitude: data.latitude.toString(), 
        longitude: data.longitude.toString(), 
        data: address, 
        project: '${DotEnv().env["APP_VERSION"]}',
        enviado: 0,
      );
      
      final uri = DotEnv().env["API_PROTOCOL"] == 'https'
        ? Uri.https('${DotEnv().env["API_HOST"]}', 'api/location/set')
        : Uri.http('${DotEnv().env["API_HOST"]}', 'api/location/set');
        final String _dataInf = locationInfToJson(_info);
      await http.post(uri, body: _dataInf);

      // if(await databaseExists(path) && DBProvider.db.isLoadingDB == false){
      //   final _gblCtrl = Get.find<GlobalController>();
      //   List<LocationInf> _locationsList = await  DBProvider.db.getLocationsPendientes();
      //   for (var i = 0; i < _locationsList.length; i++) {
      //     final int _idLocation = _locationsList[i].id;
      //     final String _locationPendiente = locationInfToJson(_locationsList[i]);
      //     print(_locationPendiente);
      //     try {
      //       final resp = await http.post(uri, body: _locationsList[i].toJson());
      //       print(resp.body);
      //       if(resp.statusCode == 200){
      //         DBProvider.db.updateLocation(_idLocation);
      //       }
      //     } on TimeoutException catch (e) {
      //       print(e);
      //     } on Error catch (e) {
      //       print(e);
      //     }
      //   }
      //   int locationEliminadas = await DBProvider.db.deleteLocationsEnviadas();
      //   print("Location elminadas $locationEliminadas");
      // }
    }
    // else{
    //   if(await databaseExists(path) && DBProvider.db.isLoadingDB == false){
    //     try{
    //       String identifier = await UniqueIdentifier.serial;
    //       LocationInf info = new LocationInf(
    //         token: '${DotEnv().env["API_WEB_SERVICE"]}', 
    //         imei: identifier, 
    //         latitude: data.latitude.toString(), 
    //         longitude: data.longitude.toString(), 
    //         data: null, 
    //         project: '${DotEnv().env["APP_VERSION"]}',
    //         enviado: 0,
    //       );
    //       await DBProvider.db.insertLocation(info);
    //     }catch(e){
    //       print(e); 
    //     }
    //   }
    // }
    final date = DateTime.now();
    await FileManager.writeToLogFile(
        '$count : ${formatDateLog(date)} --> ${formatLog(data)} --- isMocked: ${data.isMocked}\n');
  }

  static double dp(double val, int places) {
    double mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  static String formatDateLog(DateTime date) {
    return date.hour.toString() +
        ":" +
        date.minute.toString() +
        ":" +
        date.second.toString();
  }

  static String formatLog(LocationDto locationDto) {
    return dp(locationDto.latitude, 4).toString() +
        " " +
        dp(locationDto.longitude, 4).toString();
  }
}