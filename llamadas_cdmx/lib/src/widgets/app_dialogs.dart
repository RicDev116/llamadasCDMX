import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:login_template/src/Utils/utils.dart' as utils;

class AppDialogs {

  static Future updateDialog(String _link){

    return showDialog(
      barrierDismissible: false,
      context: Get.context, 
      builder: (context){  
        return AlertDialog(
          title: Center(
            child: Text(
            "Actualización Disponible",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          )),
          
          backgroundColor: Colors.teal.shade900,
          content: Text("Por favor actualiza la app para continuar", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
          actions: [
            Container(
              padding: new EdgeInsets.all(10.0),
                decoration: new BoxDecoration(
                color: const Color(0xFF33b17c),
                ),
              child: TextButton(
                onPressed: ()async{
                  await launch(_link);
                }, 
                child: Center(
                  child: Text("Actualizar", textAlign: TextAlign.center,
                    style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontFamily: 'helvetica_neue_light',
                    ), 
                  )
                ),  
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                    Icons.cloud_download,
                    color: Colors.white,
                    size: 80.0,
                  ),
              ],
            ),
          ],
        );
      }
    );
  }

  static Future loadDialog(String title, String msg) {
    return showDialog(
        barrierDismissible: false,
        context: Get.context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: Colors.white,
            title: Center(
                child: Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            )),
            // backgroundColor: Colors.teal.shade900,
            children: [
              Column(
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 5,
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Colors.cyan.shade600),
                  ),
                  Text(
                    msg,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  static Future welcomeDialog(String msg, Widget contenido) {
    return showDialog(
      context: Get.context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green.shade100,
          content: contenido,
          contentPadding: EdgeInsets.zero,
          actions: [
            Text(
              "¡Bienvenido(a)!",
              style: TextStyle(
                color: Colors.teal.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),  
            SizedBox(width: utils.porcientoW(context, 10)),      
            TextButton(
              onPressed: () => Get.back(),
              style: ButtonStyle(
                backgroundColor:MaterialStateProperty.all(Colors.teal.shade900)),
                child: Text(
                  'Aceptar',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  )
                )
            ),
          ],
          actionsPadding:EdgeInsets.zero ,
        );
      }
    );
  }

  // static Future cuotasDialogHome(){
  //   return showDialog(
  //     context: Get.context, 
  //     builder: (BuildContext context){
  //       return GetBuilder<HomeController>(
  //         id: "dialogcuotas",
  //         builder:(_) => AlertDialog(
  //           title: Text('Selecciona una Encuesta'),
  //           content: Column(
  //              mainAxisSize: MainAxisSize.min,
  //              children: List.generate(
  //                _.encuestas2.length, (index) => Row(
  //                  children: [
  //                    Builder(
  //                      builder: (context){
  //                        if(_.encuestas2[index]["id"] != 31){
  //                          return Row(
  //                            children: [
  //                               Checkbox(
  //                                 value: _.itemDialogElegido == index ?true :false, 
  //                                 onChanged: (value){
  //                                   _.onchangeValueDialogEleccion(index);
  //                                 }
  //                               ),
  //                               Text(_.encuestas2[index]["encuesta"])
  //                            ],
  //                          );
  //                        }else{
  //                          return Row();
  //                        }
  //                      }
  //                    )
  //                  ],
  //                )
  //              )
  //            ),
  //           actions: [
  //             TextButton(
  //               style: ButtonStyle(backgroundColor:MaterialStateProperty.all(Colors.teal.shade900)),
  //               onPressed: () => Get.back(),
  //               child: Text('Cancelar', style: TextStyle(color: Colors.white)),
  //             ),
  //             TextButton(
  //               style: ButtonStyle(backgroundColor:MaterialStateProperty.all(Colors.teal.shade900)),
  //               onPressed: (){
  //                 Get.back();
  //                 Get.offAndToNamed(
  //                   "/cuotas",
  //                   arguments: {
  //                     "encuesta_id":_.encuestas2[_.itemDialogElegido]["id"],
  //                     "encuesta_name":_.encuestas2[_.itemDialogElegido]["encuesta"],
  //                   }
  //                 );
  //               },
  //               child: Text('Aceptar', style: TextStyle(color: Colors.white)),
  //             ),
  //           ],
  //         ),
  //       );
  //     }
  //   );
  // }

  static Future alertDialog(String title, String msg) {
    return showDialog(
        //barrierDismissible: false,
        context: Get.context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
                child: Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )),
            backgroundColor: Colors.white,
            content: Text(
              msg,
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Get.back(),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.teal.shade900)),
                  child: Text('Aceptar',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ))),
            ],
          );
        });
  }

  static Future cuotasDialog(Widget content){
    return showDialog(
      barrierDismissible: false,
      context: Get.context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))
          ),
          content: content
        );
      }
    );
  }

  static Future cuotasDangerDialog(String title, String msg) {
    return showDialog(
        //barrierDismissible: false,
        context: Get.context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
                child: Text(
              title,
              style: TextStyle(
                color: Colors.teal.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            )),
            backgroundColor: Colors.white,
            content: Text(
              msg,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Get.back(),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.teal.shade900)),
                  child: Text('Aceptar',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ))),
            ],
          );
        });
  }

}
