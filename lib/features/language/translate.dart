/// Translate page for the mlflutter app.
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

// Group imports by dart, flutter, packages, local. Then alphabetically.

import 'package:flutter/material.dart';

import 'package:mlflutter/constants/language_constants.dart';
import 'package:mlflutter/features/language/language_process.dart';

class Translate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: const LanguageProcess(processType: ProcessType.translate),
      ),
    );
  }
}
