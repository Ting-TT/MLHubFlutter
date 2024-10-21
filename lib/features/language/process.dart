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

import 'package:mlflutter/constants/language.dart';
import 'package:mlflutter/features/log.dart';
import 'package:mlflutter/providers/language.dart';
import 'package:mlflutter/utils/get_file_info.dart';
import 'package:mlflutter/utils/save_file.dart';
import 'package:mlflutter/widgets/conditional_button.dart';
import 'package:mlflutter/widgets/language_selection.dart';
import 'package:mlflutter/widgets/item_selection.dart';
import 'package:mlflutter/widgets/file_drop.dart';
import 'package:mlflutter/widgets/processing_overlay.dart';

class LanguageProcess extends ConsumerStatefulWidget {
  final ProcessType processType;

  const LanguageProcess({super.key, required this.processType});

  @override
  LanguageProcessState createState() => LanguageProcessState();
}

class LanguageProcessState extends ConsumerState<LanguageProcess> {
  bool _isProcessing =
      false; // Track whether ml command is running, so whether to display the processing overlay
  bool _cancelled = false; // Track whether the command is cancelled
  Process? _runningProcess; // Control the process running
  bool _isProcessRunning = false; //  Track whether a process is running
  String fileInfo = ''; // Store the file information
  final TextEditingController _outputController = TextEditingController();
  late StateProvider<LanguageState> stateProvider;

  @override
  void initState() {
    super.initState();
    switch (widget.processType) {
      case ProcessType.transcribe:
        stateProvider = transcribeStateProvider;
      case ProcessType.translate:
        stateProvider = translateStateProvider;
      case ProcessType.identify:
        stateProvider = identifyStateProvider;
    }
  }

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
    final state = ref.watch(stateProvider);

    // Sync the controller with the state's outputText
    _outputController.text = state.outputText;

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
                      buildMainContent(ref, state),
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

  Widget buildMainContent(WidgetRef ref, LanguageState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Models available.
        const Text('Models available:', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 8.0),
        SelectionButtons(
          selectedItem: state.selectedModel,
          onItemSelected: (model) {
            ref
                .read(stateProvider.notifier)
                .update((state) => state.copyWith(selectedModel: model));
          },
          items: models,
        ),
        const SizedBox(height: 16.0),

        // Output Format options and Language options for transcribe/translate.
        if (widget.processType != ProcessType.identify) ...[
          // Output Format options.
          const Text('Output format:', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8.0),
          SelectionButtons(
            selectedItem: state.selectedFormat,
            onItemSelected: (format) {
              ref
                  .read(stateProvider.notifier)
                  .update((state) => state.copyWith(selectedFormat: format));
            },
            items: formats,
          ),
          const SizedBox(height: 16.0),

          // Language options.
          buildLanguageSelection(ref, state),
          const SizedBox(height: 20.0),
        ],

        // File uploading and processing area.
        buildFileUploadAndRunButtons(ref, state),
        const SizedBox(height: 8.0),
        FileDropTarget(
          height: widget.processType == ProcessType.identify ? 200.0 : 100.0,
          droppedFiles: state.droppedFiles,
          onFilesDropped: (files) async {
            fileInfo = await getFileInfo(files.last);
            ref.read(stateProvider.notifier).update(
                  (state) => state.copyWith(
                    droppedFiles: [files.last],
                    dropAreaText:
                        'Selected file:\n${(files.last).path}\n$fileInfo',
                    outputText: '',
                  ),
                );
          },
          dropAreaText: state.dropAreaText,
        ),
        const SizedBox(height: 16.0),

        // Output display and save-to-file button.
        buildOutputLabelAndSaveButton(state),
        const SizedBox(height: 8.0),
        buildOutputDisplayBox(),
      ],
    );
  }

  Widget buildLanguageSelection(WidgetRef ref, LanguageState state) {
    return Row(
      children: <Widget>[
        Expanded(
          child: InputLanguageDropdown(
            selectedInputLanguage: state.selectedInputLanguage,
            onChanged: (value) {
              ref.read(stateProvider.notifier).update(
                    (state) => state.copyWith(selectedInputLanguage: value),
                  );
            },
          ),
        ),
        if (widget.processType == ProcessType.translate) ...[
          const SizedBox(width: 20.0),
          Expanded(
            child: OutputLanguageDropdown(
              selectedOutputLanguage: state.selectedOutputLanguage,
              onChanged: (value) {
                ref.read(stateProvider.notifier).update(
                      (state) => state.copyWith(selectedOutputLanguage: value),
                    );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget buildFileUploadAndRunButtons(WidgetRef ref, LanguageState state) {
    return Row(
      children: [
        const Text('Drop your file here:', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 10.0),
        ElevatedButton(
          onPressed: _pickFile,
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text('Choose File'),
        ),
        const SizedBox(width: 10.0),
        ConditionalButton(
          onPressed: state.droppedFiles.isNotEmpty
              ? () => _runOrNot(ref, state)
              : null,
          text: 'Run',
          isEnabled: state.droppedFiles.isNotEmpty,
        ),
      ],
    );
  }

  Widget buildOutputLabelAndSaveButton(LanguageState state) {
    return Row(
      children: [
        const Text('Output:', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 10.0),
        ConditionalButton(
          onPressed: _outputController.text.isNotEmpty
              ? () async {
                  String defaultFileName =
                      '${path_lib.basenameWithoutExtension(state.droppedFiles.first.path)}.${state.selectedFormat}';
                  String initialDirectory =
                      path_lib.dirname(state.droppedFiles.first.path);
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
          text: 'Save',
          isEnabled: _outputController.text.isNotEmpty,
        ),
      ],
    );
  }

  Widget buildOutputDisplayBox() {
    return Expanded(
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
    );
  }

  // Check the input file type and run the command if it's an audio or video file
  void _runOrNot(WidgetRef ref, LanguageState state) {
    var mimeType = lookupMimeType(state.droppedFiles.first.path);
    if (mimeType != null &&
        (mimeType.startsWith('audio/') || mimeType.startsWith('video/'))) {
      setState(() => _isProcessing = true);
      runExternalCommand(state.droppedFiles.first.path, ref, state).then((_) {
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
        ref.read(stateProvider.notifier).update(
              (state) => state.copyWith(outputText: _outputController.text),
            );
      }
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      fileInfo = await getFileInfo(XFile(result.files.single.path!));
      if (mounted) {
        ref.read(stateProvider.notifier).update(
              (state) => state.copyWith(
                droppedFiles: [XFile(result.files.single.path!)],
                dropAreaText:
                    'Selected file:\n${XFile(result.files.single.path!).path}\n$fileInfo',
                outputText: '',
              ),
            );
      }
    }
  }

  Future<void> runExternalCommand(
    String filePath,
    WidgetRef ref,
    LanguageState state,
  ) async {
    if (_isProcessRunning) {
      return; // Prevent a new process if one is already running
    }
    _isProcessRunning = true; // Mark that a process is now running
    _cancelled = false; // Reset the cancellation flag
    try {
      // Escape spaces in the filePath
      String escapedFilePath = filePath.replaceAll(' ', '\\ ');

      String command;
      switch (widget.processType) {
        case ProcessType.transcribe:
        case ProcessType.translate:
          // When selectedFormat is txt, do not add argument '-f txt'
          // because default ml command without '-f' specified will output text
          // one sentence per line which is more desired than whisper txt format.
          String format = state.selectedFormat;
          String formatCommand = format == 'txt' ? '' : '-f $format';

          String? language = state.selectedInputLanguage;
          String languageCommand =
              (language != null && language != 'Not specified')
                  ? '-l $language'
                  : '';

          String operation = widget.processType == ProcessType.transcribe
              ? 'transcribe'
              : 'translate';

          command =
              'ml $operation openai "$escapedFilePath" $languageCommand $formatCommand';

        case ProcessType.identify:
          command = 'ml identify openai "$escapedFilePath"';
      }

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
        ref.read(stateProvider.notifier).update(
              (state) => state.copyWith(outputText: _outputController.text),
            );
      }

      debugPrint(completeOutput.trim());
      updateLog(ref, 'Output:\n$completeOutput');
    } catch (e) {
      if (mounted) {
        setState(() => _outputController.text = 'Error: $e');
        ref.read(stateProvider.notifier).update(
              (state) => state.copyWith(outputText: _outputController.text),
            );
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
          ref.read(stateProvider.notifier).update(
                (state) => state.copyWith(outputText: _outputController.text),
              );
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
          ref.read(stateProvider.notifier).update(
                (state) => state.copyWith(outputText: _outputController.text),
              );
        }
      });
    }
  }
}
