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
      await LogHelper.writeLog("INFO: Koleksi belum siap, mencoba rekoneksi...", source: _source, level: 3);
      await connect();
    }
    return _collection!;
  }

    Future<void> connect() async {
    try {
      final dbUri = dotenv.env['MONGODB_URI'];
      if (dbUri == null) throw Exception("MONGODB_URI tidak ditemukan di .env");

      _db = await Db.create(dbUri);
      await _db!.open(secure: true).timeout(const Duration(seconds: 15), onTimeout: () => throw Exception("Koneksi Timeout. Cek IP Whitelist atau sinyal."));
      _collection = _db!.collection('logs');

      await LogHelper.writeLog("DATABASE: Terhubung & Koleksi Siap", source: _source, level: 2);
    } catch (e) {
      await LogHelper.writeLog("DATABASE: Gagal Koneksi - $e", source: _source, level: 1);
      rethrow;
    }
  }

  Future<void> close() async => await _db?.close();

  Future<List<LogModel>> getLogs() async {
    try {
      final collection = await _getSafeCollection();
      await LogHelper.writeLog("INFO: Fetching data from Cloud...", source: _source, level: 3);
      final List<Map<String, dynamic>> data = await collection.find().toList();
      return data.map((json) => LogModel.fromMap(json)).toList();
    } catch (e) {
      await LogHelper.writeLog("DATABASE: Gagal getLogs - $e", source: _source, level: 1);
      rethrow;
    }
  }

  Future<void> insertLog(LogModel log) async {
    try {
      final collection = await _getSafeCollection();
      await collection.insertOne(log.toMap());
      await LogHelper.writeLog("INFO: Log berhasil disimpan ke Cloud", source: _source, level: 2);
    } catch (e) {
      await LogHelper.writeLog("DATABASE: Gagal insertLog - $e", source: _source, level: 1);
      rethrow;
    }
  }

  Future<void> updateLog(ObjectId id, LogModel newLog) async {
    try {
      final collection = await _getSafeCollection();
      await collection.updateOne(where.id(id), modify.set('title', newLog.title).set('description', newLog.description).set('category', newLog.category));
      await LogHelper.writeLog("INFO: Log berhasil diupdate", source: _source, level: 2);
    } catch (e) {
      await LogHelper.writeLog("DATABASE: Gagal updateLog - $e", source: _source, level: 1);
      rethrow;
    }
  }

  Future<void> deleteLog(ObjectId id) async {
    try {
      final collection = await _getSafeCollection();
      await collection.deleteOne(where.id(id));
      await LogHelper.writeLog("INFO: Log berhasil dihapus", source: _source, level: 2);
    } catch (e) {
      await LogHelper.writeLog("DATABASE: Gagal deleteLog - $e", source: _source, level: 1);
      rethrow;
    }
  }
}