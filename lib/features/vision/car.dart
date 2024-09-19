/// Identify the make and model of the car from car images.
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
/// Authors: Ting Tang

library;

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mlflutter/features/log.dart';
import 'package:mlflutter/providers/car.dart';
import 'package:mlflutter/utils/check_image.dart';
import 'package:mlflutter/widgets/conditional_button.dart';
import 'package:mlflutter/widgets/processing_overlay.dart';

class CarIdentification extends ConsumerStatefulWidget {
  const CarIdentification({super.key});

  @override
  CarIdentificationProcessState createState() =>
      CarIdentificationProcessState();
}

class CarIdentificationProcessState extends ConsumerState<CarIdentification> {
  bool _isProcessing = false;
  bool _cancelled = false;
  bool urlValid = true;
  Process? _runningProcess;
  final TextEditingController _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final carIdentificationState = ref.watch(carIdentificationStateProvider);
    final notifier = ref.read(carIdentificationStateProvider.notifier);

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildMainContent(carIdentificationState, notifier),
            ),
            if (_isProcessing)
              ProcessingOverlay(onCancel: () => _cancelProcess(notifier)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
    CarIdentificationState carIdentificationState,
    CarIdentificationNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Identify the "make" and "model" of a car from a local image or an internet photo:',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16.0),
        // Use Row to align the button and the URL input field on the same row
        Row(
          children: [
            Expanded(flex: 0, child: buildFilePicker(notifier)),
            const SizedBox(width: 20),
            Expanded(flex: 1, child: buildUrlInput(notifier)),
          ],
        ),
        const SizedBox(height: 8.0),
        if (carIdentificationState.selectedInputPath != null &&
            carIdentificationState.selectedInputPath!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SelectableText(
              'Selected: ${carIdentificationState.selectedInputPath}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        const SizedBox(height: 20.0),
        Row(
          children: [
            ConditionalButton(
              onPressed: carIdentificationState.selectedInputPath != null &&
                      carIdentificationState.selectedInputPath!.isNotEmpty
                  ? () =>
                      _runCarIdentification(carIdentificationState, notifier)
                  : null,
              text: 'Identify Car',
              isEnabled: carIdentificationState.selectedInputPath != null &&
                  carIdentificationState.selectedInputPath!.isNotEmpty,
            ),
          ],
        ),
        const SizedBox(height: 20.0),
        buildImageDisplay(carIdentificationState),
        const SizedBox(height: 16.0),
        if (carIdentificationState.errorOccurred &&
            carIdentificationState.outputMessage.isNotEmpty)
          SelectableText(
            'Error:\n${carIdentificationState.outputMessage}',
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
        if (!carIdentificationState.errorOccurred &&
            carIdentificationState.outputMessage.isNotEmpty) ...[
          SelectableText(
            carIdentificationState.outputMessage,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }

  Widget buildFilePicker(CarIdentificationNotifier notifier) {
    return ElevatedButton(
      onPressed: () => _pickFile(notifier),
      child: const Text('Choose Photo'),
    );
  }

  Widget buildUrlInput(CarIdentificationNotifier notifier) {
    return TextField(
      controller: _urlController,
      decoration: const InputDecoration(
        hintText: 'URL of the car photo on the internet',
        hintStyle: TextStyle(fontSize: 15),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
      ),
      onChanged: (url) {
        setState(() {
          notifier.updateInputPath(url.trim(), 'URL');
          notifier.updateOutputMessage('');
          urlValid = true;
        });
      },
    );
  }

  Widget buildImageDisplay(CarIdentificationState carIdentificationState) {
    if (carIdentificationState.selectedType == 'File' &&
        carIdentificationState.selectedInputPath != null &&
        isFileImage(carIdentificationState.selectedInputPath!)) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Image.file(
          File(carIdentificationState.selectedInputPath!),
          fit: BoxFit.fitHeight,
          height: 170,
          errorBuilder: (context, error, stackTrace) {
            return const Text('Could not load image.');
          },
        ),
      );
    } else if (carIdentificationState.selectedType == 'URL' &&
        carIdentificationState.selectedInputPath != null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Image.network(
          carIdentificationState.selectedInputPath!,
          fit: BoxFit.fitHeight,
          height: 170,
          errorBuilder: (context, error, stackTrace) {
            urlValid = false;

            return const Text('Could not load image.');
          },
        ),
      );
    } else {
      return const SizedBox(); // No image to display
    }
  }

  Future<void> _pickFile(CarIdentificationNotifier notifier) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        notifier.updateInputPath(result.files.single.path!, 'File');
        notifier.updateOutputMessage('');
      });
    }
  }

  String _formatOutputMessage(
    String message,
    CarIdentificationNotifier notifier,
  ) {
    List<String> parts = message.split(',');
    if (parts.length == 3) {
      return '${parts.first}, ${parts[1]}'; // Only return the make and model
    } else {
      notifier.updateErrorOccurred(true);

      return message;
    }
  }

  Future<void> _runCarIdentification(
    CarIdentificationState carIdentificationState,
    CarIdentificationNotifier notifier,
  ) async {
    if (_isProcessing) return;
    if (carIdentificationState.selectedType == 'File' &&
        !isFileImage(carIdentificationState.selectedInputPath!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image file.'),
        ),
      );

      return;
    }

    if (carIdentificationState.selectedType == 'URL' && !urlValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a valid URL of an image.'),
        ),
      );

      return;
    }

    notifier.updateErrorOccurred(false);
    setState(() {
      _isProcessing = true;
    });

    try {
      _urlController.clear();
      String? escapedFilePath =
          carIdentificationState.selectedInputPath?.replaceAll(' ', '\\ ');
      String command = 'ml identify cars "$escapedFilePath"';

      // Start the process
      _runningProcess = await Process.start('/bin/sh', ['-c', command]);
      debugPrint('Running command: $command');
      updateLog(ref, 'Command executed:\n$command', includeTimestamp: true);

      // Capture the output streams
      String output = '';
      String errorOutput = '';

      _runningProcess!.stdout
          .transform(const SystemEncoding().decoder)
          .listen((data) {
        output += data;
      });

      _runningProcess!.stderr
          .transform(const SystemEncoding().decoder)
          .listen((data) {
        errorOutput += data;
      });

      // Wait for the process to finish
      await _runningProcess!.exitCode;

      if (_cancelled) {
        _cancelled = false;

        return;
      }

      if (exitCode != 0 || errorOutput.isNotEmpty) {
        notifier.updateErrorOccurred(true);
        notifier.updateOutputMessage(
          errorOutput.isNotEmpty ? errorOutput : 'An unknown error occurred.',
        );
        updateLog(ref, 'Error occurred:\n$errorOutput');
        debugPrint('Error occurred:\n$errorOutput');
      } else {
        output = _formatOutputMessage(output, notifier);
        notifier.updateOutputMessage(output);
        updateLog(ref, 'Output:\n$output');
        debugPrint('Output:\n$output');
      }
    } catch (e) {
      notifier.updateErrorOccurred(true);
      notifier.updateOutputMessage('An unexpected error occurred: $e');
    } finally {
      _runningProcess = null;
      setState(() => _isProcessing = false);
    }
  }

  void _cancelProcess(CarIdentificationNotifier notifier) {
    if (_runningProcess != null) {
      _runningProcess!.kill();
      setState(() {
        _isProcessing = false;
        _runningProcess = null;
        _cancelled = true;
      });
      updateLog(ref, 'Operation cancelled.');
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
