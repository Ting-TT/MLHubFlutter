/// Help with retaining the state of the deface process.
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
/// Authors: Ting Tang, Graham Williams

library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

class DefaceState {
  String? selectedType; // Store the selected input type (File, Folder, URL)
  String? selectedInputPath;
  String? selectedOutputDirectory; // The directory to save the output images

  DefaceState({
    this.selectedType,
    this.selectedInputPath,
    this.selectedOutputDirectory,
  });

  DefaceState copyWith({
    String? selectedType,
    String? selectedInputPath,
    String? selectedOutputDirectory,
  }) {
    return DefaceState(
      selectedType: selectedType ?? this.selectedType,
      selectedInputPath: selectedInputPath ?? this.selectedInputPath,
      selectedOutputDirectory:
          selectedOutputDirectory ?? this.selectedOutputDirectory,
    );
  }
}

class DefaceNotifier extends StateNotifier<DefaceState> {
  DefaceNotifier() : super(DefaceState());

  void updateInputPath(String path, String type) {
    state = state.copyWith(
      selectedInputPath: path,
      selectedType: type,
    );
  }

  void updateOutputDirectory(String directory) {
    state = state.copyWith(selectedOutputDirectory: directory);
  }
}

final defaceStateProvider = StateNotifierProvider<DefaceNotifier, DefaceState>(
  (ref) => DefaceNotifier(),
);
