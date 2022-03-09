import 'dart:convert';
import 'package:get/get.dart';
import 'package:meta/meta.dart';

AudioModel audioModelFromJson(String str) => AudioModel.fromJson(json.decode(str));

String audioModelToJson(AudioModel data) => json.encode(data.toJson());

class AudioModel {
    AudioModel({
        @required this.uuid,//generar de automatico 
        @required this.registroId,//el que se genera automatico 
        @required this.userId,
        @required this.latitude,
        @required this.longitude,
        @required this.imei,
        this.audio,
        @required this.audioName,
        @required this.capturedAt,
        @required this.modifiedAt,
        @required this.enviado,
        this.encuestaId,
    });

    String uuid;
    int registroId;
    int userId;
    String latitude;
    String longitude;
    String imei;
    MultipartFile audio;
    String audioName;
    DateTime capturedAt;
    DateTime modifiedAt;
    int enviado;
    dynamic encuestaId;

    factory AudioModel.fromJson(Map<String, dynamic> json){
      if(json["audio"] != null){
        return AudioModel(
        uuid: json["uuid"],
        registroId: json["registro_id"],
        userId: json["user_id"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        imei: json["imei"],
        audio: json["audio"],
        audioName: json["audio_name"],
        capturedAt: DateTime.parse(json["captured_at"]),
        modifiedAt: DateTime.parse(json["modified_at"]),
        enviado: json["enviado"],
        encuestaId: json["encuesta_id"],
       );
      }else{
        return AudioModel(
        uuid: json["uuid"],
        registroId: json["registro_id"],
        userId: json["user_id"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        imei: json["imei"],
        audioName: json["audio_name"],
        capturedAt: DateTime.parse(json["captured_at"]),
        modifiedAt: DateTime.parse(json["modified_at"]),
        enviado: json["enviado"],
        encuestaId: json["encuesta_id"],
       );
      }
    } 

    Map<String, dynamic> toJson(){
      if(audio !=null){
        return {
          "uuid": uuid,
          "registro_id": registroId,
          "user_id": userId,
          "latitude": latitude,
          "longitude": longitude,
          "imei": imei,
          "audio":audio,
          "audio_name": audioName,
          "captured_at": capturedAt.toIso8601String(),
          "modified_at": modifiedAt.toIso8601String(),
          "enviado": enviado,
          "encuesta_id": encuestaId,
        };
      }else{
        return {
          "uuid": uuid,
          "registro_id": registroId,
          "user_id": userId,
          "latitude": latitude,
          "longitude": longitude,
          "imei": imei,
          "audio_name": audioName,
          "captured_at": capturedAt.toIso8601String(),
          "modified_at": modifiedAt.toIso8601String(),
          "enviado": enviado,
          "encuesta_id": encuestaId,
        };
      }
    } 
}
