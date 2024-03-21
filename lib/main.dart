import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

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
    // Navigation buttons in the sidebar
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
        visible: isNLPExpanded,
        child: ListTile(
          // Add indentation to represent "Transcribe" is a sub button under NLP
          contentPadding: EdgeInsets.only(left: 32),
          leading: Icon(Icons.transcribe),
          title: Text('Transcribe'),
          onTap: () => onDestinationSelected(2),
        ),
      ),
    );

    buttons.add(
      Visibility(
        visible: isNLPExpanded,
        child: ListTile(
          // Add indentation to represent "Translate" is a sub button under NLP
          contentPadding: EdgeInsets.only(left: 32),
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
      // case 1: NLP button is clicked and sub buttons are shown/hidden, 
      // no need to show any page
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

class TranscribePage extends StatefulWidget {
  @override
  _TranscribePageState createState() => _TranscribePageState();
}

class _TranscribePageState extends State<TranscribePage> {
  String outputText = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Models available:', style: TextStyle(fontSize: 18)),
          SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0, // Space between buttons
            // Buttons for different models
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement OpenAI model functionality
                },
                child: Text('OpenAI'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement Azure model functionality
                },
                child: Text('Azure'),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Row(children: [
            Text('Drop your file here:', style: TextStyle(fontSize: 18)),
            SizedBox(width: 10.0),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement save functionality
              },
              child: Text('Run'),
            ),
          ]),
          SizedBox(height: 8.0),
          Container(
            height: 150.0,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(4.0),
              color: Colors.grey[200],
            ),
            child: DragTarget(
              onAccept: (data) {
                // TODO: Handle file dropped
              },
              builder: (_, __, ___) {
                return Center(
                  child: Text('Drag and drop area',
                      style: TextStyle(color: Colors.grey)),
                );
              },
            ),
          ),
          SizedBox(height: 16.0),
          Row(children: [
            Text('Output:', style: TextStyle(fontSize: 18)),
            SizedBox(width: 10.0),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement save functionality
              },
              child: Text('Save'),
            ),
          ]),
          SizedBox(height: 8.0),
          TextFormField(
            initialValue: outputText,
            readOnly: true,
            maxLines: null, // TODO: Set max lines as needed
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
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
