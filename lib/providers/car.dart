/// Help with retaining the state of the car identification process.
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

import 'package:flutter_riverpod/flutter_riverpod.dart';

class CarIdentificationState {
  String? selectedType; // Store the selected input type (File, URL)
  String? selectedInputPath;
  String outputMessage;
  bool errorOccurred;

  CarIdentificationState({
    this.selectedType,
    this.selectedInputPath,
    this.outputMessage = '',
    this.errorOccurred = false,
  });

  CarIdentificationState copyWith({
    String? selectedType,
    String? selectedInputPath,
    String? outputMessage,
    bool? errorOccurred,
  }) {
    return CarIdentificationState(
      selectedType: selectedType ?? this.selectedType,
      selectedInputPath: selectedInputPath ?? this.selectedInputPath,
      outputMessage: outputMessage ?? this.outputMessage,
      errorOccurred: errorOccurred ?? this.errorOccurred,
    );
  }
}

class CarIdentificationNotifier extends StateNotifier<CarIdentificationState> {
  CarIdentificationNotifier() : super(CarIdentificationState());

  void updateInputPath(String path, String type) {
    state = state.copyWith(
      selectedInputPath: path,
      selectedType: type,
    );
  }

  void updateOutputMessage(String message) {
    state = state.copyWith(outputMessage: message);
  }

  void updateErrorOccurred(bool hasError) {
    state = state.copyWith(errorOccurred: hasError);
  }
}

final carIdentificationStateProvider =
    StateNotifierProvider<CarIdentificationNotifier, CarIdentificationState>(
  (ref) => CarIdentificationNotifier(),
);
