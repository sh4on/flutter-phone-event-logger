import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class LoggerController extends GetxController with WidgetsBindingObserver {
  static const platform = MethodChannel('com.example.app/events');

  var logs = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initMethodChannel();
    _loadLogsFromFile(); // Show existing logs on startup
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // Called whenever app comes back to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadLogsFromFile();
    }
  }

  void _initMethodChannel() {
    platform.setMethodCallHandler((call) async {
      if (call.method == "onKeyStroke") {
        final entry = "${DateTime.now()}: ${call.arguments}";
        debugPrint("Received from native: $entry");
        logs.insert(0, entry);
      }
    });
  }

  // Reads what Kotlin wrote to disk — the source of truth
  Future<void> _loadLogsFromFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      // Resolve to the same 'files' dir that Kotlin's filesDir points to
      final filesDir = dir.path.replaceFirst('/app_flutter', '');
      final file = File('$filesDir/../files/security_logs.txt');

      if (await file.exists()) {
        final lines = await file.readAsLines();
        logs.assignAll(lines.reversed.toList()); // newest first
      }
    } catch (e) {
      debugPrint("File load error: $e");
    }
  }
}
