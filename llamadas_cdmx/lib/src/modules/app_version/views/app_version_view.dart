import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login_template/src/modules/app_version/controllers/app_version_controller.dart';
import 'package:login_template/src/Utils/utils.dart' as utils;
import 'package:flutter_svg/flutter_svg.dart';

import 'package:login_template/src/theme/theme_app.dart';
import 'package:url_launcher/url_launcher.dart';


class AppVersionView extends GetView<AppVersionController> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppTheme.appBar(
          "Descargar Nueva Versión", controller.apiProvider.call, false),
      drawer: Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
                currentAccountPicture: Image.asset(
                  'assets/icon.png',
                  fit: BoxFit.contain,
                  matchTextDirection: true,
                  height: 50,
                ),
                accountName: new Text("Encuesta Territorial",
                    style: TextStyle(color: Colors.white)),
                accountEmail: new Text('Descargar Versión',
                    style: TextStyle(color: Colors.white)),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bg2.jpg'),
                    fit: BoxFit.cover,
                  ),
                )),
            new Divider(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SvgPicture.asset(
                  'assets/black.svg',
                  fit: BoxFit.cover,
                ),
                GetBuilder<AppVersionController>(
                    id: "progress",
                    builder: (_) {
                      return Positioned(
                        top: utils.porcientoH(context, 25),
                        left: utils.porcientoW(context, 39),
                        child: Text(
                          '${controller.progress}',
                          style: TextStyle(
                              fontSize: 40.0, color: Colors.green[900]),
                        ),
                      );
                    }),
                Positioned(
                  top: utils.porcientoH(context, 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          width: utils.porcientoW(context, 50),
                          child: Column(children: [
                            TextButton(
                                child: Image.asset('assets/actualizar.png'),
                                onPressed: () async {
                                  controller.finish = false;
                                  controller.progress = "-";
                                  if (controller.flag) {
                                    controller.flag = false;
                                    controller.download();
                                  }
                                }),
                          ])),
                      Container(
                          width: utils.porcientoW(context, 50),
                          child: Column(children: [
                            TextButton(
                              child: Image.asset('assets/descarga.png'),
                              onPressed: () async {
                                await launch(controller.fileUrl);
                              },
                            ),
                          ])),
                    ],
                  ),
                ),
                Positioned(
                  top: utils.porcientoH(context, 42),
                  left: utils.porcientoW(context, 40),
                  child: GetBuilder<AppVersionController>(
                      id: "finish",
                      builder: (_) {
                        if (_.finish) {
                          return TextButton(
                            onPressed: () {
                              controller.instalar();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFb2062f),
                                border: Border.all(
                                  color: Color(0xFFb2062f),
                                  width: 10,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Instalar',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        } else {
                          return SizedBox();
                        }
                      }),
                ),
                Positioned(
                  top: utils.porcientoH(context, 62),
                  left: utils.porcientoW(context, 24),
                  child: Row(
                    children: [
                      GetBuilder<AppVersionController>(
                          id: "gif",
                          builder: (_) {
                            if (!_.flag) {
                              return Image(
                                  image: new AssetImage("assets/upgrade.gif"),
                                  width: 150);
                            } else {
                              return Image(
                                  image: new AssetImage(
                                      "assets/download_finish.gif"),
                                  width: 180);
                            }
                          })
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}