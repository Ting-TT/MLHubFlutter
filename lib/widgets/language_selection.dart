/// Dropdown widgets for selecting input and output languages for language processing tasks.
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
import 'package:dropdown_search/dropdown_search.dart';

import 'package:mlflutter/constants/language_constants.dart';

class InputLanguageDropdown extends StatelessWidget {
  final String? selectedInputLanguage;
  final ValueChanged<String?> onChanged;

  const InputLanguageDropdown({
    super.key,
    required this.selectedInputLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Input Language:', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 5.0),
        DropdownSearch<String>(
          popupProps: const PopupProps.menu(
            showSearchBox: true,
            showSelectedItems: true,
            searchDelay: Duration(seconds: 0),
          ),
          items: inputLanguageOptions,
          onChanged: onChanged,
          selectedItem: selectedInputLanguage ?? 'Not specified',
        ),
      ],
    );
  }
}

class OutputLanguageDropdown extends StatelessWidget {
  final String? selectedOutputLanguage;
  final ValueChanged<String?> onChanged;

  const OutputLanguageDropdown({
    super.key,
    required this.selectedOutputLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Output Language:', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 5.0),
        DropdownSearch<String>(
          popupProps: const PopupProps.menu(
            showSearchBox: true,
            showSelectedItems: true,
            searchDelay: Duration(seconds: 0),
          ),
          items: translationOutputLanguageOptions,
          onChanged: onChanged,
          selectedItem: selectedOutputLanguage,
        ),
      ],
    );
  }
}
