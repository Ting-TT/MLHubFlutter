import 'dart:async';
import 'package:flutter/material.dart';

class LogManager {
  LogManager._privateConstructor() {
    _logController.add(List.from(_logMessages)); // Send initial log messages
    debugPrint('Initial log messages added: $_logMessages');
  }

  static final LogManager _instance = LogManager._privateConstructor();
  static LogManager get instance => _instance;

  final _logController = StreamController<List<String>>.broadcast();
  List<String> _logMessages = [];

  Stream<List<String>> get logs => _logController.stream;

  void log(String message) {
    _logMessages.add(message);
    debugPrint('Logging message: $message');
    _logController.add(List.from(_logMessages));
    debugPrint('logMessages: $_logMessages');
  }

  void clearLogs() {
    _logMessages.clear();
    _logController.add(List.from(_logMessages));
  }
}

class LogPage extends StatefulWidget {
  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  @override
  void initState() {
    super.initState();
    // Adding some initial logs for testing
    LogManager.instance.log('Initial log');
    LogManager.instance.log('Another log');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: LogManager.instance.logs,
      builder: (context, snapshot) {
        debugPrint('Stream builder rebuilt with data: ${snapshot.data}');
        
        // Show a loading indicator while waiting for data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(snapshot.data![index]),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Center(child: Text('No logs available'));
        }
      },
    );
  }
}