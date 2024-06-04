import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'beer/beer_information.dart';
import 'beer/cooling_calc.dart';
import 'beer/storage_helper.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<BeerInformation> beerList = [];

  String selectedTypeOfBeer = '';
  double selectedContainer = 0.33;
  double selectedWhereWasTheBeer = 20.0;
  double selectedWhereToCoolTheBeer = 4.0;
  double selectedDesiredTemperature = 4.0;
  TimeOfDay selectedStartTime = TimeOfDay.now();
  TimeOfDay calculatedCoolingTime = TimeOfDay.now();

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

  @override
  void initState() {
    super.initState();
    _loadBeerList();
  }

  Future<void> _loadBeerList() async {
    List<BeerInformation> loadedBeerList = await loadBeerList();
    setState(() {
      beerList = loadedBeerList;
    });
  }

  void _setUserInput() {

    BeerInformation beerInformation = _createBeerInformationObject();
    beerInformation.calculatedCoolingTime = calculateCoolingTime(beerInformation);
    
    setState(() {
      beerList.add(beerInformation);
    });

    saveBeerList(beerList);
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
                    -18.0,
                    0.0,
                    4.0,
                    15.0
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
                      6.0,
                      8.0,
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
          const Divider(
            height: 1,
            color: Colors.grey,
          ),
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
          ),
        ),
        Text('${beerInfo.selectedStartTime.hour}:${beerInfo.selectedStartTime.minute}'),
        const SizedBox(width: 16), 
        Text('${beerInfo.calculatedCoolingTime.hour}:${beerInfo.calculatedCoolingTime.minute}'),
        const SizedBox(width: 12), 
        IconButton(
          icon: const Icon(Icons.celebration),
          onPressed: () => _askAI(context, beerInfo, 1),
        ),
        IconButton(
          icon: const Icon(Icons.info),
          onPressed: () => _askAI(context, beerInfo, 2),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() {
              beerList.remove(beerInfo);
            });
            saveBeerList(beerList);
          },
        ),
      ],
    );
  } 
}



  

  