import 'dart:async'; // Tambahkan ini untuk StreamSubscription
import 'package:flutter/material.dart';
import 'package:logbook_app_088/services/mongo_service.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Import ini
import 'models/log_model.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);
  final ValueNotifier<bool> isOffline = ValueNotifier(false); 
  
  final String username;
  final MongoService _mongoService = MongoService();
  
  // Subscription untuk memantau koneksi
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  LogController({required this.username}) {
    _initConnectivity(); // Inisialisasi pengecekan koneksi
    loadLogs();
  }

  // Fungsi untuk memantau perubahan koneksi secara real-time
  void _initConnectivity() {
    // Cek status awal saat aplikasi dibuka
    Connectivity().checkConnectivity().then(_updateConnectionStatus);
    
    // Listen perubahan status internet
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Jika hasil mengandung 'none', berarti offline
    isOffline.value = results.contains(ConnectivityResult.none);
    
    // Jika kembali online, otomatis refresh data
    if (!isOffline.value) {
      loadLogs();
    }
  }

  // Penting: Panggil ini saat view di-dispose untuk mencegah memory leak
  void dispose() {
    _connectivitySubscription?.cancel();
  }

  String formatTimestamp(String dateStr) {
    try {
      DateTime date;
      try {
        date = DateTime.parse(dateStr);
      } catch (_) {
        date = DateTime.parse(dateStr.replaceFirst(' ', 'T'));
      }
      
      final Duration diff = DateTime.now().difference(date);

      if (diff.inSeconds < 60) return "Baru saja";
      if (diff.inMinutes < 60) return "${diff.inMinutes} menit yang lalu";
      if (diff.inHours < 24) return "${diff.inHours} jam yang lalu";
      if (diff.inDays == 1) return "Kemarin";
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> loadLogs() async {
    // Jika sedang offline, jangan paksa hit ke MongoDB agar tidak timeout lama
    if (isOffline.value) return;

    try {
      final logs = await _mongoService.getLogs(username);
      logsNotifier.value = logs;
      filteredLogs.value = logs;
    } catch (e) {
      print("Log Controller Error: $e");
    }
  }

  // Logika addLog, updateLog, deleteLog tetap sama...
  Future<void> addLog(String title, String desc, String category) async {
    if (isOffline.value) return; // Guard: Cegah aksi jika offline
    final newLog = LogModel(
      title: title,
      description: desc,
      category: category,
      date: DateTime.now().toIso8601String(), 
      author: username,
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
      author: username,
    );
    await _mongoService.updateLog(targetLog.id!, updatedLog);
    await loadLogs();
  }

  Future<void> removeLog(int index) async {
    final targetLog = filteredLogs.value[index];
    if (targetLog.id == null) return;

    await _mongoService.deleteLog(targetLog.id!, username);
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