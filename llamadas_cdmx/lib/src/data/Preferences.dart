
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_template/src/Utils/utils.dart'as utils;

final sharedPrefs = SharedPrefs();

const String _token     = "token";
const String _userId    = "userId";
const String _user      = "username";
const String _email     = "email";
final String _encuestas = "encuestas";
final String _alcaldia  = "alcaldia";

const String _imei      = "imei";
const String _longitude = "longitude";
const String _latitude  = "latitude";

class SharedPrefs {
  static SharedPreferences _sharedPrefs;

  //USUARIO
  String get token => _sharedPrefs.getString(_token) ?? "";
  int    get userId => _sharedPrefs.getInt(_userId) ?? 0;
  String get username => _sharedPrefs.getString(_user) ?? "";
  String get email => _sharedPrefs.getString(_email) ?? "";
  String get encuestas => _sharedPrefs.getString(_encuestas)?? "";
  String get alcaldia => _sharedPrefs.getString(_alcaldia) ?? "";
  //UBICACIÓN E INFORMACION
  String get imei => _sharedPrefs.getString(_imei) ?? "";
  double get longitude => _sharedPrefs.getDouble(_longitude) ?? 0;
  double get latitude => _sharedPrefs.getDouble(_latitude) ?? 0;

  init() async {
    if (_sharedPrefs == null) {
      _sharedPrefs = await SharedPreferences.getInstance();
    }
  }

  void setData(String type, String key, value) {
    switch (type) {
      case 'String':
        _sharedPrefs.setString(key, value);
        break;
      case 'Int':
        _sharedPrefs.setInt(key, value);
        break;
      case 'Double':
        _sharedPrefs.setDouble(key, value);
        break;
      case 'Bool':
        _sharedPrefs.setBool(key, value);
        break;
      case 'StringList':
        _sharedPrefs.setStringList(key, value);
        break;
    }
  }

  void saveData(String user,String apiToken){
    this.setData('String','email',user);
    this.setData('String', 'token', apiToken);
  }

  void preferencesSaveData(dynamic response){
    //var jsonResponse = json.decode(response.body);
    //return response.body;

    var user = response['data']['user'];
    var name = utils.name(
      user['name'] ?? "", user['paterno'] ?? "", user['materno'] ?? ""
    );
    print(name);
    this.setData('String', 'token',    response['data']['access_token']);
    this.setData('Int',    'userId',   user['user_id']);
    this.setData('String', 'username', name);
    this.setData('String', 'email',    user['email']);
    this.setData('String', 'encuestas', json.encode(user['adicionales']['encuestas']));
    this.setData('String', 'alcaldia', json.encode(user['adicionales']['alcaldias_asignadas']));
  }

  void preferencesSaveVersion(dynamic response){
    
  }

  bool preferencesSaveLocation(double longitude, double latitude){
    if(longitude == this.longitude && latitude == this.latitude){
      return true;
    }else{
      this.setData("Double", "longitude", longitude);
      this.setData("Double", "latitude", latitude);
      return false;
    }
  }

  void clean() {
    _sharedPrefs.clear();
  }

}
