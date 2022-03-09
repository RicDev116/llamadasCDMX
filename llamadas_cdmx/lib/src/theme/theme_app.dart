import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:login_template/global_data/global_controller/global_controller.dart';
import 'package:login_template/src/data/Preferences.dart';
import 'package:login_template/src/Utils/utils.dart' as utils;

final globalController = Get.find<GlobalController>();

class AppTheme {
  static final themeData = ThemeData(
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xff2b2b2b),
      titleTextStyle: TextStyle(color: Colors.white),
    ),
  );

  static Widget drawer(BuildContext context,Function call) {
    return Drawer(
      child: new ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
              currentAccountPicture: Image.asset(
                  'assets/icono.png',
                  fit: BoxFit.contain,
                  matchTextDirection: true,
                  height: 50,
              ),
              accountName: new Text("${sharedPrefs.username}",
                  style: TextStyle(color: Colors.white)),
              accountEmail: new Text('${sharedPrefs.email}',
                  style: TextStyle(color: Colors.white)),
              decoration: BoxDecoration(
                  image: DecorationImage(
                  image: AssetImage('assets/bg2.jpg'),
                  fit: BoxFit.cover,
              ),
              )
          ),
          new Divider(),
          new ListTile(
            title: new Text("Inicio"),
            trailing: new Icon(Icons.home, color: Colors.greenAccent.shade400,),
            onTap: () => Get.offNamed('/home'),
          ),
          // new Divider(),
          // new ListTile(
          //   title: new Text("Encuestas"),
          //   trailing: new Icon(Icons.list, color: Colors.greenAccent.shade400,),
          //   onTap: () => Get.offNamed('/home'),
          // ),
          // new Divider(),
          // new ListTile(
          //   title: new Text("Enviar encuestas"),
          //   trailing: new Icon(Icons.library_books, color: Colors.greenAccent.shade400,),
          //   onTap: () => Get.offNamed('/home'),
          // ),
          // new Divider(),
          
          // new ListTile(
          //   title: new Text("Enviar archivos"),
          //   trailing: new Icon(Icons.collections, color: Colors.greenAccent.shade400,),
          //   onTap: () => Get.offNamed('/home'),
          // ),
          new Divider(),
          new ListTile(
            title: new Text("Salir"),
            trailing: new Icon(Icons.exit_to_app, color: Colors.greenAccent.shade400,),
            onTap: () => (globalController.connectionStatus != ConnectivityResult.none)
              ? AppTheme.logoutOnline(call)
              : AppTheme.logoutOffline()
          ),
        ],
      ),
    );
  }

  static AppBar appBar(
      String name, Function call, bool showInModule) {
    return AppBar(
      title: Text(name, style: TextStyle(color: Colors.white)),
      iconTheme: IconThemeData(color: Colors.white),
      actions: showInModule
          ? [
              TextButton(
                onPressed: () => Get.offAllNamed("/home"),
                child: Text("Salir", style: TextStyle(color: Colors.white)),
              ),
            ]
          : null,
    );
  }

  static void logoutOnline(Function call) async {
    print('logout online');
    try {
      final Response _response = await call(
        'post',
        'logout',
        null,
        utils.contenType(),
      );

      var status = await utils.checkToken(_response.body,false);
      if (status == 0) {
        print("Token caducado");
      }else{
        sharedPrefs.clean();
        globalController.login = false;
        Get.offAllNamed("/login");
      }
    } on TimeoutException catch (e) {
      print('Timeout: $e');
      sharedPrefs.clean();
      globalController.login = false;
      Get.offAllNamed("/login");
    } on Error catch (e) {
      print('Error: $e');
      sharedPrefs.clean();
      globalController.login = false;
      Get.offAllNamed("/login");
    }
  }

  static void logoutOffline() {
    print('logout offline');
    sharedPrefs.clean();
    globalController.login = false;
    Get.offAllNamed("/login");
  }
}

class AppColors {
  static Color colorPrincipal = Color(0xff303030);
}
