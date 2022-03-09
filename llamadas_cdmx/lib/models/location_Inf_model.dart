import 'dart:convert';
import 'package:meta/meta.dart';

LocationInf locationInfFromJson(String str) => LocationInf.fromJson(json.decode(str));

String locationInfToJson(LocationInf data) => json.encode(data.toJson());

class LocationInf {

    LocationInf({
      this.id,
      @required this.token,
      @required this.imei,
      @required this.latitude,
      @required this.longitude,
      @required this.data,
      @required this.project,
      @required this.enviado,
    });

    int id;
    String token;
    String imei;
    String latitude;
    String longitude;
    String data;
    String project;
    int enviado;

    factory LocationInf.fromJson(Map<String, dynamic> json) => LocationInf(
      id: json["id"],
      token: json["token"],
      imei: json["imei"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      data: json["data"],
      project: json["project"],
      enviado: json["enviado"],
    );

    Map<String, dynamic> toJson() => {
      "id":id,
      "token":token,
      "imei":imei,
      "latitude":latitude,
      "longitude":longitude,
      "data": data,
      "project":project,
      "enviado":enviado,
    };

}
