import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'transcribe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowManager.instance.setMinimumSize(const Size(700, 500));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

  void onDestinationSelected(int index) {
    setState(() {
      selectedIndex = index;
      if ((index == 1 && !isLanguageExpanded) || index == 2 || index == 3) {
        // Assuming "Language" is at index 1, and its children are at 2 and 3
        isLanguageExpanded = true;
      } else {
        isLanguageExpanded = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Navigation buttons in the sidebar
    List<Widget> buttons = [
      ListTile(
        leading: Icon(Icons.home),
        title: Text('Home'),
        onTap: () => onDestinationSelected(0),
        selected: selectedIndex == 0,
        selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        selectedColor: Theme.of(context).colorScheme.primary,
      ),
      ListTile(
        leading: Icon(Icons.language),
        title: Text('Language'),
        onTap: () => onDestinationSelected(1),
        selected: selectedIndex == 1,
        selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        selectedColor: Theme.of(context).colorScheme.primary,
      ),
    ];

    buttons.add(
      Visibility(
        visible: isLanguageExpanded,
        child: ListTile(
          // Add indentation to represent "Transcribe" is a sub button under Language
          contentPadding: EdgeInsets.only(left: 32),
          leading: Icon(Icons.transcribe),
          title: Text('Transcribe'),
          onTap: () => onDestinationSelected(2),
          selected: selectedIndex == 2,
          selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );

    buttons.add(
      Visibility(
        visible: isLanguageExpanded,
        child: ListTile(
          // Add indentation to represent "Translate" is a sub button under Language
          contentPadding: EdgeInsets.only(left: 32),
          leading: Icon(Icons.translate),
          title: Text('Translate'),
          onTap: () => onDestinationSelected(3),
          selected: selectedIndex == 3,
          selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );

    buttons.add(
      ListTile(
        leading: Icon(Icons.visibility),
        title: Text('Vision'),
        onTap: () => onDestinationSelected(4),
        selected: selectedIndex == 4,
        selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        selectedColor: Theme.of(context).colorScheme.primary,
      ),
    );

    double sidebarWidth = 180; // Sidebar width

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: sidebarWidth,
            child: ListView(children: buttons),
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
      default:
        return IntroductionPage();
    }
  }
}

class IntroductionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Welcome to MLHub Flutter App'),
    );
  }
}

class TranslatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Translate Page'),
    );
  }
}

class ComputerVisionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Computer Vision Page'),
    );
  }
}
