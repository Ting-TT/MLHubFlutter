/// The needed elements for storing language processing pages' states.
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

import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mlflutter/constants/language.dart';

class LanguageState {
  final String selectedModel;
  final String selectedFormat;
  final String? selectedInputLanguage;
  final String? selectedOutputLanguage;
  final List<XFile> droppedFiles;
  final String dropAreaText;
  final String outputText;

  LanguageState({
    String? selectedModel,
    String? selectedFormat,
    String? selectedInputLanguage,
    String? selectedOutputLanguage,
    List<XFile>? droppedFiles,
    String? dropAreaText,
    String? outputText,
  })  : selectedModel = selectedModel ?? selectedModelDefault,
        selectedFormat = selectedFormat ?? selectedFormatDefault,
        selectedInputLanguage =
            selectedInputLanguage ?? selectedInputLanguageDefault,
        selectedOutputLanguage =
            selectedOutputLanguage ?? selectedOutputLanguageDefault,
        droppedFiles = droppedFiles ?? const [],
        dropAreaText = dropAreaText ?? dropAreaTextDefault,
        outputText = outputText ?? '';

  LanguageState copyWith({
    String? selectedModel,
    String? selectedFormat,
    String? selectedInputLanguage,
    String? selectedOutputLanguage,
    List<XFile>? droppedFiles,
    String? dropAreaText,
    String? outputText,
  }) {
    return LanguageState(
      selectedModel: selectedModel ?? this.selectedModel,
      selectedFormat: selectedFormat ?? this.selectedFormat,
      selectedInputLanguage:
          selectedInputLanguage ?? this.selectedInputLanguage,
      selectedOutputLanguage:
          selectedOutputLanguage ?? this.selectedOutputLanguage,
      droppedFiles: droppedFiles ?? this.droppedFiles,
      dropAreaText: dropAreaText ?? this.dropAreaText,
      outputText: outputText ?? this.outputText,
    );
  }
}

final transcribeStateProvider =
    StateProvider<LanguageState>((ref) => LanguageState());
final translateStateProvider =
    StateProvider<LanguageState>((ref) => LanguageState());
final identifyStateProvider =
    StateProvider<LanguageState>((ref) => LanguageState());
