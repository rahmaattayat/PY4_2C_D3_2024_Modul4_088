import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../features/logbook/models/log_model.dart';
import '../helpers/log_helper.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  Db? _db;
  DbCollection? _collection;
  final String _source = "mongo_service.dart";

  factory MongoService() => _instance;
  MongoService._internal();

  Future<DbCollection> _getSafeCollection() async {
    if (_db == null || !_db!.isConnected || _collection == null) {
      await connect();
    }
    return _collection!;
  }

  Future<void> connect() async {
    try {
      final dbUri = dotenv.env['MONGODB_URI'];
      if (dbUri == null) throw Exception("MONGODB_URI missing");
      _db = await Db.create(dbUri);
      await _db!.open(secure: true);
      _collection = _db!.collection('logs');
      await LogHelper.writeLog("DATABASE: Terhubung & Koleksi Siap", source: _source);
    } catch (e) {
      await LogHelper.writeLog("DATABASE: Gagal Koneksi - $e", source: _source, level: 1);
    }
  }

  Future<void> close() async {
    await _db?.close();
    await LogHelper.writeLog("DATABASE: Koneksi Ditutup", source: _source);
  }

  Future<List<LogModel>> getLogs(String username) async {
    try {
      final collection = await _getSafeCollection();
      final data = await collection.find(where.eq('author', username)).toList();
      return data.map((json) => LogModel.fromMap(json)).toList();
    } catch (e) {
      await LogHelper.writeLog("DATABASE: Gagal getLogs - $e", source: _source, level: 1);
      return [];
    }
  }

  Future<void> insertLog(LogModel log) async {
    try {
      final collection = await _getSafeCollection();
      await collection.insertOne(log.toMap());
      await LogHelper.writeLog("INFO: Log ${log.author} disimpan", source: _source);
    } catch (e) {
      await LogHelper.writeLog("DATABASE: Gagal insertLog - $e", source: _source, level: 1);
    }
  }

  Future<void> updateLog(ObjectId id, LogModel newLog) async {
    try {
      final collection = await _getSafeCollection();
      await collection.updateOne(
        where.id(id).and(where.eq('author', newLog.author)), 
        modify.set('title', newLog.title).set('description', newLog.description).set('category', newLog.category)
      );
    } catch (e) {
      await LogHelper.writeLog("DATABASE: Gagal updateLog - $e", source: _source, level: 1);
    }
  }

  Future<void> deleteLog(ObjectId id, String username) async {
    try {
      final collection = await _getSafeCollection();
      await collection.remove(where.id(id).and(where.eq('author', username)));
    } catch (e) {
      await LogHelper.writeLog("DATABASE: Gagal deleteLog - $e", source: _source, level: 1);
    }
  }
}