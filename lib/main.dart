/// Entry point for the mlflutter app.
///
/// Copyright (C) 2024
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';

import 'package:mlflutter/language_process.dart';
import 'package:mlflutter/log.dart';

// Check if this is a production (--release) version.

const bool isProduction = bool.fromEnvironment('dart.vm.product');

void main() async {
  // In production do not display [debguPrint] messages.

  if (isProduction) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowManager.instance.setMinimumSize(const Size(700, 500));
  runApp(const ProviderScope(child: MLHub())); // Wrap with ProviderScope
}

class MLHub extends StatelessWidget {
  const MLHub({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MLHub Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MLHubMainPage(),
    );
  }
}

class MLHubMainPage extends StatefulWidget {
  @override
  State<MLHubMainPage> createState() => _MLHubMainPageState();
}

class _MLHubMainPageState extends State<MLHubMainPage> {
  var selectedIndex = 0;
  bool isLanguageExpanded = false;
  String _appVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version; // Set app version from package info
    });
  }

  void onDestinationSelected(int index) {
    setState(() {
      selectedIndex = index;
      ((index == 1 && !isLanguageExpanded) || index == 2 || index == 3)
          ?
          // Assuming "Language" is at index 1, and its children are at 2 and 3
          isLanguageExpanded = true
          : isLanguageExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Navigation buttons in the sidebar
    List<Widget> mainButtons = [
      ListTile(
        leading: const Icon(Icons.home),
        title: const Text('Home'),
        onTap: () => onDestinationSelected(0),
        selected: selectedIndex == 0,
        selectedTileColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
        selectedColor: Theme.of(context).colorScheme.primary,
      ),
      ListTile(
        leading: const Icon(Icons.language),
        title: const Text('Language'),
        onTap: () => onDestinationSelected(1),
        selected: selectedIndex == 1,
        selectedTileColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
        selectedColor: Theme.of(context).colorScheme.primary,
      ),
    ];

    mainButtons.add(
      Visibility(
        visible: isLanguageExpanded,
        child: ListTile(
          // Add indentation to represent "Transcribe" is a sub button under Language
          contentPadding: const EdgeInsets.only(left: 32),
          leading: const Icon(Icons.transcribe),
          title: const Text('Transcribe'),
          onTap: () => onDestinationSelected(2),
          selected: selectedIndex == 2,
          selectedTileColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );

    mainButtons.add(
      Visibility(
        visible: isLanguageExpanded,
        child: ListTile(
          // Add indentation to represent "Translate" is a sub button under Language
          contentPadding: const EdgeInsets.only(left: 32),
          leading: const Icon(Icons.translate),
          title: const Text('Translate'),
          onTap: () => onDestinationSelected(3),
          selected: selectedIndex == 3,
          selectedTileColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );

    mainButtons.add(
      ListTile(
        leading: const Icon(Icons.visibility),
        title: const Text('Vision'),
        onTap: () => onDestinationSelected(4),
        selected: selectedIndex == 4,
        selectedTileColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
        selectedColor: Theme.of(context).colorScheme.primary,
      ),
    );

    Widget logButton = ListTile(
      leading: const Icon(Icons.list_alt),
      title: const Text('Log'),
      onTap: () => onDestinationSelected(5),
      selected: selectedIndex == 5,
      selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      selectedColor: Theme.of(context).colorScheme.primary,
    );

    Widget versionLabel = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Version: $_appVersion',
        style: const TextStyle(color: Colors.grey),
      ),
    );

    double sidebarWidth = 180; // Sidebar width

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: sidebarWidth,
            child: Column(
              children: [
                Expanded(child: ListView(children: mainButtons)),
                logButton, // This will always be at the bottom
                versionLabel,
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: getPage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget getPage() {
    switch (selectedIndex) {
      case 0:
        return IntroductionPage();
      // Case 1: Language button is clicked and sub buttons are shown/hidden,
      // no need to show any page.
      case 2: // Transcribe
        return TranscribePage();
      case 3: // Translate
        return TranslatePage();
      case 4: // Computer Vision
        return ComputerVisionPage();
      case 5: // Log
        return LogPage();
      default:
        return IntroductionPage();
    }
  }
}

class IntroductionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Welcome to MLHub Flutter App'),
    );
  }
}

class TranscribePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const LanguageProcessPage(processType: ProcessType.transcribe);
  }
}

class TranslatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const LanguageProcessPage(processType: ProcessType.translate);
  }
}

class ComputerVisionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Computer Vision Page'),
    );
  }
}
