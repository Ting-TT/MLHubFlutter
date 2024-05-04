import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

List<String> languageOptions = [
  "Not specified",
  "Afrikaans",
  "Albanian",
  "Amharic",
  "Arabic",
  "Armenian",
  "Assamese",
  "Azerbaijani",
  "Bashkir",
  "Basque",
  "Belarusian",
  "Bengali",
  "Bosnian",
  "Breton",
  "Bulgarian",
  "Cantonese",
  "Catalan",
  "Chinese",
  "Croatian",
  "Czech",
  "Danish",
  "Dutch",
  "English",
  "Estonian",
  "Faroese",
  "Finnish",
  "French",
  "Galician",
  "Georgian",
  "German",
  "Greek",
  "Gujarati",
  "Haitian Creole",
  "Hausa",
  "Hebrew",
  "Hindi",
  "Hungarian",
  "Icelandic",
  "Indonesian",
  "Italian",
  "Japanese",
  "Javanese",
  "Kannada",
  "Kazakh",
  "Khmer",
  "Korean",
  "Latin",
  "Latvian",
  "Lingala",
  "Lithuanian",
  "Luxembourgish",
  "Macedonian",
  "Malagasy",
  "Malay",
  "Malayalam",
  "Maltese",
  "Marathi",
  "Maori",
  "Mongolian",
  "Myanmar",
  "Nepali",
  "Nynorsk",
  "Occitan",
  "Pashto",
  "Persian",
  "Polish",
  "Portuguese",
  "Punjabi",
  "Romanian",
  "Russian",
  "Sanskrit",
  "Serbian",
  "Sindhi",
  "Sinhala",
  "Slovak",
  "Slovenian",
  "Somali",
  "Spanish",
  "Swahili",
  "Swedish",
  "Tagalog",
  "Tajik",
  "Tamil",
  "Tatar",
  "Telugu",
  "Thai",
  "Tibetan",
  "Turkish",
  "Turkmen",
  "Ukrainian",
  "Urdu",
  "Uzbek",
  "Vietnamese",
  "Welsh",
  "Yiddish",
  "Yoruba"
];

class TranscribePage extends StatefulWidget {
  @override
  _TranscribePageState createState() => _TranscribePageState();
}

class _TranscribePageState extends State<TranscribePage> {
  String? selectedModel = 'OpenAI'; // Set the default model to 'OpenAI'
  String selectedFormat = 'txt';
  String? selectedLanguage = 'Not specified';
  String outputText = '';
  bool _isRunning = false; // Track whether the command is running
  bool _cancelled = false; // Track whether the command is cancelled
  Process? _runningProcess; // Control the process running
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
    debugPrint('Building with _isRunning: $_isRunning');
    return Container(
      child: Stack(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(16.0),
              child: buildMainContent(),  // Apply padding only to main content
          ),
          if (_isRunning) buildOverlay(), // Present a processing page
        ],
      ),
    );
  }

  Widget buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Models available
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

        // Output format
        Text('Output format:', style: TextStyle(fontSize: 18)),
        SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0, // Space between buttons
          children: <Widget>[
            for (var format in ['txt', 'json', 'srt', 'tsv', 'vtt'])
              ElevatedButton(
                onPressed: () => setState(() => selectedFormat = format),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedFormat == format ? Colors.purple[100] : null,
                ),
                child: Text(format),
              ),
          ],
        ),
        SizedBox(height: 16.0),

        // Language of the input audio file
        Text('Input Language:', style: TextStyle(fontSize: 18)),
        SizedBox(height: 5.0),
        DropdownSearch<String>(
          popupProps: PopupProps.menu(
            showSelectedItems: true,
          ),
          items: languageOptions,
          onChanged: (value) {
            setState(() {
              selectedLanguage = value;
            });
          },
          selectedItem: "Not specified",
        ),
        SizedBox(height: 20.0),

        Row(children: [
          Text('Drop your file here:', style: TextStyle(fontSize: 18)),
          SizedBox(width: 10.0),
          ElevatedButton(
            onPressed: _pickFile,
            child: Text('Choose File'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                // Square button
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
          SizedBox(width: 10.0),
          // Run button
          ElevatedButton(
            onPressed: _runOrNot,
            child: _isRunning ? Text('Running') : Text('Run'),
          ),
        ]),
        SizedBox(height: 8.0),
        // Drag and Drop file area
        Container(
          height: 80.0,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(4.0),
            color: Colors.grey[200],
          ),
          child: DropTarget(
            onDragDone: (detail) {
              setState(() {
                // Clear the list of previously dropped files
                _droppedFiles.clear();
                if (detail.files.isNotEmpty) {
                  // Add only the most recent file
                  _droppedFiles.add(detail.files.last);
                }

                // Update the outputText to reflect the newly dropped file
                outputText = 'Selected file:\n' +
                    _droppedFiles.map((file) => file.path).join('\n');
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
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _droppedFiles.clear(); // Clear previous files
        _droppedFiles.add(XFile(result.files.single.path!));
        outputText = 'Selected file:\n' +
            _droppedFiles.map((file) => file.path).join('\n');
      });
    }
  }

  void _runOrNot() {
    if (_droppedFiles.isNotEmpty && !_isRunning) {
      // Check MIME type
      var mimeType = lookupMimeType(_droppedFiles.first.path);

      // Check if the file type is audio or video
      if (mimeType != null &&
          (mimeType.startsWith('audio/') || mimeType.startsWith('video/'))) {
        setState(() => _isRunning = true);
        runExternalCommand(_droppedFiles.first.path).then((_) {
          // Set _isRunning to false when the command finishes
          setState(() => _isRunning = false);
        });
      } else {
        // Update UI with error message if file is not audio/video
        setState(() {
          _outputController.text =
              "Input file doesn't look like an audio or video file, please check the input file type.";
        });
      }
    }
  }

  Future<void> runExternalCommand(String filePath) async {
    _cancelled = false;  // Reset the cancellation flag
    try {
      // Escape spaces in the filePath
      String escapedFilePath = filePath.replaceAll(' ', '\\ ');
      // When selectedFormat is txt, do not add argument '-f txt'
      // because default ml command without '-f' specified will output text
      // one sentence per line which is more desired than whisper txt format.
      String formatCommand =
          selectedFormat == 'txt' ? '' : '-f $selectedFormat';
      String languageCommand =
          (selectedLanguage != null && selectedLanguage != 'Not specified')
              ? '-l $selectedLanguage'
              : '';
      var command =
          'ml transcribe openai "$escapedFilePath" $languageCommand $formatCommand 2>&1';
      
      _runningProcess = await Process.start(
        '/bin/sh',
        ['-c', command],
        runInShell: true,
      );
      debugPrint('Command: $command');

      // Capture the stdout and trim it to remove leading/trailing whitespace.
      String completeOutput = "";
      await for (var output in _runningProcess!.stdout.transform(utf8.decoder)) {
        if (_cancelled) break;  // Stop processing if cancelled
        completeOutput += output;
      }
      setState(() {
          _outputController.text = completeOutput.trim();  
      });
      debugPrint(completeOutput.trim());

    } catch (e) {
      setState(() => _outputController.text = 'Error: $e');
      debugPrint('An error occurred while running the process: $e');
    }
  }

  Widget buildOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.white60, // Semi-transparent overlay
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text('Processing...', style: TextStyle(color: Colors.black, fontSize: 18)),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: cancelOperation, // Implement this method to handle cancel
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void cancelOperation() {
    if (_runningProcess != null) {
      _cancelled = true;  // Set the cancellation flag
      _runningProcess!.kill(ProcessSignal.sigint);
      setState(() {
        _isRunning = false;
        _outputController.text = 'Operation cancelled.';
      });
    }
  }
}
