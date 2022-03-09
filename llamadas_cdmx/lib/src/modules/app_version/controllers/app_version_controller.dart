import 'dart:convert';


import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:login_template/global_data/global_controller/global_controller.dart';
import 'package:login_template/global_data/providers/api_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;

class AppVersionController extends GetxController {

  final apiProvider = Get.find<API>();
  final globalController = Get.find<GlobalController>();

  String fileUrl;
  String fileName;

  // final String fileUrl = "http://api.territorial.cdmx.gob.mx/app/descargar/Prod";
  // final String fileName = "encuestas_territorial.apk";
  // final String fileUrl = "http://img-plus.com/wp-content/uploads/2016/02/7_TRS-GROUND.jpg";
  // final String fileName = "imagen.jpg";
  final Dio _dio = Dio();

  Map<String, dynamic> result;

  String progress = "-";
  bool finish = false;
  bool flag = true;
  String pathTest = '';

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  
  @override
  void onInit() async {
    super.onInit();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final initSettings = InitializationSettings(android: android, iOS: iOS);

    flutterLocalNotificationsPlugin.initialize(initSettings, onSelectNotification: _onSelectNotification);

    fileUrl = Get.arguments['link'];
    fileName = "encuesta_territorial_${Get.arguments['version']}.apk";
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }


  Future<void> _onSelectNotification(String json) async {

    final obj = jsonDecode(json);
    BuildContext context;

    if (obj['isSuccess']) {
      OpenFile.open(obj['filePath']);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('${obj['error']}'),
        ),
      );
    }
  }

  Future<void> _showNotification(Map<String, dynamic> downloadStatus) async {
    final android = AndroidNotificationDetails(
      'channel id',
      'channel name',
      'channel description',
      priority: Priority.high,
      importance: Importance.max
    );
    final iOS = IOSNotificationDetails();
    final platform = NotificationDetails(android: android, iOS: iOS);
    final json = jsonEncode(downloadStatus);
    final isSuccess = downloadStatus['isSuccess'];

    await flutterLocalNotificationsPlugin.show(
      0, // notification id
      isSuccess ? 'Descarga Completada' : 'Error',
      isSuccess ? '¡El archivo se ha descargado correctamente!' : 'Hubo un error al descargar el archivo.',
      platform,
      payload: json
    );
    if(isSuccess){
      finish = true;
    }
    flag = true;
    update(["finish","gif"]);
  }


  Future<bool> _requestPermissions() async {
    var statusStorage = await Permission.storage.request();

    if (statusStorage != PermissionStatus.granted) {
      statusStorage = await Permission.storage.request();
    }

    return statusStorage == PermissionStatus.granted;
  }

  void _onReceiveProgress(int received, int total) {
    if (total != -1) {
      progress = (received / total * 100).toStringAsFixed(0) + "%";
      update(["progress"]);
    }
  }

  Future<void> _startDownload(String savePath) async {
    result = {
      'isSuccess': false,
      'filePath': null,
      'error': null,
    };

    try {
      final response = await _dio.download(
        fileUrl,
        savePath,
        onReceiveProgress: _onReceiveProgress,
        deleteOnError: true,
        options: Options(
          // receiveTimeout: 500000,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.stream,
        )
      );
      result['isSuccess'] = response.statusCode == 200;
      result['filePath'] = savePath;
      pathTest = savePath;
    } catch (ex) {
      result['error'] = ex.toString();
      print(ex.toString());
    } finally {
      await _showNotification(result);
    }
  }

  Future<void> download() async {
    update(["finish","gif"]);
    final dir = await DownloadsPathProvider.downloadsDirectory;
    final isPermissionStatusGranted = await _requestPermissions();

    if (isPermissionStatusGranted) {
      final savePath = path.join(dir.path, fileName);
      print('Este es el path: $savePath');
      await _startDownload(savePath);
    } else {
      // handle the scenario when user declines the permissions
    }
  }

  void instalar(){
    OpenFile.open(pathTest);
  }
}
