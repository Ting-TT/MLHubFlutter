import 'package:flutter/material.dart';

void main() {
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
  bool isNLPExpanded = false;

  void onDestinationSelected(int index) {
    setState(() {
      selectedIndex = index;
      if ((index == 1 && !isNLPExpanded) || index == 2 || index == 3) {
        // Assuming "NLP" is at index 1, and its children are at 2 and 3
        isNLPExpanded = true;
      } else {
        isNLPExpanded = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [
      ListTile(
        leading: Icon(Icons.home),
        title: Text('Home'),
        onTap: () => onDestinationSelected(0),
      ),
      ListTile(
        leading: Icon(Icons.language),
        title: Text('NLP'),
        onTap: () => onDestinationSelected(1),
      ),
    ];

    buttons.add(
      Visibility(
        visible: isNLPExpanded, // Control visibility based on `isNLPExpanded`
        child: ListTile(
          contentPadding: EdgeInsets.only(left: 32), // Add indentation
          leading: Icon(Icons.transcribe),
          title: Text('Transcribe'),
          onTap: () => onDestinationSelected(2),
        ),
      ),
    );

    buttons.add(
      Visibility(
        visible: isNLPExpanded, // Control visibility based on `isNLPExpanded`
        child: ListTile(
          contentPadding: EdgeInsets.only(left: 32), // Add indentation
          leading: Icon(Icons.translate),
          title: Text('Translate'),
          onTap: () => onDestinationSelected(3),
        ),
      ),
    );

    buttons.add(
      ListTile(
        leading: Icon(Icons.visibility),
        title: Text('Computer Vision'),
        onTap: () => onDestinationSelected(4),
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
      // case 1: NLP button is clicked and sub buttons are shown, no need to show any page
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

class TranscribePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Transcribe Page'),
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
