/// LLM Chat tool using Ollama
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
/// Authors: Graham Williams

library;

import 'package:flutter/material.dart';

import 'package:mlflutter/constants/language.dart';
import 'package:mlflutter/features/language/process.dart';

// TODO 20240914 IMPLEMET THE OLLAMA GUI
//
// Choice of models: ollama3 codellama ....
//
// Text field to type in a prompt
//
// A RUN button
//
// A texfield to show the output as it is being generated
//
// Commands are `ollama run codellama` which then prompts for the prompt. On
// ENTER it starts generating the output. Perhaps use pty/xterm to show the
// output.
//
// INSTALL
//
// If ollama is not found as a command, then suggest `sudo snap install ollama`
// or the equivalent on your OS.
//
// On furst run it takes a while to download the model (> 3GB).
//
// EXAMPLE
//
// >>> In flutter I want a popup to display when a file does not exist
//
// To display a popup in Flutter when a file does not exist, you can use the `showDialog` function from the `material.dart` library and pass in a custom dialog
// widget as an argument. Here's an example:
// ```
// import 'package:flutter/material.dart';
//
// class MyWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('My Widget')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             final file = File('path/to/file.txt');
//             if (!await file.exists()) {
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) => AlertDialog(
//                   title: Text('Error'),
//                   content: Text('File not found'),
//                   actions: [
//                     FlatButton(
//                       child: Text('Ok'),
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             } else {
//               // Do something with the file
//             }
//           },
//
// >>>

class Ollama extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: const LanguageProcess(processType: ProcessType.transcribe),
      ),
    );
  }
}
