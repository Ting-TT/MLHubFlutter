/// File Drop Area Widget which allows users to drag and drop files.
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

import 'package:flutter/material.dart';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';

class FileDropTarget extends StatelessWidget {
  final double height;
  final List<XFile> droppedFiles;
  final ValueChanged<List<XFile>> onFilesDropped;
  final String dropAreaText;

  const FileDropTarget({
    super.key,
    required this.height,
    required this.droppedFiles,
    required this.onFilesDropped,
    required this.dropAreaText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(4.0),
        color: Colors.grey[200],
      ),
      child: DropTarget(
        onDragDone: (detail) {
          if (detail.files.isNotEmpty) {
            onFilesDropped(detail.files);
          }
        },
        child: Center(
          child: SelectableText(
            dropAreaText,
            style: droppedFiles.isEmpty
                ? const TextStyle(color: Colors.grey)
                : null,
          ),
        ),
      ),
    );
  }
}
