import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';

class TranscribePage extends StatefulWidget {
  @override
  _TranscribePageState createState() => _TranscribePageState();
}

class _TranscribePageState extends State<TranscribePage> {
  String outputText = "";
  String? selectedModel; // Track the selected model
  List<XFile> _droppedFiles = []; // Store the paths of dropped files
  final TextEditingController _outputController = TextEditingController();

  @override
  void dispose() {
    _outputController
        .dispose(); // Dispose of the controller when the widget is disposed
    super.dispose();
  }

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
                  backgroundColor:
                      selectedModel == 'OpenAI' ? Colors.purple[100] : null,
                ),
                child: Text('OpenAI'),
              ),
              ElevatedButton(
                onPressed: () => setState(() => selectedModel = 'Azure'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedModel == 'Azure' ? Colors.purple[100] : null,
                ),
                child: Text('Azure'),
              ),
              ElevatedButton(
                onPressed: () => setState(() => selectedModel = 'Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedModel == 'Google' ? Colors.purple[100] : null,
                ),
                child: Text('Google'),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Row(children: [
            Text('Drop your file here:', style: TextStyle(fontSize: 18)),
            SizedBox(width: 10.0),
            // Run button
            ElevatedButton(
              onPressed: () {
                if (_droppedFiles.isNotEmpty) {
                  runExternalCommand(_droppedFiles.first.path);
                }
              },
              child: Text('Run'),
            ),
          ]),
          SizedBox(height: 8.0),
          // Drag and Drop file area
          Container(
            height: 120.0,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(4.0),
              color: Colors.grey[200],
            ),
            child: DropTarget(
              onDragDone: (detail) {
                setState(() {
                  _droppedFiles
                      .clear(); // Clear the list of previously dropped files
                  if (detail.files.isNotEmpty) {
                    _droppedFiles.add(
                        detail.files.last); // Add only the most recent file
                  }

                  // Update the outputText to reflect the newly dropped file
                  outputText = "Dropped file:\n" +
                      _droppedFiles.map((file) => file.path).join("\n");
                });
              },
              onDragEntered: (detail) {
                setState(() {});
              },
              onDragExited: (detail) {
                setState(() {});
              },
              child: Center(
                child: _droppedFiles.isEmpty
                    ? Text('Drag and drop area',
                        style: TextStyle(color: Colors.grey))
                    : Text(outputText),
              ),
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
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 3.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: TextFormField(
                    controller: _outputController,
                    readOnly: true,
                    maxLines: null, // Allows for any number of lines
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      // No border here, as the border is on the container
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> runExternalCommand(String filePath) async {
    try {
      var command = 'ml transcribe openai $filePath -f txt 2>&1';
      var process = await Process.start(
        '/bin/sh',
        ['-c', command],
        runInShell: true,
      );
      debugPrint("Process started");

      // Capture the stdout and trim it to remove leading/trailing whitespace.
      var output = await utf8.decoder
          .bind(process.stdout)
          .join()
          .then((String text) => text.trim());

      // Print the combined output
      debugPrint(output);

      // Wait for the process to complete and then print the exit code
      var exitCode = await process.exitCode;
      debugPrint('Exit code: $exitCode');

      setState(() {
        _outputController.text =
            output; // Update the controller instead of outputText
      });
    } catch (e) {
      debugPrint('An error occurred while running the process: $e');
    }
  }
}
