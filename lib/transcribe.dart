import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:convert';

Future<void> runExternalCommand() async {
  try {
    // Define the environment variables for the process
    Map<String, String> environmentVars = {
      // 'PATH': '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/anaconda3/bin',
      // Add other necessary environment variables here
    };

    // Start the process with the specified environment
    var process = await Process.start(
      '/bin/sh',
      ['-c', 'ml transcribe openai harvard.wav -l en 2>&1'], // 2>&1: Redirect stderr to stdout
      environment: environmentVars, // Set environment variables here
      runInShell: true, // Consider if you need to run in a shell
    );
    debugPrint("Process started");

    // Capture the stdout stream and convert it to a single string
    var output = await utf8.decoder.bind(process.stdout).join(); // Use `join()` to convert the stream to a single string

    // Print the combined output
    debugPrint(output);

    // Wait for the process to complete and then print the exit code
    var exitCode = await process.exitCode;
    debugPrint('Exit code: $exitCode');
  } catch (e) {
    debugPrint('An error occurred while running the process: $e');
  }
}

class TranscribePage extends StatefulWidget {
  @override
  _TranscribePageState createState() => _TranscribePageState();
}

class _TranscribePageState extends State<TranscribePage> {
  String outputText = "";
  String? selectedModel; // Track the selected model

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Models available:', style: TextStyle(fontSize: 18)),
          SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0, // Space between buttons
            // Buttons for different models
            children: <Widget>[
              ElevatedButton(
                onPressed: () => setState(() => selectedModel = 'OpenAI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedModel == 'OpenAI' ? Colors.purple[100] : null,
                ),
                child: Text('OpenAI'),
              ),
              ElevatedButton(
                onPressed: () => setState(() => selectedModel = 'Azure'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedModel == 'Azure' ? Colors.purple[100] : null,
                ),
                child: Text('Azure'),
              ),
              ElevatedButton(
                onPressed: () => setState(() => selectedModel = 'Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedModel == 'Google' ? Colors.purple[100] : null,
                ),
                child: Text('Google'),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Row(children: [
            Text('Drop your file here:', style: TextStyle(fontSize: 18)),
            SizedBox(width: 10.0),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement save functionality
                runExternalCommand();
              },
              child: Text('Run'),
            ),
          ]),
          SizedBox(height: 8.0),
          Container(
            height: 150.0,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(4.0),
              color: Colors.grey[200],
            ),
            child: DragTarget(
              onAccept: (data) {
                // TODO: Handle file dropped
              },
              builder: (_, __, ___) {
                return Center(
                  child: Text('Drag and drop area',
                      style: TextStyle(color: Colors.grey)),
                );
              },
            ),
          ),
          SizedBox(height: 16.0),
          Row(children: [
            Text('Output:', style: TextStyle(fontSize: 18)),
            SizedBox(width: 10.0),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement save functionality
              },
              child: Text('Save'),
            ),
          ]),
          SizedBox(height: 8.0),
          TextFormField(
            initialValue: outputText,
            readOnly: true,
            maxLines: null, // TODO: Set max lines as needed
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}