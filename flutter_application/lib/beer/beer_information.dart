import 'package:flutter/material.dart';

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