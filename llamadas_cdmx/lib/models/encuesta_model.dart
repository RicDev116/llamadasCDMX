import 'dart:convert';
import 'package:meta/meta.dart';

EnucestaModel enucestaModelFromJson(String str) => EnucestaModel.fromJson(json.decode(str));

String enucestaModelToJson(EnucestaModel data) => json.encode(data.toJson());

class EnucestaModel {
  EnucestaModel({
    @required this.apiToken,
    @required this.registroId,
    @required this.statusId,
    @required this.tiempo,
    @required this.participara,
    @required this.latitud,
    @required this.longitud,
    @required this.audio,
    @required this.respuesta1,
  });

  String apiToken;
  int registroId;
  int statusId;
  String tiempo;
  int participara;
  String latitud;
  String longitud;
  String audio;
  String respuesta1;

  factory EnucestaModel.fromJson(Map<String, dynamic> user) => EnucestaModel(
        apiToken: user["api_token"],
        registroId: user["registro_id"],
        statusId: user["status_id"],
        tiempo: user["tiempo"],
        participara: user["participara"],
        latitud: user["latitud"],
        longitud: user["longitud"],
        audio: json.encode(user["audio"]),
        respuesta1: user["respuesta_1"],
      );

  Map<String, dynamic> toJson() => {
        "api_token": apiToken,
        "registro_id": registroId,
        "status_id": statusId,
        "tiempo": tiempo,
        "participara": participara,
        "latitud": latitud,
        "longitud": longitud,
        "audio": audio,
        "respuesta_1":respuesta1,
      };
}
