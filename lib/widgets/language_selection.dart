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
