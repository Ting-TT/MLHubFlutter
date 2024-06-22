/// Transcribe or translate the audio file.
///
/// Copyright (C) 2024 The Authors
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Ting Tang, Graham Williams

// TODO 20240622 gjw FILE TOO LONG. USE A MORE STRUCTURED APPROACH.

library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path_lib;

import 'package:mlflutter/log.dart';
import 'package:mlflutter/utils/save_file.dart';

// The list of languages supported by Whisper for the input audio file.
// Referred to the LANGUAGES from https://github.com/openai/whisper/blob/main/whisper/tokenizer.py

List<String> inputLanguageOptions = [
  'Not specified',
  'Afrikaans',
  'Albanian',
  'Amharic',
  'Arabic',
  'Armenian',
  'Assamese',
  'Azerbaijani',
  'Bashkir',
  'Basque',
  'Belarusian',
  'Bengali',
  'Bosnian',
  'Breton',
  'Bulgarian',
  'Cantonese',
  'Catalan',
  'Chinese',
  'Croatian',
  'Czech',
  'Danish',
  'Dutch',
  'English',
  'Estonian',
  'Faroese',
  'Finnish',
  'French',
  'Galician',
  'Georgian',
  'German',
  'Greek',
  'Gujarati',
  'Haitian creole',
  'Hausa',
  'Hawaiian',
  'Hebrew',
  'Hindi',
  'Hungarian',
  'Icelandic',
  'Indonesian',
  'Italian',
  'Japanese',
  'Javanese',
  'Kannada',
  'Kazakh',
  'Khmer',
  'Korean',
  'Lao',
  'Latin',
  'Latvian',
  'Lingala',
  'Lithuanian',
  'Luxembourgish',
  'Macedonian',
  'Malagasy',
  'Malay',
  'Malayalam',
  'Maltese',
  'Maori',
  'Marathi',
  'Mongolian',
  'Myanmar',
  'Nepali',
  'Norwegian',
  'Nynorsk',
  'Occitan',
  'Pashto',
  'Persian',
  'Polish',
  'Portuguese',
  'Punjabi',
  'Romanian',
  'Russian',
  'Sanskrit',
  'Serbian',
  'Shona',
  'Sindhi',
  'Sinhala',
  'Slovak',
  'Slovenian',
  'Somali',
  'Spanish',
  'Sundanese',
  'Swahili',
  'Swedish',
  'Tagalog',
  'Tajik',
  'Tamil',
  'Tatar',
  'Telugu',
  'Thai',
  'Tibetan',
  'Turkish',
  'Turkmen',
  'Ukrainian',
  'Urdu',
  'Uzbek',
  'Vietnamese',
  'Welsh',
  'Yiddish',
  'Yoruba',
];

// Define an enum to differentiate the modes.

enum ProcessType { transcribe, translate }

// Flag to track if a process is running
bool isProcessRunning = false;

class LanguageProcessPage extends StatefulWidget {
  final ProcessType processType;

  const LanguageProcessPage({super.key, required this.processType});

  @override
  LanguageProcessPageState createState() => LanguageProcessPageState();
}

class LanguageProcessPageState extends State<LanguageProcessPage> {
  // Currently, only English is supported because only 'OpenAI' is implemented.

  List<String> translationOutputLanguageOptions = [
    'English',
  ];

  // Set the default model to 'OpenAI'.

  String? selectedModel = 'OpenAI';

  String selectedFormat = 'txt';
  String? selectedInputLanguage = 'Not specified';
  String? selectedOutputLanguage = 'English';
  String outputText = '';

  bool _isRunning = false; // Track whether the command is running.
  bool _cancelled = false; // Track whether the command is cancelled.

  Process? _runningProcess; // Control the process running.

  final List<XFile> _droppedFiles = []; // Store the paths of dropped files.

  final TextEditingController _outputController = TextEditingController();

  // 20240622 ting Commented out fetchSupportedLanguages() function which
  // fetches the list inputLanguageOptions using "ml supported openai" command
  // and will get the most update-to-date version of what languages Whisper
  // supports.  However, this function is commented out because it takes quite a
  // few seconds to load the language list on the UI, so now we are back to use
  // a predefined inputLanguageOptions list instead.

  // @override
  // void initState() {
  //   super.initState();
  //   fetchSupportedLanguages();
  // }

  // Future<void> fetchSupportedLanguages() async {
  //   var result = await Process.run('ml', ['supported', 'openai']);
  //   if (result.exitCode == 0) {
  //     var languages = LineSplitter.split(result.stdout.toString()).toList();
  //     if (mounted) { // Check if the widget is still in the widget tree
  //       setState(() {
  //         inputLanguageOptions.addAll(languages);
  //       });
  //     }
  //   }
  // }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.

    _outputController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building with _isRunning: $_isRunning');

    return Consumer(
      builder: (context, ref, child) {
        return Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  // Apply padding only to main content.
                  buildMainContent(ref),
            ),
            // Present a processing page.
            if (_isRunning) buildOverlay(ref),
          ],
        );
      },
    );
  }

  Widget buildMainContent(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Models available.
        const Text('Models available:', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 8.0),
        Wrap(
          // Space between buttons

          spacing: 8.0,

          // Buttons for different models.

          children: <Widget>[
            ElevatedButton(
              onPressed: () => setState(() => selectedModel = 'OpenAI'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    selectedModel == 'OpenAI' ? Colors.purple[100] : null,
              ),
              child: const Text('OpenAI'),
            ),
            ElevatedButton(
              // Disabled button for Azure.
              onPressed: null,
              style: ElevatedButton.styleFrom(
                // Set a disabled color.
                backgroundColor: Colors.grey,
                // Text color for disabled state.
                foregroundColor: Colors.black45,
              ),
              child: const Text('Azure'),
            ),
            ElevatedButton(
              // Disabled button for Google.
              onPressed: null,
              style: ElevatedButton.styleFrom(
                // Set a disabled color
                backgroundColor: Colors.grey,
                // Text color for disabled state
                foregroundColor: Colors.black45,
              ),
              child: const Text('Google'),
            ),
          ],
        ),
        const SizedBox(height: 16.0),

        // Output format
        const Text('Output format:', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 8.0),
        Wrap(
          // Space between buttons.
          spacing: 8.0,
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
        const SizedBox(height: 16.0),

        // Language options.

        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                // Language of the input audio file

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text('Input Language:', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 5.0),
                  DropdownSearch<String>(
                    popupProps: const PopupProps.menu(
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
                    selectedItem: 'Not specified',
                  ),
                ],
              ),
            ),
            // Output language for the translation task
            if (widget.processType == ProcessType.translate) ...[
              const SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Output Language:',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 5.0),
                    DropdownSearch<String>(
                      popupProps: const PopupProps.menu(
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
            ],
          ],
        ),
        const SizedBox(height: 20.0),

        Row(
          children: [
            const Text('Drop your file here:', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10.0),
            ElevatedButton(
              onPressed: _pickFile,
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  // Square button
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Choose File'),
            ),
            const SizedBox(width: 10.0),
            // Run button
            ElevatedButton(
              onPressed: () => _runOrNot(ref),
              child: _isRunning ? const Text('Running') : const Text('Run'),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
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
                  outputText =
                      'Selected file:\n${_droppedFiles.map((file) => file.path).join('\n')}';
                });
              }
            },
            child: Center(
              child: _droppedFiles.isEmpty
                  ? const Text(
                      'Drag and drop area',
                      style: TextStyle(color: Colors.grey),
                    )
                  : Text(outputText),
            ),
          ),
        ),

        const SizedBox(height: 16.0),
        Row(
          children: [
            const Text('Output:', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10.0),
            ElevatedButton(
              onPressed: _outputController.text.isNotEmpty
                  ? () async {
                      String defaultFileName =
                          '${path_lib.basenameWithoutExtension(_droppedFiles.first.path)}.$selectedFormat';
                      String initialDirectory =
                          path_lib.dirname(_droppedFiles.first.path);
                      String result = await saveToFile(
                        content: _outputController.text,
                        defaultFileName: defaultFileName,
                        initialDirectory: initialDirectory,
                      );
                      if (mounted) {
                        // Check if the widget is still mounted
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(result)));
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _outputController.text.isNotEmpty ? null : Colors.grey,
                foregroundColor:
                    _outputController.text.isNotEmpty ? null : Colors.black45,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 3.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: TextFormField(
                  controller: _outputController,
                  readOnly: true,
                  maxLines: null, // Allows for any number of lines
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
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
          outputText =
              'Selected file:\n${_droppedFiles.map((file) => file.path).join('\n')}';
        });
      }
    }
  }

  void _runOrNot(WidgetRef ref) {
    // Alert user to provide an input file if none is provided
    if (_droppedFiles.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Input File Missing'),
            content: const Text(
              'Please provide an audio or video file first, either drag-and-drop or Choose File.',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      return;
    }

    if (!_isRunning) {
      // Check MIME type
      var mimeType = lookupMimeType(_droppedFiles.first.path);

      // Check if the file type is audio or video
      if (mimeType != null &&
          (mimeType.startsWith('audio/') || mimeType.startsWith('video/'))) {
        if (mounted) {
          setState(() => _isRunning = true);
        }
        runExternalCommand(_droppedFiles.first.path, ref).then((_) {
          // Set _isRunning to false when the command finishes
          if (mounted) {
            setState(() => _isRunning = false);
          }
        });
      } else {
        // Update UI with error message if file is not audio/video
        if (mounted) {
          setState(() {
            _outputController.text =
                'Input file does not look like an audio or video file, '
                'please check the input file type.';
          });
        }
      }
    }
  }

  Future<void> runExternalCommand(String filePath, WidgetRef ref) async {
    if (isProcessRunning) {
      return; // Prevent a new process if one is already running
    }
    isProcessRunning = true; // Mark that a process is now running
    _cancelled = false; // Reset the cancellation flag
    try {
      // Escape spaces in the filePath

      String escapedFilePath = filePath.replaceAll(' ', '\\ ');

      // When selectedFormat is txt, do not add argument '-f txt'
      // because default ml command without '-f' specified will output text
      // one sentence per line which is more desired than whisper txt format.

      String formatCommand =
          selectedFormat == 'txt' ? '' : '-f $selectedFormat';

      String languageCommand = (selectedInputLanguage != null &&
              selectedInputLanguage != 'Not specified')
          ? '-l $selectedInputLanguage'
          : '';

      String operation = widget.processType == ProcessType.transcribe
          ? 'transcribe'
          : 'translate';

      var command =
          'ml $operation openai "$escapedFilePath" $languageCommand $formatCommand';

      // TODO 20240622 gjw ON OLIVE STARTING FROM GNOME SHELL PATH DOES NOT
      // INCLUDE ~/.local/bin` WHERE ml IS INSTALLED. ON KADESH IT
      // DOES. STARTING FROM TERMINAL ALL IS OKAY BECAUSE THE PATH IS SETUP
      // OKAY. HOW TO HANDLE THIS?

      // var command = 'printenv PATH';

      _runningProcess = await Process.start(
        '/bin/sh',
        ['-c', command],
        runInShell: true,
      );

      debugPrint('Command: $command');
      updateLog(ref, 'Command executed:\n$command', includeTimestamp: true);

      // Capture the stdout and trim it to remove leading/trailing whitespace.

      // TODO 20240622 gjw DO WE ALSO NEED TO BE COLLECTING stderr OUTPUT TO
      // REPORT AN ERROR. ALSO NOTING THE COMMENT IN
      // https://api.flutter.dev/flutter/dart-io/Process/start.html STATING "Users
      // must read all data coming on the stdout and stderr streams of processes
      // started with Process.start. If the user does not read all data on the
      // streams the underlying system resources will not be released since there
      // is still pending data."

      String completeOutput = '';

      await for (var output
          in _runningProcess!.stdout.transform(utf8.decoder)) {
        if (_cancelled) break; // Stop processing if cancelled
        completeOutput += output;
      }

      // TODO 20240622 gjw CAN WE ALSO CAPTURE THE

      if (_cancelled) return;

      if (mounted) {
        setState(() {
          _outputController.text = completeOutput.trim();
        });
      }

      debugPrint(completeOutput.trim());
      updateLog(ref, 'Output:\n$completeOutput');
    } catch (e) {
      if (mounted) {
        setState(() => _outputController.text = 'Error: $e');
      }
      debugPrint('An error occurred while running the process: $e');
    } finally {
      // Ensure _runningProcess is cleared and mark that no process is running
      _runningProcess = null;
      isProcessRunning = false;
    }
  }

  Widget buildOverlay(WidgetRef ref) {
    return Positioned.fill(
      child: Container(
        color: Colors.white60, // Semi-transparent overlay
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text(
              'Processing...',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => cancelOperation(
                ref,
              ), // Implement this method to handle cancel
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void cancelOperation(WidgetRef ref) {
    if (_runningProcess != null) {
      _cancelled = true; // Set the cancellation flag
      _runningProcess!.kill(ProcessSignal.sigint);

      // Wait for the process to terminate
      _runningProcess!.exitCode.then((_) {
        if (mounted) {
          setState(() {
            // Reset the UI and flags only after the process has actually terminated
            _isRunning = false;
            isProcessRunning = false;
            _outputController.text = 'Operation cancelled.';
            _runningProcess = null;
          });
          debugPrint('Process successfully cancelled.');
          updateLog(ref, 'Operation cancelled.');
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _outputController.text = 'Error cancelling the operation: $error';
            // Ensure flags are reset even if there's an error
            _isRunning = false;
            isProcessRunning = false;
            _runningProcess = null;
          });
        }
      });
    }
  }
}
