import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';

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
  String selectedFormat = 'default';  // Default output format
  String? selectedLanguage = 'Not specified';
  String outputText = '';
  bool _isRunning = false; // Track whether the command is running
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
    return MouseRegion(
        cursor: _isRunning ? SystemMouseCursors.wait : SystemMouseCursors.wait,
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
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
                  for (var format in ['default', 'txt', 'json', 'srt', 'tsv', 'vtt'])
                    ElevatedButton(
                      onPressed: () => setState(() => selectedFormat = format),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedFormat == format ? Colors.purple[100] : null,
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
                    shape: RoundedRectangleBorder(  // Square button
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
          ),
        ));
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

  Future<void> runExternalCommand(String filePath) async {
    try {
      String formatCommand = selectedFormat == 'default' ? '' : '-f $selectedFormat';
      String languageCommand = (selectedLanguage != null && selectedLanguage != 'Not specified') ? '-l $selectedLanguage' : '';
      var command = 'ml transcribe openai $filePath $languageCommand $formatCommand 2>&1';
      var process = await Process.start(
        '/bin/sh',
        ['-c', command],
        runInShell: true,
      );
      debugPrint('Command: $command');

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

      // Update the controller instead of outputText
      setState(() {
        _outputController.text = output;
      });
    } catch (e) {
      debugPrint('An error occurred while running the process: $e');
    }
  }

  void _runOrNot() {
    if (_droppedFiles.isNotEmpty && !_isRunning) {
      setState(() => _isRunning = true);
      runExternalCommand(_droppedFiles.first.path).then((_) {
        // Set _isRunning to false when the command finishes
        setState(() => _isRunning = false);
      });
    }
  }
}
