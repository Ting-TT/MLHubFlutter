/// This file contains the constants for language processing tasks.
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

import 'package:mlflutter/widgets/item_selection.dart';

// Define an enum to differentiate the modes
enum ProcessType { transcribe, translate }

String selectedModel = 'OpenAI';
String selectedFormat = 'txt';
String? selectedInputLanguage = 'Not specified';
String? selectedOutputLanguage = 'English';

List<SelectableItem> models = [
  SelectableItem(name: 'OpenAI', isEnabled: true),
  SelectableItem(name: 'Azure', isEnabled: false),
  SelectableItem(name: 'Google', isEnabled: false),
  // Add more models as needed
];

List<SelectableItem> formats = [
  SelectableItem(name: 'txt'),
  SelectableItem(name: 'json'),
  SelectableItem(name: 'srt'),
  SelectableItem(name: 'tsv'),
  SelectableItem(name: 'vtt'),
  // Add more formats as needed
];

// Currently, only English is supported because only 'OpenAI' is implemented
List<String> translationOutputLanguageOptions = [
  'English',
];

// The list of languages supported by Whisper for the input audio file.
// Referred to the LANGUAGES from https://github.com/openai/whisper/blob/main/whisper/tokenizer.py
List<String> inputLanguageOptions = [
  'Not specified',
  'Afrikaans',
  'Albanian',
  'Amharic',
  'Arabic',
  'Armenian',
  'Assamese',
  'Azerbaijani',
  'Bashkir',
  'Basque',
  'Belarusian',
  'Bengali',
  'Bosnian',
  'Breton',
  'Bulgarian',
  'Cantonese',
  'Catalan',
  'Chinese',
  'Croatian',
  'Czech',
  'Danish',
  'Dutch',
  'English',
  'Estonian',
  'Faroese',
  'Finnish',
  'French',
  'Galician',
  'Georgian',
  'German',
  'Greek',
  'Gujarati',
  'Haitian creole',
  'Hausa',
  'Hawaiian',
  'Hebrew',
  'Hindi',
  'Hungarian',
  'Icelandic',
  'Indonesian',
  'Italian',
  'Japanese',
  'Javanese',
  'Kannada',
  'Kazakh',
  'Khmer',
  'Korean',
  'Lao',
  'Latin',
  'Latvian',
  'Lingala',
  'Lithuanian',
  'Luxembourgish',
  'Macedonian',
  'Malagasy',
  'Malay',
  'Malayalam',
  'Maltese',
  'Maori',
  'Marathi',
  'Mongolian',
  'Myanmar',
  'Nepali',
  'Norwegian',
  'Nynorsk',
  'Occitan',
  'Pashto',
  'Persian',
  'Polish',
  'Portuguese',
  'Punjabi',
  'Romanian',
  'Russian',
  'Sanskrit',
  'Serbian',
  'Shona',
  'Sindhi',
  'Sinhala',
  'Slovak',
  'Slovenian',
  'Somali',
  'Spanish',
  'Sundanese',
  'Swahili',
  'Swedish',
  'Tagalog',
  'Tajik',
  'Tamil',
  'Tatar',
  'Telugu',
  'Thai',
  'Tibetan',
  'Turkish',
  'Turkmen',
  'Ukrainian',
  'Urdu',
  'Uzbek',
  'Vietnamese',
  'Welsh',
  'Yiddish',
  'Yoruba',
];
