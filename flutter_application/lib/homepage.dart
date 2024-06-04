import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;


// Klasse zur Speicherung der Bierinformationen
class BeerInformation {
  String typeOfBeer;
  double container;
  double whereWasTheBeer;
  double whereToCoolTheBeer;
  double desiredTemperature;
  TimeOfDay selectedStartTime;
  TimeOfDay calculatedCoolingTime;

  BeerInformation({
    required this.typeOfBeer,
    required this.container,
    required this.whereWasTheBeer,
    required this.whereToCoolTheBeer,
    required this.desiredTemperature,
    required this.selectedStartTime,
    required this.calculatedCoolingTime,
  });

  factory BeerInformation.fromJson(Map<String, dynamic> json) {
    return BeerInformation(
      typeOfBeer: json['typeOfBeer'],
      container: json['container'],
      whereWasTheBeer: json['whereWasTheBeer'],
      whereToCoolTheBeer: json['whereToCoolTheBeer'],
      desiredTemperature: json['desiredTemperature'],
      selectedStartTime: TimeOfDay(
        hour: int.parse(json['selectedStartTime'].split(":")[0]),
        minute: int.parse(json['selectedStartTime'].split(":")[1]),
      ),
      calculatedCoolingTime: TimeOfDay(
        hour: int.parse(json['calculatedCoolingTime'].split(":")[0]),
        minute: int.parse(json['calculatedCoolingTime'].split(":")[1]),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'typeOfBeer': typeOfBeer,
      'container': container,
      'whereWasTheBeer': whereWasTheBeer,
      'whereToCoolTheBeer': whereToCoolTheBeer,
      'desiredTemperature': desiredTemperature,
      'selectedStartTime': '${selectedStartTime.hour}:${selectedStartTime.minute}',
      'calculatedCoolingTime': '${calculatedCoolingTime.hour}:${calculatedCoolingTime.minute}',
    };
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

  ChatApi? _api;

  List<BeerInformation> beerList = [];

  String selectedTypeOfBeer = '';
  double selectedContainer = 0.33;
  double selectedWhereWasTheBeer = 20.0;
  double selectedWhereToCoolTheBeer = 4.0;
  double selectedDesiredTemperature = 4.0;
  TimeOfDay selectedStartTime = TimeOfDay.now();
  TimeOfDay calculatedCoolingTime = TimeOfDay.now();

  String _aiAnswer = "";

  // Funktion zum Erstellen des BeerInformation-Objekts
  BeerInformation _createBeerInformationObject() {
    return BeerInformation(
      typeOfBeer: selectedTypeOfBeer,
      container: selectedContainer,
      whereWasTheBeer: selectedWhereWasTheBeer,
      whereToCoolTheBeer: selectedWhereToCoolTheBeer,
      desiredTemperature: selectedDesiredTemperature,
      selectedStartTime: selectedStartTime,
      calculatedCoolingTime: calculatedCoolingTime,
    );
  }

  // Funktion zum Speichern des BeerInformation-Objekts und Durchführen der weiteren Logik
  void _setUserInput() {

    BeerInformation beerInformation = _createBeerInformationObject();
    beerInformation.calculatedCoolingTime = calculateCoolingTime(beerInformation);
    
    setState(() {
      beerList.add(beerInformation);
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != selectedStartTime) {
      setState(() {
        selectedStartTime = pickedTime;
      });
    }
  }

  // TODO: Funktion zum Berechnen der Kühlzeit
  TimeOfDay calculateCoolingTime(BeerInformation beerInfo) {
    double mass = beerInfo.container; // Volumen des Biers in kg (1L = 1kg für Wasser)
    double specificHeatCapacity = 4180; // spezifische Wärmekapazität in J/(kg·K)
    double initialTemperature = beerInfo.whereWasTheBeer; // Starttemperatur in °C
    double finalTemperature = beerInfo.desiredTemperature; // Endtemperatur in °C

    double temperatureDifference = initialTemperature - finalTemperature; // Temperaturdifferenz in °C

    double coolingConstant = 0.05; // Ein angenommener Konstante für den Kühlprozess (z.B. in K/min)
    double coolingTimeMinutes = (mass * specificHeatCapacity * temperatureDifference) / (coolingConstant * 60 * 1000); // Zeit in Minuten

    // Berechnung der Stunden und Minuten aus der Gesamtzeit in Minuten
    int coolingHours = (coolingTimeMinutes / 60).floor();
    int coolingMinutes = (coolingTimeMinutes % 60).round();

    // Hinzufügen der Kühlzeit zur Startzeit
    int endHour = (beerInfo.selectedStartTime.hour + coolingHours + (beerInfo.selectedStartTime.minute + coolingMinutes) ~/ 60) % 24;
    int endMinute = (beerInfo.selectedStartTime.minute + coolingMinutes) % 60;

    return TimeOfDay(hour: endHour, minute: endMinute);
  }

  // function to ask AI
  void _askAI(BuildContext context, BeerInformation beerInfo, int iconbutton) async {

    final api = Provider.of<ChatApi>(context, listen: false);
    String messageText;

    if (iconbutton == 1) {
      messageText = "Gib einen witzigen Trinkspruch für das folgende Bier: ${beerInfo.typeOfBeer}";
    } else if (iconbutton == 2) {
      messageText = "Gib mir 3 witzige, kurze, knackige Fakten über die Biersorte: ${beerInfo.typeOfBeer}";
    } else {
      messageText = "Unbekannte Anfragequelle.";
    } 

    var message = Message(
      timestamp: DateTime.now().toUtc(),
      author: MessageAuthorEnum.user,
      message: messageText,
    );

    try {
      var response = await api.chat(message);

      if (response != null && response.message != null) {
        _showResponseDialog(context, response.message!, iconbutton);
      } else {
        _showResponseDialog(context, "No response received from OpenAPI.", iconbutton);
      }
    } catch (e) {
      _showResponseDialog(context, "Error: $e", iconbutton);
  }
  }

  // void _setAiAnswer(Message message) {
  //   setState(() {
  //     _aiAnswer = message.message ?? "<no message received>";
  //   });
  // }

  // Funktion zum Anzeigen der Antwort im Popup-Fenster
  void _showResponseDialog(BuildContext context, String response, int iconbutton) {
    
    String dialogTile;

    if (iconbutton == 1) {
      dialogTile = "Trinkspruch";
    } else if (iconbutton == 2) {
      dialogTile = "Bierfakten";
    } else {
      dialogTile = "Unbekannte Anfragequelle.";
    } 
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(dialogTile),
          content: Text(response),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // Oberer Teil: Neues Bier kalt stellen
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                title: const Text('Type of Beer'),
                trailing: SizedBox(
                  width: 200,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter the type of beer',
                    ),
                    onChanged: (value) {
                      selectedTypeOfBeer = value;
                    },
                  ),
                ),
              ),
              ListTile(
                title: const Text('Bottle/Container'),
                trailing: DropdownButton<double>(
                  value: selectedContainer,
                  items: <double>[
                    0.25,
                    0.33,
                    0.5
                  ].map((double value) {
                    return DropdownMenuItem<double>(
                      value: value,
                      child: Text('$value L'),
                    );
                  }).toList(),
                  onChanged: (double? newValue) {
                    setState(() {
                      selectedContainer = newValue!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Where was the beer?'),
                trailing: DropdownButton<double>(
                  value: selectedWhereWasTheBeer,
                  items: <double>[
                    30.0,
                    20.0,
                    16.5
                  ].map((double value) {
                    return DropdownMenuItem<double>(
                      value: value,
                      child: Text('$value °C'),
                    );
                  }).toList(),
                  onChanged: (double? newValue) {
                    setState(() {
                      selectedWhereWasTheBeer = newValue!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Where do you want to cool the beer?'),
                trailing: DropdownButton<double>(
                  value: selectedWhereToCoolTheBeer,
                  items: <double>[
                    4.0,
                    5.0,
                    6.0
                  ].map((double value) {
                    return DropdownMenuItem<double>(
                      value: value,
                      child: Text('$value °C'),
                    );
                  }).toList(),
                  onChanged: (double? newValue) {
                    setState(() {
                      selectedWhereToCoolTheBeer = newValue!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Desired temperature'),
                trailing: DropdownButton<double>(
                  value: selectedDesiredTemperature,
                  items: <double>[
                      4.0,
                      5.0,
                      6.0
                    ]
                      .map((double value) {
                    return DropdownMenuItem<double>(
                      value: value,
                      child: Text('$value °C'),
                    );
                  }).toList(),
                  onChanged: (double? newValue) {
                    setState(() {
                      selectedDesiredTemperature = newValue!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Select Time'),
                trailing: ElevatedButton(
                  onPressed: () {
                    _selectTime(context);
                  },
                  child: Text('${selectedStartTime!.hour}:${selectedStartTime!.minute}'),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _setUserInput,
                child: const Text('Click to cool your beer'),
              ),
            ],
          ),
          // Trennlinie
          const Divider(
            height: 1,
            color: Colors.grey,
          ),
          // Unterer Teil: Liste der kaltgestellten Biere
          Expanded(
            child: ListView.builder(
              itemCount: beerList.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildListRow(context, beerList[index]);
              },
            ),
          ),
        ],
      )
    );
  }

  // Funktion zum Erstellen einer Zeile in der Liste
  Widget _buildListRow(BuildContext context, BeerInformation beerInfo) {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: Text(beerInfo.typeOfBeer),
            // weitere informationen des element drunter anzeigen lassen 
          ),
        ),
        Text('${beerInfo.selectedStartTime.hour}:${beerInfo.selectedStartTime.minute}'),
        const SizedBox(width: 16), 
        Text('${beerInfo.calculatedCoolingTime.hour}:${beerInfo.calculatedCoolingTime.minute}'),
        const SizedBox(width: 12), 
        // function: get drinking toast
        IconButton(
          icon: const Icon(Icons.celebration),
          onPressed: () => _askAI(context, beerInfo, 1),
        ),
        // function: get random information about the sort of beer
        IconButton(
          icon: const Icon(Icons.info),
          onPressed: () => _askAI(context, beerInfo, 2),
        ),
        // function: delete beer item from beerlist
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {

          },
        ),
      ],
    );
  } 
}



  

  