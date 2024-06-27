library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path_lib;

import 'package:mlflutter/constants/language_constants.dart';
import 'package:mlflutter/features/log/log_panel.dart';
import 'package:mlflutter/utils/save_file.dart';
import 'package:mlflutter/widgets/language_selection.dart';
import 'package:mlflutter/widgets/item_selection.dart';
import 'package:mlflutter/widgets/file_drop.dart';
import 'package:mlflutter/widgets/processing_overlay.dart';

class LanguageProcessPage extends StatefulWidget {
  final ProcessType processType;

  const LanguageProcessPage({super.key, required this.processType});

  @override
  LanguageProcessPageState createState() => LanguageProcessPageState();
}

class LanguageProcessPageState extends State<LanguageProcessPage> {
  bool _isRunning = false; // Track whether the command is running
  bool _cancelled = false; // Track whether the command is cancelled
  Process? _runningProcess; // Control the process running
  String dropAreaText = '';
  List<XFile> droppedFiles = []; // Store the paths of dropped files
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

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Consumer(
          builder: (context, ref, child) {
            return Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: buildMainContent(
                    ref,
                  ), // Apply padding only to main content
                ),
                if (_isRunning)
                  ProcessingOverlay(
                    onCancel: () => cancelOperation(ref),
                  ), // Present a processing page
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
        const Text('Models available:', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 8.0),
        SelectionButtons(
          selectedItem: selectedModel,
          onItemSelected: (model) => setState(() => selectedModel = model),
          items: models,
        ),
        const SizedBox(height: 16.0),
        const Text('Output format:', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 8.0),
        SelectionButtons(
          selectedItem: selectedFormat,
          onItemSelected: (format) => setState(() => selectedFormat = format),
          items: formats,
        ),
        const SizedBox(height: 16.0),
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
                backgroundColor:
                    droppedFiles.isNotEmpty ? null : Colors.grey,
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
          onFilesDropped: (files) {
            setState(() {
              droppedFiles.clear();
              if (files.isNotEmpty) {
                droppedFiles.add(files.last); // Add only the most recent file
              }
              dropAreaText =
                  'Selected file:\n${droppedFiles.map((file) => file.path).join('\n')}';
            });
          },
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

  void _runOrNot(WidgetRef ref) {
    if (!_isRunning) {
      var mimeType = lookupMimeType(droppedFiles.first.path);
      if (mimeType != null &&
          (mimeType.startsWith('audio/') || mimeType.startsWith('video/'))) {
        setState(() => _isRunning = true);
        runExternalCommand(droppedFiles.first.path, ref).then((_) {
          if (mounted) {
            setState(() => _isRunning = false);
          }
        });
      } else {
        if (mounted) {
          setState(() {
            _outputController.text =
                "Input file doesn't look like an audio or video file, please check the input file type.";
          });
        }
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
          dropAreaText =
              'Selected file:\n${droppedFiles.map((file) => file.path).join('\n')}';
        });
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

      _runningProcess = await Process.start(
        '/bin/sh',
        ['-c', command],
        runInShell: true,
      );
      debugPrint('Command: $command');
      updateLog(ref, 'Command executed:\n$command', includeTimestamp: true);

      // Capture the stdout and trim it to remove leading/trailing whitespace.
      String completeOutput = '';
      await for (var output
          in _runningProcess!.stdout.transform(utf8.decoder)) {
        if (_cancelled) break; // Stop processing if cancelled
        completeOutput += output;
      }
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
      isProcessRunning = false;
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
            _isRunning = false;
            isProcessRunning = false;
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
            _isRunning = false;
            isProcessRunning = false;
            _runningProcess = null;
          });
        }
      });
    }
  }
}
