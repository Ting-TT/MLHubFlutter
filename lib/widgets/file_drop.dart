import 'package:flutter/material.dart';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';

class FileDropTarget extends StatelessWidget {
  final List<XFile> droppedFiles;
  final ValueChanged<List<XFile>> onFilesDropped;

  const FileDropTarget({
    super.key,
    required this.droppedFiles,
    required this.onFilesDropped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
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
          child: droppedFiles.isEmpty
              ? const Text(
                  'Drag and drop area',
                  style: TextStyle(color: Colors.grey),
                )
              : Text(
                  'Selected file:\n${droppedFiles.map((file) => file.path).join('\n')}',
                ),
        ),
      ),
    );
  }
}
