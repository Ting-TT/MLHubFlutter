/// The layout for processing language tasks which can be used for both
/// transcribe page and translate page.
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

// Group imports by dart, flutter, packages, local. Then alphabetically.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path_lib;

import 'package:mlflutter/constants/language_constants.dart';
import 'package:mlflutter/features/log.dart';
import 'package:mlflutter/utils/get_file_info.dart';
import 'package:mlflutter/utils/save_file.dart';
import 'package:mlflutter/widgets/language_selection.dart';
import 'package:mlflutter/widgets/item_selection.dart';
import 'package:mlflutter/widgets/file_drop.dart';
import 'package:mlflutter/widgets/processing_overlay.dart';

class LanguageProcess extends StatefulWidget {
  final ProcessType processType;

  const LanguageProcess({super.key, required this.processType});

  @override
  LanguageProcessState createState() => LanguageProcessState();
}

class LanguageProcessState extends State<LanguageProcess> {
  bool _isProcessing =
      false; // Track whether ml command is running, so whether to display the processing overlay
  bool _cancelled = false; // Track whether the command is cancelled
  Process? _runningProcess; // Control the process running
  bool _isProcessRunning = false; //  Track whether a process is running
  String dropAreaText =
      'Drag and drop area'; // Text to display in the drop area
  List<XFile> droppedFiles = []; // Store the paths of dropped files
  String fileInfo = ''; // Store the file information
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
    // Dispose of the controller when the widget is disposed
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Consumer(
          builder: (context, ref, child) {
            return Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child:
                      // Apply padding only to main content
                      buildMainContent(ref),
                ),
                // Present a processing page as the ml command is running
                if (_isProcessing)
                  ProcessingOverlay(onCancel: () => cancelOperation(ref)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildMainContent(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Models available.
        const Text('Models available:', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 8.0),
        SelectionButtons(
          selectedItem: selectedModel,
          onItemSelected: (model) => setState(() => selectedModel = model),
          items: models,
        ),

        // Output format options.
        const SizedBox(height: 16.0),
        const Text('Output format:', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 8.0),
        SelectionButtons(
          selectedItem: selectedFormat,
          onItemSelected: (format) => setState(() => selectedFormat = format),
          items: formats,
        ),
        const SizedBox(height: 16.0),

        // Language options.
        Row(
          children: <Widget>[
            Expanded(
              child: InputLanguageDropdown(
                selectedInputLanguage: selectedInputLanguage,
                onChanged: (value) {
                  setState(() => selectedInputLanguage = value);
                },
              ),
            ),
            if (widget.processType == ProcessType.translate) ...[
              const SizedBox(width: 20.0),
              Expanded(
                child: OutputLanguageDropdown(
                  selectedOutputLanguage: selectedOutputLanguage,
                  onChanged: (value) {
                    setState(() => selectedOutputLanguage = value);
                  },
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20.0),

        // File uploading and processing area.
        Row(
          children: [
            const Text('Drop your file here:', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10.0),
            ElevatedButton(
              onPressed: _pickFile,
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Choose File'),
            ),
            const SizedBox(width: 10.0),
            ElevatedButton(
              onPressed: droppedFiles.isNotEmpty ? () => _runOrNot(ref) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: droppedFiles.isNotEmpty ? null : Colors.grey,
                foregroundColor:
                    droppedFiles.isNotEmpty ? null : Colors.black45,
              ),
              child: const Text('Run'),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        FileDropTarget(
          droppedFiles: droppedFiles,
          onFilesDropped: (files) async {
            setState(() {
              droppedFiles.clear();
              if (files.isNotEmpty) {
                droppedFiles.add(files.last); // Add only the most recent file
              }
            });
            fileInfo = await getFileInfo(files.last);
            setState(() {
              dropAreaText =
                  'Selected file:\n${droppedFiles.last.path}\n$fileInfo';
            });
          },
          dropAreaText: dropAreaText,
        ),
        const SizedBox(height: 16.0),

        // Output display and save-to-file button.
        Row(
          children: [
            const Text('Output:', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10.0),
            ElevatedButton(
              onPressed: _outputController.text.isNotEmpty
                  ? () async {
                      String defaultFileName =
                          '${path_lib.basenameWithoutExtension(droppedFiles.first.path)}.$selectedFormat';
                      String initialDirectory =
                          path_lib.dirname(droppedFiles.first.path);
                      String result = await saveToFile(
                        content: _outputController.text,
                        defaultFileName: defaultFileName,
                        initialDirectory: initialDirectory,
                      );
                      if (mounted) {
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

  // Check the input file type and run the command if it's an audio or video file
  void _runOrNot(WidgetRef ref) {
    var mimeType = lookupMimeType(droppedFiles.first.path);
    if (mimeType != null &&
        (mimeType.startsWith('audio/') || mimeType.startsWith('video/'))) {
      setState(() => _isProcessing = true);
      runExternalCommand(droppedFiles.first.path, ref).then((_) {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      });
    } else {
      if (mounted) {
        setState(() {
          _outputController.text =
              'Input file does not look like an audio or video file, '
              'please check the input file type.';
        });
      }
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      if (mounted) {
        setState(() {
          droppedFiles.clear(); // Clear previous files
          droppedFiles.add(XFile(result.files.single.path!));
        });
      }
      fileInfo = await getFileInfo(droppedFiles.last);
      if (mounted) {
        setState(() {
          dropAreaText = 'Selected file:\n${droppedFiles.last.path}\n$fileInfo';
        });
      }
    }
  }

  Future<void> runExternalCommand(String filePath, WidgetRef ref) async {
    if (_isProcessRunning) {
      return; // Prevent a new process if one is already running
    }
    _isProcessRunning = true; // Mark that a process is now running
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
    } finally {
      // Ensure _runningProcess is cleared and mark that no process is running
      _runningProcess = null;
      _isProcessRunning = false;
    }
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
            _isProcessing = false;
            _isProcessRunning = false;
            _outputController.text = 'Operation cancelled.';
            _runningProcess = null;
          });
          updateLog(ref, 'Operation cancelled.');
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _outputController.text = 'Error cancelling the operation: $error';
            // Ensure flags are reset even if there's an error
            _isProcessing = false;
            _isProcessRunning = false;
            _runningProcess = null;
          });
        }
      });
    }
  }
}
