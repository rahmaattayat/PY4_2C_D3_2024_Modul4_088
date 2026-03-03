import 'dart:developer' as dev;
import 'dart:io'; 
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

class LogHelper {
  static Future<void> writeLog(String message, {String source = "Unknown", int level = 2}) async {
    final int configLevel = int.tryParse(dotenv.env['LOG_LEVEL'] ?? '2') ?? 2;
    final String muteList = dotenv.env['LOG_MUTE'] ?? '';

    if (level > configLevel) return;
    if (muteList.split(',').contains(source)) return;

    try {
      final DateTime now = DateTime.now();
      final String timestamp = DateFormat('HH:mm:ss').format(now);
      final String label = _getLabel(level);
      final String color = _getColor(level);

      dev.log(message, name: source, time: now, level: level * 100);
      print('$color[$timestamp][$label][$source] -> $message\x1B[0m');

      await _writeToFile(timestamp, label, source, message);

    } catch (e) {
      dev.log("Logging failed: $e", name: "SYSTEM", level: 1000);
    }
  }

static Future<void> _writeToFile(String time, String label, String source, String msg) async {
  try {
    final String fileName = DateFormat('dd-MM-yyyy').format(DateTime.now());
    Directory directory;

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      directory = Directory('logs'); 
    } else {
      final directoryPath = (await getApplicationDocumentsDirectory()).path;
      directory = Directory('$directoryPath/logs');
    }

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final file = File('${directory.path}/$fileName.log');
    final logEntry = '[$time][$label][$source] -> $msg\n';

    await file.writeAsString(logEntry, mode: FileMode.append);
  } catch (e) {

  }
}

  static String _getLabel(int level) {
    switch (level) {
      case 1: return "ERROR";
      case 2: return "INFO";
      case 3: return "VERBOSE";
      default: return "LOG";
    }
  }

  static String _getColor(int level) {
    switch (level) {
      case 1: return '\x1B[31m'; 
      case 2: return '\x1B[32m'; 
      case 3: return '\x1B[34m'; 
      default: return '\x1B[0m';
    }
  }
}