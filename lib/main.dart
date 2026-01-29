import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import 'logger_controller.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Phone Event Logger',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: EventLogger(),
      initialBinding: BindingsBuilder(() {
        Get.put(LoggerController());
      }),
    );
  }
}

class EventLogger extends StatelessWidget {
  final LoggerController controller = Get.put(LoggerController());

  EventLogger({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Private Event Log"),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: controller.sendLogFile,
          ),
        ],
      ),
      body: Obx(
        () => ListView.builder(
          itemCount: controller.logs.length,
          itemBuilder: (context, index) =>
              ListTile(title: Text(controller.logs[index]), dense: true),
        ),
      ),
    );
  }
}
