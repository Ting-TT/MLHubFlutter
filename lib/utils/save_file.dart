import 'dart:io';
import 'package:file_picker/file_picker.dart';

/// Saves content to a file with a dialog for choosing the location.
/// 
/// [content] is the content to be saved.
/// [defaultFileName] is the suggested filename shown in the save dialog, which includes the file extension.
/// [initialDirectory] optionally specifies the initial directory in the file picker.
/// Returns a Future<String> that provides a message about the success or failure of the save operation.
Future<String> saveToFile({
  required String content,
  required String defaultFileName,
  String? initialDirectory,
}) async {
  if (content.isEmpty) {
    return 'No output to save.';
  }

  String? path = await FilePicker.platform.saveFile(
    dialogTitle: 'Save your file',
    fileName: defaultFileName,
    initialDirectory: initialDirectory,
  );

  if (path != null) {
    File file = File(path);
    try {
      await file.writeAsString(content);
      return 'File saved successfully to $path';
    } catch (e) {
      return 'Failed to save file: $e';
    }
  } else {
    return 'File save cancelled or failed.';
  }
}
