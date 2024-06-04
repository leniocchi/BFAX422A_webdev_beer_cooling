import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;


// Klasse zur Speicherung der Bierinformationen
class BeerInformation {
  String? typeOfBeer;
  String? container;
  String? whereWasTheBeer;
  String? whereToCoolTheBeer;
  String? desiredTemperature;
  TimeOfDay? selectedStartTime;
  TimeOfDay? calculatedCoolingTime;

  BeerInformation({
    this.typeOfBeer,
    this.container,
    this.whereWasTheBeer,
    this.whereToCoolTheBeer,
    this.desiredTemperature,
    this.selectedStartTime,
    this.calculatedCoolingTime,
  });
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

  String? selectedTypeOfBeer;
  String? selectedContainer;
  String? selectedWhereWasTheBeer;
  String? selectedWhereToCoolTheBeer;
  String? selectedDesiredTemperature;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? calculatedCoolingTime;

  String? _aiAnswer = "";

  // Funktion zum Erstellen des BeerInformation-Objekts
  BeerInformation _createBeerInformationObject() {
    return BeerInformation(
      typeOfBeer: selectedTypeOfBeer,
      container: selectedContainer,
      whereWasTheBeer: selectedWhereWasTheBeer,
      whereToCoolTheBeer: selectedWhereToCoolTheBeer,
      desiredTemperature: selectedDesiredTemperature,
      selectedStartTime: _selectedStartTime,
    );
  }

  // Funktion zum Speichern des BeerInformation-Objekts und Durchführen der weiteren Logik
  void _setUserInput() {
    BeerInformation beerInformation = _createBeerInformationObject();
    
    BeerInformation responseBeerInformation = _getCoolingTime(beerInformation);

    setState(() {
      beerList.add(responseBeerInformation);
    });
  }

  // Funktion um ChatGPT nach der Kühlzeit zu fragen
  BeerInformation _getCoolingTime(BeerInformation beerInformation) {

    // Wie lange dauert es, bis ein Getränk der Sorte {selectedTypeOfBeer} in einem {selectedContainer}, das sich vorher an {selectedWhereWasTheBeer} befand, 
    // auf {selectedDesiredTemperature} abgekühlt ist, wenn es seit {_selectedStartTime} in {selectedWhereToCoolTheBeer} gekühlt wird?

    return BeerInformation(
      calculatedCoolingTime: calculatedCoolingTime
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedStartTime) {
      setState(() {
        _selectedStartTime = pickedTime;
      });
    }
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
                title: Text('Type of Beer'),
                trailing: Container(
                  width: 200,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter the type of beer',
                    ),
                    onChanged: (value) {
                      selectedTypeOfBeer = value;
                    },
                  ),
                ),
              ),
              ListTile(
                title: Text('Bottle/Container'),
                trailing: DropdownButton<String>(
                  value: selectedContainer,
                  items: <String?>[
                    'Small Glas Bottle (8.5 oz / 0.25L)',
                    'Medium Glass Bottle (330ml)',
                    'Glass Bottle (16.9 oz / 0.5L)'
                  ].map((String? value) {
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
                  items: <String?>[
                    'Hot summer day (30°C / 86F)',
                    'Cloudy day (20°C/68F)',
                    'Room temperature (16.5°C/61.7F)',
                    'Custom'
                  ].map((String? value) {
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
                  items: <String?>[
                    'Fridge (4°C/39F)',
                    'Freezer (-18°C/-0.4F)',
                    'Custom (air)',
                    'Custom (water)'
                  ].map((String? value) {
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
                  items: <String?>['Optimal', 'Custom']
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
              ListTile(
                title: Text('Select Time'),
                trailing: ElevatedButton(
                  onPressed: () {
                    _selectTime(context);
                  },
                  child: Text(_selectedStartTime != null
                      ? '${_selectedStartTime!.hour}:${_selectedStartTime!.minute}'
                      : 'Select Time'),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _setUserInput,
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
          Expanded(
            child: ListView.builder(
              itemCount: beerList.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildListRow(beerList[index]);
              },
            ),
          ),
        ],
      )
    );
  }
}

// Funktion zum Erstellen einer Zeile in der Liste
Widget _buildListRow(BeerInformation beerInfo) {
  return Row(
    children: [
      Expanded(
        child: ListTile(
          title: Text('${beerInfo.typeOfBeer}'),
          // weitere informationen des element drunter anzeigen lassen 
        ),
      ),
      Text('${beerInfo.selectedStartTime?.hour}:${beerInfo.selectedStartTime?.minute}'),
      Text('End time'), // Timer hier einfügen
      IconButton(
        icon: Icon(Icons.celebration),
        onPressed: () {
          // Aktion für das erste Icon
        },
      ),
      IconButton(
        icon: Icon(Icons.info),
        onPressed: () {
          // Aktion für das zweite Icon
        },
      ),
      IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          // Aktion für das dritte Icon
        },
      ),
    ],
  );
}