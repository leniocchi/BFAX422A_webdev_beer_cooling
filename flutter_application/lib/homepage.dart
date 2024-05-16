import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';


// Welcome view with app icon
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage(title: 'Beer Cooling')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Icon(
          Icons.sports_bar,
          size: 100,
          color: Colors.orange.shade300,
        ),
      ),
    );
  }
}

// Homepage: 
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  String? selectedTypeOfBeer;
  String? selectedContainer;
  String? selectedWhereWasTheBeer;
  String? selectedWhereToCoolTheBeer;
  String? selectedDesiredTemperature;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Oberer Teil: Neues Bier kalt stellen
          Column(
            children: [
              ListTile(
                title: Text('Type of Beer'),
                trailing: DropdownButton<String>(
                  value: selectedTypeOfBeer,
                  items: <String?>['Ale', 'Guinness', 'Kölsch', 'Lager', 'Pils', 'Schwarzbier', 'Stout', 'Weizen']
                      .map((String? value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value ?? ''),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTypeOfBeer = newValue;
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('Bottle/Container'),
                trailing: DropdownButton<String>(
                  value: selectedContainer,
                  items: <String?>['Small Glas Bottle (8.5 oz / 0.25L)', 'Medium Glass Bottle (330ml)', 'Glass Bottle (16.9 oz / 0.5L)']
                      .map((String? value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value ?? ''),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedContainer = newValue;
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('Where was the beer?'),
                trailing: DropdownButton<String>(
                  value: selectedWhereWasTheBeer,
                  items: <String?>['Hot summer day (30°C / 86F)', 'Cloudy day (20°C/68F)', 'Room temperature (16.5°C/61.7F)', 'Custom']
                      .map((String? value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value ?? ''),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedWhereWasTheBeer = newValue;
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('Where do you want to cool the beer?'),
                trailing: DropdownButton<String>(
                  value: selectedWhereToCoolTheBeer,
                  items: <String?>['Fridge (4°C/39F)', 'Freezer (-18°C/-0.4F)', 'Custom (air)', 'Custom (water)']
                      .map((String? value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value ?? ''),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedWhereToCoolTheBeer = newValue;
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('Desired temperature'),
                trailing: DropdownButton<String>(
                  value: selectedDesiredTemperature,
                  items: <String?>['Option 1', 'Option 2', 'Option 3', 'Option 4']
                      .map((String? value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value ?? ''),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDesiredTemperature = newValue;
                    });
                  },
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Hier kannst du die Logik implementieren, die ausgeführt wird, wenn der Button gedrückt wird
                },
                child: Text('Click to cool your beer'),
              ),
            ],
          ),
          // Trennlinie
          Divider(
            height: 1,
            color: Colors.grey,
          ),
          // Unterer Teil: Liste der kaltgestellten Biere
          Container(
            padding: EdgeInsets.all(20),
            child: Text(
              'Unterer Teil',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      )
    );
  }
}

class ListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text('Item 1'),
        ),
        ListTile(
          title: Text('Item 2'),
        ),
        ListTile(
          title: Text('Item 3'),
        ),
        // Weitere Listenelemente hier hinzufügen, wenn nötig
      ],
    );
  }
}

  // String _userInput = "";
  // String _aiAnswer = "";

  // ChatApi? _api;

  // void _setAiAnswer(Message message) {
  //   setState(() {
  //     _aiAnswer = message.message ?? "<no message received>";
  //   });
  // }

  // void _setUserInput(String input) {
  //   _userInput = input;
  // }

  // void _askAI() async {
  //   var message = Message(
  //     timestamp: DateTime.now().toUtc(),
  //     author: MessageAuthorEnum.user,
  //     message: _userInput,
  //   );

  //   var response = await _api!.chat(message);

  //   _setAiAnswer(response!);
  // }

  // @override
  // Widget build(BuildContext context) {
  //   _api = Provider.of<ChatApi>(context);

  //   return Scaffold(
  //     appBar: AppBar(
  //       backgroundColor: Theme.of(context).colorScheme.inversePrimary,
  //       title: Text(widget.title),
  //     ),
  //     body: Column(
  //       children: <Widget>[
  //         TextField(
  //           key: const Key('UserInputTextField'),
  //           maxLines: 5,
  //           decoration: const InputDecoration(
  //             hintText: 'Enter text here',
  //           ),
  //           onChanged: (String value) {
  //             _setUserInput(value);
  //           },
  //         ),
  //         Expanded(
  //           child: Text(
  //             _aiAnswer,
  //             key: const Key('AiAnswerText'),
  //           ),
  //         ),
  //       ],
  //     ),
  //     floatingActionButton: FloatingActionButton(
  //       tooltip: 'Ask AI',
  //       onPressed: _askAI,
  //       child: const Icon(Icons.send),
  //     ),
  //   );
  // }