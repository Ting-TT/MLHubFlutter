import 'dart:convert';
import 'dart:io';
import 'log.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as Path;

// Define an enum to differentiate the modes
enum ProcessType { transcribe, translate }

class LanguageProcessPage extends StatefulWidget {
  final ProcessType processType;

  LanguageProcessPage({Key? key, required this.processType}) : super(key: key);

  @override
  _LanguageProcessPageState createState() => _LanguageProcessPageState();
}

class _LanguageProcessPageState extends State<LanguageProcessPage> {
  List<String> inputLanguageOptions = ['Not specified'];
  List<String> translationOutputLanguageOptions = ['English']; // Currently, only English is supported because only 'OpenAI' is implemented
  String? selectedModel = 'OpenAI'; // Set the default model to 'OpenAI'
  String selectedFormat = 'txt';
  String? selectedInputLanguage = 'Not specified';
  String? selectedOutputLanguage = 'English';
  String outputText = '';
  bool _isRunning = false; // Track whether the command is running
  bool _cancelled = false; // Track whether the command is cancelled
  Process? _runningProcess; // Control the process running
  List<XFile> _droppedFiles = []; // Store the paths of dropped files
  final TextEditingController _outputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSupportedLanguages();
  }

  Future<void> fetchSupportedLanguages() async {
    var result = await Process.run('ml', ['supported', 'openai']);
    if (result.exitCode == 0) {
      var languages = LineSplitter.split(result.stdout.toString()).toList();
      if (mounted) { // Check if the widget is still in the widget tree
        setState(() {
          inputLanguageOptions.addAll(languages);
        });
      }
    }
  }

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
              onPressed: null, // Disabled button for Azure
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey, // Set a disabled color
                foregroundColor: Colors.black45, // Text color for disabled state
              ),
              child: Text('Azure'),
            ),
            ElevatedButton(
              onPressed: null, // Disabled button for Google
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey, // Set a disabled color
                foregroundColor: Colors.black45, // Text color for disabled state
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

        // Language options
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                // Language of the input audio file
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Input Language:', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 5.0),
                  DropdownSearch<String>(
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      showSelectedItems: true,
                      searchDelay: Duration(seconds: 0),
                    ),
                    items: inputLanguageOptions,
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          selectedInputLanguage = value;
                        });
                      }
                    },
                    selectedItem: "Not specified",
                  ),
                ],
              ),
            ),
            // Output language for the translation task
            if (widget.processType == ProcessType.translate) ...[
              SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Output Language:', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 5.0),
                    DropdownSearch<String>(
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        showSelectedItems: true,
                        searchDelay: Duration(seconds: 0),
                      ),
                      items: translationOutputLanguageOptions,
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            selectedOutputLanguage = value;
                          });
                        }
                      },
                      selectedItem: selectedOutputLanguage,
                    ),
                  ],
                ),
              ),
            ]
          ],
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
              if (mounted) {
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
              }
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
            onPressed: saveToFile,
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
      if (mounted) {
        setState(() {
          _droppedFiles.clear(); // Clear previous files
          _droppedFiles.add(XFile(result.files.single.path!));
          outputText = 'Selected file:\n' +
              _droppedFiles.map((file) => file.path).join('\n');
        });
      }
    }
  }

  void _runOrNot() {
    if (_droppedFiles.isNotEmpty && !_isRunning) {
      // Check MIME type
      var mimeType = lookupMimeType(_droppedFiles.first.path);

      // Check if the file type is audio or video
      if (mimeType != null && (mimeType.startsWith('audio/') || mimeType.startsWith('video/'))) {
        if (mounted) {setState(() => _isRunning = true);}
        runExternalCommand(_droppedFiles.first.path).then((_) {
          // Set _isRunning to false when the command finishes
          if (mounted) {setState(() => _isRunning = false);}
        });
      } else {
        // Update UI with error message if file is not audio/video
        if (mounted) {
          setState(() {
            _outputController.text =
                "Input file doesn't look like an audio or video file, please check the input file type.";
          });
        }
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
          (selectedInputLanguage != null && selectedInputLanguage != 'Not specified')
              ? '-l $selectedInputLanguage'
              : '';
      String operation = widget.processType == ProcessType.transcribe ? 'transcribe' : 'translate';
      var command = 'ml $operation openai "$escapedFilePath" $languageCommand $formatCommand 2>&1';
      
      _runningProcess = await Process.start(
        '/bin/sh',
        ['-c', command],
        runInShell: true,
      );
      debugPrint('Command: $command');
      LogManager.instance.log('Command: $command');

      // Capture the stdout and trim it to remove leading/trailing whitespace.
      String completeOutput = "";
      await for (var output in _runningProcess!.stdout.transform(utf8.decoder)) {
        if (_cancelled) break;  // Stop processing if cancelled
        completeOutput += output;
      }
      if (mounted) {
        setState(() {
            _outputController.text = completeOutput.trim();  
        });
      }
      debugPrint(completeOutput.trim());
      LogManager.instance.log('Output: $completeOutput');
    } catch (e) {
      if (mounted) {setState(() => _outputController.text = 'Error: $e');}
      debugPrint('An error occurred while running the process: $e');
    }
  }

  Future<void> saveToFile() async {
    if (_outputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No output to save.')),
      );
      return;
    }

    String defaultFileName = Path.basenameWithoutExtension(_droppedFiles.first.path) + ".$selectedFormat";
    String initialDirectory = Path.dirname(_droppedFiles.first.path);

    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save your file',
      fileName: defaultFileName,
      initialDirectory: initialDirectory,
      type: FileType.custom,
      allowedExtensions: [selectedFormat],
    );

    if (path != null) {
      File file = File(path);
      try {
        await file.writeAsString(_outputController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File saved to $path')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save file: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File save failed.')),
        );
      }
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
      if (mounted) {
        setState(() {
          _isRunning = false;
          _outputController.text = 'Operation cancelled.';
        });
      }
    }
  }
}
