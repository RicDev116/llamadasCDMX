import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:login_template/global_data/global_controller/global_controller.dart';

import 'package:login_template/src/Utils/utils.dart' as utils;
import 'package:login_template/src/modules/login/controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Container(
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.black38,
                  blurRadius: 25.0,
                  spreadRadius: 5.0,
                  offset: Offset(15.0, 15.0))
            ],
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.only(
          top: 60,
          left: 10,
          right: 10,
        ),
        padding: EdgeInsets.only(left: 30, right: 30),
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                ),
                // Container(
                //   child: Image.asset(
                //     'assets/logo_app_ex.png',
                //     height: 80,
                //   ),
                // ),
                // Container(
                //   child: Image.asset(
                //     'assets/icono.png',
                //     height: 150,
                //   ),
                // ),
                SizedBox(
                  height: 1,
                ),
                HeaderSection(),
                TextSection(),
                ButtonSection(login: controller.login),
                SizedBox(
                  height: 30,
                ),
                GetBuilder<GlobalController>(
                  id: ("Login"),
                  builder: (_) => Text(
                      (controller.globalController.connectionStatus ==
                              ConnectivityResult.none)
                          ? "MODO: Fuera de línea"
                          : "MODO: En línea",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              (controller.globalController.connectionStatus ==
                                      ConnectivityResult.none)
                                  ? Colors.red
                                  : Colors.green)),
                ),
                SizedBox(
                  height: utils.porcientoH(context, 20),
                ),

                // Container(
                //   decoration: BoxDecoration(
                //     color: Color.fromRGBO(6, 71, 54, 8),
                //     borderRadius: BorderRadius.circular(15),
                //   ),
                //   margin: EdgeInsets.only(top: 1.0),
                //   padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                //   height: utils.porcientoH(context, 31),
                //   child: Padding(
                //     padding: const EdgeInsets.all(18.0),
                //     child: Center(
                //       child: Column(
                //         children: <Widget>[
                //           Image.asset(
                //             'assets/actualizar.png',
                //             width: 80,
                //           ),
                //           Text(
                //             "ACTUALIZAR APLICACIÓN",
                //             style: TextStyle(
                //                 fontSize: 20.0,
                //                 color: Colors.white,
                //                 fontWeight: FontWeight.bold),
                //           ),
                //           IconButton(
                //             onPressed: (){},
                //             padding: EdgeInsets.symmetric(
                //                 vertical: 20, horizontal: 0),
                //             icon: Icon(
                //               Icons.cloud_download,
                //               color: Colors.white,
                //               size: 60,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                Text('Versión: ${DotEnv().env["APP_VERSION"]}',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(
                  height: utils.porcientoH(context, 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  final double fontSize;

  const HeaderSection({
    this.fontSize = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        // margin: EdgeInsets.only(top: 50.0),
        // padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        // child: Center(
        //     child: Text(DotEnv().env["APP_NAME"],
        //         style: TextStyle(
        //             color: Colors.lightGreenAccent[900],
        //             fontSize: this.fontSize,
        //             fontWeight: FontWeight.bold))),
        );
  }
}

class TextSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<LoginController>();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 20.0,
      ),
      child: Form(
        key: _controller.formKey,
        child: Column(
          children: <Widget>[
            MiTextFormField(
              controller: _controller.emailController,
              icon: Icons.email,
              hintText: 'Correo',
              // validator: (value)=>(!utils.validarEmail(value))
              // ?'El correo no es valido'
              // :null
            ),
            SizedBox(
              height: 25.0,
            ),
            GetBuilder<LoginController>(
              id: "password",
              builder: (_) => MiTextFormField(
                  changeValue: _.changeValueShowPassword,
                  passwordIcon: !(_.showPassword)
                      ? Icons.visibility
                      : Icons.visibility_off,
                  obscureText: _.showPassword,
                  controller: _controller.passwordController,
                  icon: Icons.lock,
                  hintText: 'Contraseña',
                  validator: (value) => (value.length < 4)
                      ? 'La contraseña debe ser de al menos 4 caracteres'
                      : null),
            ),
            SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}

class MiTextFormField extends StatelessWidget {
  const MiTextFormField({
    @required this.controller,
    this.msgError,
    this.icon = Icons.ac_unit,
    this.hintText = 'Correo',
    this.themeColor = const Color(0xffffffff),
    // this.themeColor = const Color(0xff9F2241),
    this.validator,
    this.obscureText = false,
    this.passwordIcon,
    this.changeValue,
  }) : assert(controller != null);

  final TextEditingController controller;
  final String msgError;
  final IconData icon;
  final String hintText;
  final Color themeColor;
  final Function(String) validator;
  final bool obscureText;
  final IconData passwordIcon;
  final Function changeValue;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        validator: this.validator,
        controller: this.controller,
        cursorColor: this.themeColor,
        obscureText: this.obscureText,
        style: TextStyle(color: Colors.white),
        // style: TextStyle(color: Colors.red[800]),
        decoration: InputDecoration(
            errorText: msgError,
            icon: Icon(this.icon, color: Colors.white),
            // icon: Icon(this.icon, color: Colors.red[800]),
            hintText: this.hintText,
            hintStyle: TextStyle(color: Colors.white),
            // hintStyle: TextStyle(color: Colors.red[800]),
            suffix: IconButton(
              onPressed: () => changeValue(),
              icon: Icon(
                this.passwordIcon,
                color: Colors.white,
                // color: Colors.red[800],
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              // borderSide: BorderSide(color: Colors.red[800]),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              // borderSide: BorderSide(color: Colors.red[800]),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),              
              // borderSide: BorderSide(color: Colors.red[800]),
            )) // )),
        );
  }
}

class ButtonSection extends StatelessWidget {
  const ButtonSection({
    this.textButton = "Ingresar",
    this.color = const Color(0xff9F2241),
    this.login,
  });

  final String textButton;
  final Color color;
  final Function login;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: utils.porcientoW(context, 80),
      height: utils.porcientoH(context, 5),
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: ElevatedButton(
        onPressed: () => this.login(context),
        child: Text("INGRESAR", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          primary: this.color,
        ),
      ),
    );
  }
}
