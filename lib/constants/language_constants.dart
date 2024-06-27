import 'package:mlflutter/widgets/item_selection.dart';

// Define an enum to differentiate the modes
enum ProcessType { transcribe, translate }

// Flag to track if a process is running
bool isProcessRunning = false;

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