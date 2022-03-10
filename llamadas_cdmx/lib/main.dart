import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:login_template/global_data/global_controller/global_controller.dart';
import 'package:login_template/global_data/providers/api_provider.dart';
import 'package:login_template/src/Utils/notification_utils.dart';
import 'package:login_template/src/routes/initial_bindings.dart';
import 'package:login_template/src/theme/theme.dart';
import 'src/routes/app_pages.dart';
import 'package:login_template/src/data/Preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await sharedPrefs.init();
  await DotEnv().load('.env');
  notificationsUtils.init();
  //CONTROLADORES GLOBALES
  Get.put(API(), permanent: true);
  Get.put(GlobalController());

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //INICIALIZA GLOBALCONTROLLER:
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: '${DotEnv().env["APP_NAME"]}',
      initialRoute: (sharedPrefs.token.isNotEmpty)?AppPages.HOME:AppPages.LOGIN,
      getPages: AppPages.routes,
      initialBinding: InitialBindings(),
      theme: companyThemeData,
    );
  }
}
