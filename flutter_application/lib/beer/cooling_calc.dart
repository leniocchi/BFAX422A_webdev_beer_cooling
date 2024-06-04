import 'package:flutter/material.dart';
import 'package:flutter_application/beer/beer_information.dart';

TimeOfDay calculateCoolingTime(BeerInformation beerInfo) {
  double mass = beerInfo.container; 
  double specificHeatCapacity = 4180; 
  double initialTemperature = beerInfo.whereWasTheBeer; 
  double finalTemperature = beerInfo.desiredTemperature;

  double temperatureDifference = initialTemperature - finalTemperature;

  double coolingCoefficient;

  switch (beerInfo.whereToCoolTheBeer) {
    case 4.0: 
      coolingCoefficient = 0.01; 
      break;
    case -18.0: 
      coolingCoefficient = 0.02; 
      break;
    default:
      coolingCoefficient = 0.005; 
  }

  double coolingTimeMinutes = temperatureDifference / coolingCoefficient;

  int coolingHours = (coolingTimeMinutes / 60).floor();
  int coolingMinutes = (coolingTimeMinutes % 60).round();

  int endHour = (beerInfo.selectedStartTime.hour + coolingHours + (beerInfo.selectedStartTime.minute + coolingMinutes) ~/ 60) % 24;
  int endMinute = (beerInfo.selectedStartTime.minute + coolingMinutes) % 60;

  return TimeOfDay(hour: endHour, minute: endMinute);
}