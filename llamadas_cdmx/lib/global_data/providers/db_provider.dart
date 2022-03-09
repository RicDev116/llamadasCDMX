import 'dart:io';
import 'package:intl/intl.dart';
import 'package:login_template/models/user_model.dart';
import 'package:login_template/models/audio_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DBProvider {
  static Database _database;
  static final DBProvider db = DBProvider._();
  DBProvider._(); 

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();

    return _database;
  }

  bool isLoadingDB = false;

  Future<Database> initDB() async {
    //Path donde almacenaremos la BD
    isLoadingDB = true;

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String nameDB = DotEnv().env["APP_NAME"] + '.db';
    final path = join(documentsDirectory.path, nameDB);
    //print(path);

    // await deleteDatabase(patkh);
    return await openDatabase(path, version: 39,
        onCreate: (Database db, int version) async {
      await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY,
            user_id INTEGER NOT NULL,
            role varchar(255) NOT NULL,
            name varchar(255) NOT NULL,
            paterno varchar(255),
            materno varchar(255),
            email varchar(255) NOT NULL,
            access_token TEXT NOT NULL,
            adicionales TEXT,
            created_at timestamp(0) NOT NULL,
            updated_at timestamp(0) NOT NULL
          );
        ''');

      await db.execute('''
          CREATE TABLE audios(
            uuid TEXT PRIMARY KEY,
            registro_id INTEGER NOT NULL,
            user_id INTEGER NOT NULL,
            latitude varchar(255) NOT NULL,
            longitude varchar(255) NOT NULL,
            imei varchar(255) NOT NULL,
            audio_name varchar(255),
            captured_at timestamp(0),
            modified_at timestamp(0),
            enviado INTEGER NOT NULL,
            encuesta_id INTEGER
          );
        ''');

      await db.execute('''
       CREATE TABLE location(
            id INTEGER PRIMARY KEY,
            token TEXT NOT NULL,
            imei TEXT NOT NULL,
            latitude TEXT NOT NULL,
            longitude TEXT NOT NULL,
            data TEXT,
            project TEXT NOT NULL,
            enviado INTEGER NOT NULL
          );
      ''');

        var batch = db.batch();                               
        await batch.commit();
        isLoadingDB = false;
    },
    onUpgrade: (Database db, int oldVersion, int newVersion) async {
      isLoadingDB = true;
      var batch = db.batch();                                                 
      await batch.commit();
      isLoadingDB = false;
    });
  }          

  Future<dynamic> updateIMEI(String tabla,String imei) async {
    final db = await database;
    final uRegistro = await db.rawQuery('''
        UPDATE $tabla SET 'imei' = '$imei'
      ''');
    await db.rawQuery('''
        UPDATE photos SET 'imei'= '$imei';
      ''');
    await db.rawQuery('''
        UPDATE audios SET 'imei' = '$imei';
      ''');
    return uRegistro;
  }

  Future<int> nuevoUsuario(UserModel nuevoUser) async {
    final userId = nuevoUser.userId;
    final accessToken = nuevoUser.accessToken;
    final updatedAt = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(DateTime.now());
    //verificar la BD
    final db = await database;
    var checkPrevious = await db.rawQuery('''
      SELECT EXISTS(SELECT 1 FROM users WHERE user_id = $userId and updated_at >= '$formatted' LIMIT 1) as previo;
    ''');
    var dbItem = checkPrevious.first;
    var previo = dbItem['previo'];
    var res;
    if (previo == 1) {
      final res = await db.rawQuery('''
        UPDATE users SET "updated_at" = '$updatedAt', access_token = '$accessToken' WHERE user_id = $userId
      ''');
      print(res);
    } else {
      Map data = nuevoUser.toJson();

      data['created_at'] = DateTime.now().toString();
      data['updated_at'] = DateTime.now().toString();
      final res = await db.insert('users', data);
      print(res);
    }
    return res;
  }

  Future<List<UserModel>> getUserById(int id) async {
    final db = await database;
    final res = await db.rawQuery(''' SELECT * FROM users WHERE user_id = $id ORDER BY id DESC LIMIT 1; ''');
    return res.isNotEmpty
        ? res.map((s) => UserModel.fromJson(s)).toList()
        : null;
  }

  Future<List> getAllRegisters() async {
    final db = await database;
    final res = await db.rawQuery('SELECT * FROM users');
    return res;
  }

  Future<int> deleteOldRegisters() async {
    // final DateFormat formatter = DateFormat('yyyy-MM-dd');
    // final String formatted = formatter.format(DateTime.now());
    //verificar la BD
    final db = await database;
    return await db.rawDelete('''
      DELETE FROM users;
    ''');
  }

  Future<int> deleteOldAudios() async {
    final db = await database;
    return await db.rawDelete('''
      DELETE FROM audios WHERE enviado = 1;
    ''');
  }
  
  Future<int> nuevoAudio(AudioModel nuevoAudio) async {
    //verificar la BD
    final db = await database;
    Map data = nuevoAudio.toJson();
    final res = await db.insert('audios', data);
    return res;
  }

  Future<AudioModel> getAudioById(int registroId) async {
    final db = await database;
    final res = await db.query('audios', where: 'registro_id = ?', whereArgs: [registroId]);
    return res.isNotEmpty ? AudioModel.fromJson(res.first) : null;
  }

  Future<List<AudioModel>> getAudioPendientesEnvio() async {
    final db = await database;
    final res =
        await db.query('audios', where: 'enviado = 0 and encuesta_id IS NOT NULL');
    return res.isNotEmpty
        ? res.map((s) => AudioModel.fromJson(s)).toList()
        : null;
  }

  Future<dynamic> updateAudio(int registroId, int encuestaId) async {
    var modified = DateTime.now();
    final db = await database;
    final res = await db.rawQuery('''
        UPDATE audios SET 'modified_at' = '$modified', 'encuesta_id' = $encuestaId,'enviado' = 1 WHERE registro_id = $registroId;
      ''');
    return res;
  }

}