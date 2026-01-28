import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(home: EventLogger());
}

class EventLogger extends StatefulWidget {
  const EventLogger({super.key});
  @override
  State<EventLogger> createState() => _EventLoggerState();
}

class _EventLoggerState extends State<EventLogger> {
  static const platform = MethodChannel('com.example.app/events');
  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler((call) async {
      if (call.method == "onKeyStroke") {
        setState(() {
          logs.insert(0, "${DateTime.now()}: ${call.arguments}");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Private Event Log")),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) =>
            ListTile(title: Text(logs[index]), dense: true),
      ),
    );
  }
}
