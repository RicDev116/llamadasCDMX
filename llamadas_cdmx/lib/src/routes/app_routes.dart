
part of 'app_pages.dart';
//NO MODIFICAR ARCHIVO D4E RUTAS STATICAS
abstract class Routes {
  Routes._();

  static const LOGIN = _Paths.LOGIN;
  static const HOME = _Paths.HOME;
  static const ENCUESTA = _Paths.ENCUESTA;
  static const CUOTAS = _Paths.CUOTAS;
  static const APPVERSION = _Paths.APPVERSION;

}

abstract class _Paths {

  static const LOGIN = '/login';
  static const HOME = '/home';
  static const ENCUESTA = '/encuesta';
  static const CUOTAS = '/cuotas';
  static const APPVERSION = '/app/version';
}
