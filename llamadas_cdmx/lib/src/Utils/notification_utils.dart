import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

final notificationsUtils = NotificationsUtils();

class NotificationsUtils{

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  
  void init(){
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initSettings = InitializationSettings(android: android);
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: onSelectNotification);
  }

  Future<void> showNotification(Map<String,dynamic> notificationInfo) async {
    final android = AndroidNotificationDetails(
      notificationInfo['channel_id'],
      notificationInfo['channel_name'],
      notificationInfo['channel_description'],
      // 'TIMER', 
      // 'Envio de registros', 
      // 'Alerta mostrada en el envio automatico de archivos',
      priority: Priority.high, 
      importance: Importance.max
    );
    final platform = NotificationDetails(android: android);
    await flutterLocalNotificationsPlugin.show(
        notificationInfo['id'],
        notificationInfo['title'],
        notificationInfo['body'],
        platform,
        payload: 'itemx',
    );  
  }

  Future<dynamic> onSelectNotification(String payload)async{
    //WRITE SOME ABOUT SHITS TO DO WHEN PRESS THE NOTIFICATION
    Get.offNamed('/home');
  }
}