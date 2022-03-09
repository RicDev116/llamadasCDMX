import 'dart:convert';
import 'package:meta/meta.dart';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  UserModel({
    @required this.accessToken,
    @required this.name,
    this.paterno,
    this.materno,
    @required this.email,
    @required this.userId,
    @required this.role,
    this.adicionales,
  });

  String accessToken;
  String name;
  dynamic paterno;
  dynamic materno;
  String email;
  int userId;
  String role;
  String adicionales;

  factory UserModel.fromJson(Map<String, dynamic> user) => UserModel(
        accessToken: user["access_token"],
        name: user["name"],
        paterno: user["paterno"],
        materno: user["materno"],
        email: user["email"],
        userId: user["user_id"],
        role: user["role"],
        adicionales: json.encode(user["adicionales"]),
      );

  Map<String, dynamic> toJson() => {
        "access_token": accessToken,
        "name": name,
        "paterno": paterno,
        "materno": materno,
        "email": email,
        "user_id": userId,
        "role": role,
        "adicionales": adicionales,
      };
}
