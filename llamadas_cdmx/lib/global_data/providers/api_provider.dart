import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:login_template/global_data/providers/db_provider.dart';
import 'package:login_template/models/audio_model.dart';
import 'package:login_template/src/Utils/utils.dart' as utils;
import 'package:http/http.dart'as http;

class API extends GetConnect {

  @override
  void onInit() {
    print("api iniciada!");
    String protocol = DotEnv().env["API_PROTOCOL"];
    httpClient.baseUrl = (protocol == 'http' ? "http://" : "https://") + DotEnv().env["API_HOST"];
    print(httpClient.baseUrl);
    super.onInit();
  }


  Map get routes => {
        'version': '/api/version/actual',
        'login': '/api/auth/login',
        'logout': '/api/auth/logout',
        // 'catalogos': '/api/catalogos',
        'encuestas' :'/api/encuestas/guardar',
        'encuestas.validacion':'/api/encuestas/validacion',
        'audios':'/api/archivos/audios',
        // 'fotos': '/api/archivos/fotos',
        'ubicame':'/api/location/ubicame',
        // 'cuotas' : '/api/encuestas/cuotas',
        // 'cuotas.detalle' : '/api/encuestas/cuotas/detalles',
        // 'cuotas.detalle.seccion' : '/api/encuestas/cuotas/detallesbyseccion',
      };

  Future<Response> call(String method, String endPoint, body, headers) async {

    Response _response;
    String _url;
    
    if(endPoint == 'cuotas'){
      _url = this.routes[endPoint] + "/${body["id_encuesta"]}";
    }else if(endPoint == 'cuotas.detalle'){
      _url = this.routes[endPoint] + "/${body["id_encuesta"]}/${body["id_agrupador"]}";
    }else if(endPoint == 'cuotas.detalle.seccion'){
      _url = this.routes[endPoint] + "/${body["id_encuesta"]}/${body["seccion"]}";
    }else{
      _url = this.routes[endPoint];
    }
    
    switch (method) {
      case 'post':
        print(this.routes[endPoint]);
        _response = await post(_url, body, headers: headers)
            .timeout(const Duration(seconds: 10));
        break;
      case 'get':
        _response = await get(_url, headers: headers)
            .timeout(const Duration(seconds: 10));
        break;
    }
    return _response;
  }
  // Future<http.Response> call(String method, String endPoint, body, headers) async {
  //   var _uri = Uri.parse(httpClient.baseUrl+this.routes[endPoint]);
  //   http.Response _response;
  //   switch (method) {
  //     case 'post':
  //       print(this.routes[endPoint]);
  //       _response = await http.post(_uri,headers: headers,body: body,)
  //           .timeout(const Duration(seconds: 10));
  //       break;
  //     case 'get':
  //       _response = await http.get(this.routes[endPoint], headers: headers)
  //           .timeout(const Duration(seconds: 10));
  //       break;
  //   }
  //   return _response;

  Future<http.Response> postAudio(AudioModel audio)async{

    var uri = Uri.parse(httpClient.baseUrl+"/api/archivos/audios");

    final _request = http.MultipartRequest("POST",uri);
    _request.fields["uuid"] = audio.uuid;
    _request.fields["user_id"] = audio.userId.toString();
    _request.files.add(await http.MultipartFile.fromPath("audio", audio.audioName));
    _request.fields["latitude"] = audio.latitude;
    _request.fields["longitude"] = audio.longitude;
    _request.fields["imei"] = audio.imei;
    _request.fields["created_at"] = audio.capturedAt.toString();
    _request.fields["encuesta_id"] = audio.encuestaId.toString();
    _request.fields["registro_id"] = audio.registroId.toString();
    _request.headers.addAll(utils.contenType());
    print(_request.fields);
    print(_request.files);
    final _streamResponse = await _request.send();
    final _resp = await http.Response.fromStream(_streamResponse).timeout(const Duration(seconds: 10));

    return _resp;
  }

  // Future<http.Response> postPhoto(PhotoModel photo)async{

  //   var uri = Uri.parse(httpClient.baseUrl+"/api/archivos/fotos");

  //   final _request = http.MultipartRequest("POST",uri);
  //   _request.fields["uuid"] = photo.uuid.toString();
  //   _request.fields["user_id"] = photo.userId.toString();
  //   _request.files.add(await http.MultipartFile.fromPath("photo", photo.photoName));
  //   _request.fields["latitude"] = photo.latitude;
  //   _request.fields["longitude"] = photo.longitude;
  //   _request.fields["imei"] = photo.imei;
  //   _request.fields["created_at"] = photo.capturedAt.toString();
  //   _request.fields["encuesta_id"] = photo.encuestaId.toString();
  //   _request.fields["registro_id"] = photo.registroId.toString();
  //   _request.headers.addAll(utils.contenType());
  //   final _streamResponse = await _request.send();
  //   return await http.Response.fromStream(_streamResponse).timeout(const Duration(seconds: 10));
  // }

  // Future<bool> filesWereSent(AudioModel _audio,List<PhotoModel> _listPhotoModel,int _idEncuesta)async{
  //   _audio.encuestaId = _idEncuesta;
  //   if(_listPhotoModel.isNotEmpty){
  //     final bool _isPhotosOk = await subirImagen(_listPhotoModel,_idEncuesta,false);
  //     final bool _isAudioOk =await subirAudio(_audio);
  //     if(_isAudioOk && _isPhotosOk)return true;
  //   }else{
  //     final bool _isAudioOk =await subirAudio(_audio);
  //     if(_isAudioOk)return true;
  //   }
  //   return false;
  // }

  Future<bool>subirAudio(AudioModel _audio)async{
    bool isOk;
    try{
      final _response = await postAudio(_audio).timeout(const Duration(seconds: 10));
       final Map _responseEncoded = json.decode(_response.body);
       final int _status = await utils.checkToken(json.decode(_response.body), false);
       if(_status == 0){
         print("Token caducado");
         isOk = false;
       }else if (_response.statusCode!=200 ||_responseEncoded["response"]["code"] == 1) {
        print("Error");
        print(_response.statusCode);
        isOk = false;
      }else if (_response.statusCode == 200){
        DBProvider.db.updateAudio(_audio.registroId, _audio.encuestaId);
        isOk = true;
      }
    }on TimeoutException catch(e){
      print('Timeout: $e');
      isOk = false;
      //Get.back();
    } on Error catch(e){
      print('Error: $e');
      isOk = false;
      //Get.back();
    }
    return isOk;
  }

  // Future<bool> subirImagen(List<PhotoModel> _listPhotoModel,int _idEncuesta, bool isFromHome) async {
  //   final GlobalController globalController = Get.find<GlobalController>();
  //   bool isOk = true;
  //   for(int i = 0; i < _listPhotoModel.length && isOk == true; i++){
  //     (isFromHome)
  //     ?print("IsFromHome")
  //     :_listPhotoModel[i].encuestaId = _idEncuesta;
  //     try{
  //       final _response = await postPhoto(_listPhotoModel[i]);
  //       final Map _responseEncoded = json.decode(_response.body);
  //       final int _status = await utils.checkToken(_responseEncoded, false);
  //       if(_status == 0){
  //         print("Token caducado");
  //         isOk = false;
  //       } 
  //     if (_response.statusCode!=200 ||_responseEncoded["response"]["code"] == 1) {
  //       print("Error");
  //       print(_response.statusCode);
  //       isOk = false;
  //     }else if (_response.statusCode == 200){
  //       isOk = true;
  //       DBProvider.db.updatePhoto(_listPhotoModel[i].registroId, _idEncuesta);
  //       globalController.ultimosArchivosEnviados++;
  //     }
  //     }on TimeoutException catch(e){
  //       print('Timeout: $e');
  //       isOk = false;
  //     } on Error catch(e){
  //       print('Error: $e');
  //       isOk = false;
  //     }
  //     if(isOk == false)return isOk;
  //   }
  //   return isOk;
  // }
 }