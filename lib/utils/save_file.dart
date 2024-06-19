/// Save content from MLFlutter to a file.
///
/// Copyright (C) 2024 Authors
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

import 'package:file_picker/file_picker.dart';

/// Saves content to a file with a dialog for choosing the location.
///
/// [content] is the content to be saved.
/// [defaultFileName] is the suggested filename shown in the save dialog, which includes the file extension.
/// [initialDirectory] optionally specifies the initial directory in the file picker.
///
/// Returns a Future<String> that provides a message about the success or failure of the save operation.
Future<String> saveToFile({
  required String content,
  required String defaultFileName,
  String? initialDirectory,
}) async {
  if (content.isEmpty) {
    return 'No content to save. Please ensure there is content before saving.';
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
