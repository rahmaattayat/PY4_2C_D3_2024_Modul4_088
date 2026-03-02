import 'package:flutter/material.dart';
import 'package:logbook_app_088/services/mongo_service.dart';
import 'models/log_model.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);

  final String username;
  final MongoService _mongoService = MongoService();

  LogController({required this.username}) {
    loadLogs();
  }

  Future<void> loadLogs() async {
    try {
      final logs = await _mongoService.getLogs();
      logsNotifier.value = logs;
      filteredLogs.value = logs;
    } catch (e) {
      // Error ditangani di UI
    }
  }

  Future<void> addLog(String title, String desc, String category) async {
    final newLog = LogModel(
      title: title,
      description: desc,
      category: category,
      date: DateTime.now().toString(),
    );
    await _mongoService.insertLog(newLog);
    await loadLogs();
  }

  Future<void> updateLog(int index, String title, String desc, String category) async {
    final targetLog = filteredLogs.value[index];
    if (targetLog.id == null) return;

    final updatedLog = LogModel(
      id: targetLog.id,
      title: title,
      description: desc,
      category: category,
      date: targetLog.date,
    );
    await _mongoService.updateLog(targetLog.id!, updatedLog);
    await loadLogs();
  }

  Future<void> removeLog(int index) async {
    final targetLog = filteredLogs.value[index];
    if (targetLog.id == null) return;

    await _mongoService.deleteLog(targetLog.id!);
    await loadLogs();
  }

  void searchLog(String query) {
    if (query.isEmpty) {
      filteredLogs.value = logsNotifier.value;
    } else {
      filteredLogs.value = logsNotifier.value
          .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}