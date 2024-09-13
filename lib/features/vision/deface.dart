/// Identify the brand of the car from car images.
///
/// Copyright (C) 2024 Togaware Pty Ltd
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

library;

// import 'package:flutter/material.dart';

// class Deface extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         color: Theme.of(context).colorScheme.primaryContainer,
//         child: Center(
//           child: Column(
//             children: [
//               const Text('Deface Images - Not Yet Implemented'),
//               const SizedBox(height: 100), // Add space between Text and Image
//               Image.network(
//                 'https://linuxtldr.com/wp-content/uploads/2024/02/Defacing-faces-with-blur-effect.webp', // Replace with your image URL
//                 width: 500, // Adjust width and height
//                 //height: 300,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import 'package:mlflutter/features/log.dart';
import 'package:mlflutter/providers/deface.dart.~3~';
import 'package:mlflutter/utils/check_image.dart';
import 'package:mlflutter/widgets/processing_overlay.dart';

class Deface extends ConsumerStatefulWidget {
  const Deface({super.key});

  @override
  DefaceProcessState createState() => DefaceProcessState();
}

class DefaceProcessState extends ConsumerState<Deface> {
  bool _isProcessing = false;
  bool _cancelled = false;
  bool errorOccurred = false;
  bool urlValid = true; // Flag to check if the URL image is valid
  Process? _runningProcess; // Store the running process
  String? outputImagePath; // For displaying the output image
  List<File>? inputImages; // List for display when input is a folder
  List<File>? outputImages; // List for display when input is a folder
  String? outputMessage;
  final TextEditingController _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final defaceState = ref.watch(defaceStateProvider);
    final notifier = ref.read(defaceStateProvider.notifier);

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildMainContent(defaceState, notifier),
            ),
            if (_isProcessing)
              ProcessingOverlay(onCancel: () => _cancelProcess(notifier)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
    DefaceState defaceState,
    DefaceNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Deface to your local photos, a folder of photos, or a photo on the internet:',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16.0),
        buildFileOrFolderPickers(notifier),
        const SizedBox(height: 16.0),
        buildUrlInput(notifier),
        const SizedBox(height: 5.0),
        if (defaceState.selectedInputPath != null &&
            defaceState.selectedInputPath!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SelectableText(
              'Selected: ${defaceState.selectedInputPath}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        const SizedBox(height: 14.0),
        buildOutputDirectoryPicker(defaceState, notifier),
        const SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: defaceState.selectedInputPath != null &&
                  defaceState.selectedInputPath!.isNotEmpty
              ? () => _runDeface(defaceState, notifier)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: defaceState.selectedInputPath != null &&
                    defaceState.selectedInputPath!.isNotEmpty
                ? null
                : Colors.grey,
            foregroundColor: defaceState.selectedInputPath != null &&
                    defaceState.selectedInputPath!.isNotEmpty
                ? null
                : Colors.black45,
          ),
          child: const Text('Deface'),
        ),
        const SizedBox(height: 16.0),
        if (errorOccurred && outputMessage != null)
          SelectableText(
            'Error: Defaced images were not generated.\n$outputMessage',
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
        if (!errorOccurred && outputMessage != null) ...[
          SelectableText(
            '$outputMessage',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 10.0),
        ],
        if (!errorOccurred) buildImageDisplay(defaceState),
      ],
    );
  }

  Widget buildFileOrFolderPickers(DefaceNotifier notifier) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => _pickFile(notifier),
          child: const Text('Choose Photo'),
        ),
        const SizedBox(width: 8.0),
        ElevatedButton(
          onPressed: () => _pickFolder(notifier),
          child: const Text('Choose Folder'),
        ),
      ],
    );
  }

  Widget buildUrlInput(DefaceNotifier notifier) {
    return TextField(
      controller: _urlController,
      decoration: const InputDecoration(
        hintText: 'URL of the photo on the internet',
        hintStyle: TextStyle(fontSize: 15),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
      ),
      onChanged: (url) {
        setState(() {
          notifier.updateInputPath(url, 'URL');
          urlValid = true; // Reset the URL validation
          _clearOutput();
        });
      },
    );
  }

  Widget buildOutputDirectoryPicker(
    DefaceState defaceState,
    DefaceNotifier notifier,
  ) {
    return Row(
      children: [
        const Text(
          'Save to:',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            defaceState.selectedOutputDirectory ?? 'No directory selected',
            style: const TextStyle(fontSize: 16.0),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8.0),
        ElevatedButton(
          onPressed: () => _pickOutputDirectory(notifier),
          child: const Text('Select'),
        ),
      ],
    );
  }

  Widget buildImageDisplay(DefaceState defaceState) {
    if (defaceState.selectedType == 'Folder' &&
        inputImages != null &&
        outputImages != null) {
      return Expanded(
        child: ListView.builder(
          itemCount: inputImages!.length,
          itemBuilder: (context, index) {
            return Row(
              children: [
                buildImageColumn('Input Image:', inputImages![index].path),
                const SizedBox(width: 20.0),
                buildImageColumn('Output Image:', outputImages![index].path),
              ],
            );
          },
        ),
      );
    } else if (defaceState.selectedType == 'File' &&
        defaceState.selectedInputPath != null &&
        isFileImage(defaceState.selectedInputPath!)) {
      return Row(
        children: [
          buildImageColumn('Input Image:', defaceState.selectedInputPath),
          const SizedBox(width: 20.0),
          buildImageColumn('Output Image:', outputImagePath),
        ],
      );
    } else if (defaceState.selectedType == 'URL' &&
        defaceState.selectedInputPath != null) {
      return Row(
        children: [
          buildImageColumn(
            'Input Image:',
            defaceState.selectedInputPath,
            isNetwork: true,
          ),
          const SizedBox(width: 20.0),
          buildImageColumn('Output Image:', outputImagePath),
        ],
      );
    } else {
      return const SizedBox(); // No image to display
    }
  }

  Widget buildImageColumn(
    String label,
    String? imagePath, {
    bool isNetwork = false,
  }) {
    bool showLabel = imagePath != null;
    Widget imageWidget;

    imageWidget = isNetwork
        ? Image.network(
            imagePath!,
            fit: BoxFit.fitHeight,
            height: 170,
            errorBuilder: (context, error, stackTrace) {
              urlValid = false; // Mark the URL as invalid if an error occurs

              return const Text('Could not load image.');
            },
          )
        : (imagePath != null
            ? Image.file(
                File(imagePath),
                fit: BoxFit.fitHeight,
                height: 170,
              )
            : const SizedBox()); // Placeholder if no image

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          showLabel ? Text(label) : const SizedBox(),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: imageWidget,
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile(DefaceNotifier notifier) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        notifier.updateInputPath(result.files.single.path!, 'File');
        _clearOutput();
      });
    }
  }

  Future<void> _pickFolder(DefaceNotifier notifier) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        notifier.updateInputPath(selectedDirectory, 'Folder');
        _clearOutput();
      });
    }
  }

  Future<void> _clearOutput() async {
    outputImagePath = null;
    inputImages = null;
    outputImages = null;
    outputMessage = null;
  }

  Future<void> _generateOutputImagePath(
    DefaceState defaceState,
  ) async {
    String inputName = path.basename(defaceState.selectedInputPath!);
    List<String> nameParts = inputName.split('.');
    if (nameParts.length > 1) {
      nameParts[nameParts.length - 2] =
          '${nameParts[nameParts.length - 2]}_anonymized';
      setState(() {
        outputImagePath = path.join(
          defaceState.selectedOutputDirectory ?? Directory.current.path,
          nameParts.join('.'),
        );
      });
    }

    // Validation for file or URL after path generation
    if (outputImagePath == null || !File(outputImagePath!).existsSync()) {
      errorOccurred = true;
      outputMessage =
          'URL or file invalid. Please ensure your input is a valid image.';
    } else {
      outputMessage =
          'Output image(s) successfully saved to: ${defaceState.selectedOutputDirectory}';
    }
  }

  Future<void> _generateListForFolderImages(
    DefaceState defaceState,
  ) async {
    final directory = Directory(defaceState.selectedInputPath!);
    final files = directory
        .listSync()
        .where((file) => file is File && isFileImage(file.path))
        .map((file) => File(file.path))
        .toList();
    inputImages = files;

    outputImages = [];
    for (var file in files) {
      String inputName = path.basename(file.path);
      List<String> nameParts = inputName.split('.');
      if (nameParts.length > 1) {
        nameParts[nameParts.length - 2] =
            '${nameParts[nameParts.length - 2]}_anonymized';
        String outputPath = path.join(
          defaceState.selectedOutputDirectory ?? Directory.current.path,
          nameParts.join('.'),
        );
        outputImages!.add(File(outputPath));
      }
    }

    // Validation for output images after generation
    if (outputImages!.isEmpty ||
        !outputImages!
            .every((outputImage) => File(outputImage.path).existsSync())) {
      errorOccurred = true;
      outputMessage =
          'Please ensure that the selected folder contains only images.';
    } else {
      outputMessage =
          'Output image(s) successfully saved to: ${defaceState.selectedOutputDirectory}';
    }
  }

  Future<void> _pickOutputDirectory(DefaceNotifier notifier) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        notifier.updateOutputDirectory(selectedDirectory);
      });
    }
  }

  Future<void> _runDeface(
    DefaceState defaceState,
    DefaceNotifier notifier,
  ) async {
    if (_isProcessing) return;
    if (defaceState.selectedType == 'File' &&
        !isFileImage(defaceState.selectedInputPath!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image file.'),
        ),
      );

      return;
    }

    if (defaceState.selectedType == 'URL' && !urlValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a valid URL of an image.'),
        ),
      );

      return;
    }

    setState(() {
      _isProcessing = true;
      errorOccurred = false;
    });

    try {
      _urlController.clear();

      if (defaceState.selectedOutputDirectory != null) {
        Directory.current = defaceState.selectedOutputDirectory!;
      }
      debugPrint('Current directory: ${Directory.current.path}');

      String? escapedFilePath =
          defaceState.selectedInputPath?.replaceAll(' ', '\\ ');
      String command = 'deface "$escapedFilePath"';

      // Start the process
      _runningProcess = await Process.start('/bin/sh', ['-c', command]);

      debugPrint('Running command: $command');
      updateLog(ref, 'Command executed:\n$command', includeTimestamp: true);

      // Capture the output streams
      String output = '';
      _runningProcess!.stdout
          .transform(const SystemEncoding().decoder)
          .listen((data) {
        output += data;
      });

      // Wait for the process to finish
      await _runningProcess!.exitCode;

      if (_cancelled) {
        _cancelled = false;

        return;
      }

      updateLog(ref, 'Output:\n$output');
      debugPrint('Output:\n$output');

      // Generate the list or path for displaying images and outputMessage
      if (defaceState.selectedType == 'Folder') {
        await _generateListForFolderImages(defaceState);
      } else {
        await _generateOutputImagePath(defaceState);
      }
    } finally {
      _runningProcess = null; // Reset the running process
      setState(() => _isProcessing = false);
    }
  }

  void _cancelProcess(DefaceNotifier notifier) {
    if (_runningProcess != null) {
      _runningProcess!.kill(); // Terminate the process
      setState(() {
        _isProcessing = false; // Reset the processing state
        _runningProcess = null; // Clear the running process
        _cancelled = true;
      });
      updateLog(ref, 'Operation cancelled.');
      debugPrint('Operation cancelled.');
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
