import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login_template/src/data/Preferences.dart';
import 'package:login_template/src/modules/home/controllers/home_controller.dart';
import 'package:login_template/src/theme/theme_app.dart';
import 'package:login_template/src/Utils/utils.dart' as utils;

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppTheme.appBar( "${sharedPrefs.username}", controller.apiProvider.call, false),
      drawer: AppTheme.drawer(context, controller.apiProvider.call),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // SizedBox(height: utils.porcientoH(context, 40)),
          GetBuilder<HomeController>(
            id:"phone-number",
            builder: (_) => controller.isLoading
            ? Center(
              child: CircularProgressIndicator()
            )
            : Column(
              children: [
                Text(controller.number??"",style: TextStyle(fontSize: 20),),
                (controller.number == null || controller.number.isEmpty)
                ?Center(
                  child: TextButton(
                    onPressed: () => _.solicitarNumero(), 
                    child: Container(
                      child: Text("Solicitar número"),
                    ),
                  ),
                )
                :Column(
                  children: [
                    Card(
                      margin: EdgeInsets.all(20),
                      // width: utils.porcientoW(context, 80),
                      // color: Colors.red,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '¡Hola que tal! Le llamo de la asociación Que Siga la Democracia,'+
                          '\n¿Sabías que la pensión de adulto mayor la da el presidente de la República?'+
                          '\n¿Qué en el 2024 llegará a seis mil pesos bimestrales?'+
                          '\n¿Sabías que el 10 de abril se va a realizar una ratificación del presidente Andrés Manuel López Obrador?'+
                          '\nSi no quieres que llegue otro gobierno y nos quite los apoyos y lo conquistado, entonces…',
                          style: TextStyle(fontSize: 15),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                    Text("¡Sal a votar este próximo 10 de abril! '",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 20)),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text("Estado de la llamada",style: TextStyle(color: Colors.black),textAlign: TextAlign.start),
                            Container(
                              width: utils.porcientoW(context, 70),
                              child: DropdownButton<String>(
                                value: controller.tipoCaptura,
                                elevation: 8,
                                itemHeight: 60,
                                icon: Icon(Icons.arrow_drop_down_circle),
                                iconDisabledColor: Colors.red,
                                iconEnabledColor: Colors.green,
                                isExpanded: true,
                                hint: Text(
                                  "Selecciona (*)",
                                  style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500),
                                ),
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                items:
                                <String>[
                                  'No existe',
                                  'No contesta',
                                  'Rechazo',
                                  'Efectiva',
                                  'Abandono',
                                ].map((String value) {
                                  return new DropdownMenuItem<String>(
                                    value: value,
                                    child: new Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  _.changeValueDrop(value,"estado");
                                  print(_.tipoCaptura);
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
                    Builder(
                      builder: (_){
                        if(controller.tipoCaptura == 'Efectiva'){
                          return Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(left: 20),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text("¿Participará?",style: TextStyle(color: Colors.black),textAlign: TextAlign.start),
                                  Container(
                                    width: utils.porcientoW(context, 70),
                                    child: DropdownButton<String>(
                                      value: controller.participara,
                                      elevation: 8,
                                      itemHeight: 60,
                                      icon: Icon(Icons.arrow_drop_down_circle),
                                      iconDisabledColor: Colors.red,
                                      iconEnabledColor: Colors.green,
                                      isExpanded: true,
                                      hint: Text(
                                        "Selecciona (*)",
                                        style: TextStyle(
                                          color: Colors.black38,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                      ),
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      items:
                                      <String>[
                                        'Si participará',
                                        'No participará',
                                      ].map((String value) {
                                        return new DropdownMenuItem<String>(
                                          value: value,
                                          child: new Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        controller.changeValueDrop(value,"participara");
                                        print(controller.tipoCaptura);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          );
                        }else{
                          controller.participara = null;
                          return SizedBox();
                        }
                      }
                    ),
                    TextButton(
                      onPressed: () => _.llamar(), 
                      child: Container(
                        child: Text("Llamar",style: TextStyle(color: Colors.blue),),
                      ),
                    ),
                    Builder(
                      builder: (context){
                        if((controller.tipoCaptura != null && controller.tipoCaptura != "Efectiva") || (controller.tipoCaptura != null && controller.tipoCaptura == "Efectiva" && controller.participara!= null) ){
                          return TextButton(
                            onPressed: () => _.enviar(), 
                            child: Container(
                              child: Text("Enviar",style: TextStyle(color: Colors.green),),
                            ),
                          );
                        }else{
                          return SizedBox();
                        }
                      }
                    ),
                  ],
                )
              ],
            )
          ),
        ],
      ),
    );
  }
}
