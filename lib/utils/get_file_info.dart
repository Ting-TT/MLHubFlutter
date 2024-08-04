/// Get the file information like file size, audio/video length etc.
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

import 'dart:async';
import 'package:cross_file/cross_file.dart';
import 'package:mime/mime.dart';
import 'dart:io';

Future<String> getFileInfo(XFile file) async {
  String fileInfo = '';
  String duration = '';
  final mimeType = lookupMimeType(file.path);

  // Calculate file size
  final fileSize = await file.length();
  String fileSizeStr;
  if (fileSize < 1024) {
    fileSizeStr = '$fileSize bytes';
  } else if (fileSize < 1024 * 1024) {
    fileSizeStr = '${(fileSize / 1024).toStringAsFixed(2)} KB';
  } else {
    fileSizeStr = '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  // Get duration for audio and video files
  if (mimeType != null &&
      (mimeType.startsWith('audio/') || mimeType.startsWith('video/'))) {
    try {
      final result = await Process.run('ffmpeg', ['-i', file.path]);

      // Extract duration from ffmpeg output
      final durationRegExp = RegExp(r'Duration: (\d{2}):(\d{2}):(\d{2})');
      final match = durationRegExp.firstMatch(result.stderr as String);
      if (match != null) {
        final hours = int.parse(match.group(1)!);
        final minutes = int.parse(match.group(2)!);
        final seconds = int.parse(match.group(3)!);

        if (hours > 0) {
          duration = '$hours h $minutes min $seconds sec';
        } else if (minutes > 0) {
          duration = '$minutes min $seconds sec';
        } else {
          duration = '$seconds sec';
        }
      }
    } catch (e) {
      return 'Error getting duration: $e';
    }
  }

  fileInfo = 'File size: $fileSizeStr';
  if (duration.isNotEmpty) {
    fileInfo += '\nDuration: $duration';
  }

  return fileInfo;
}
