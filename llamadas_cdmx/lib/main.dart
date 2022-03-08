import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  //TODO  await sharedPrefs.init();
  await DotEnv().load('.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '${DotEnv().env["APP_NAME"]}',
      // initialRoute: AppPages.LOGIN,
      // getPages: AppPages.routes,
      // initialBinding: InitialBindings(),
      // theme: companyThemeData,
    );
  }
}