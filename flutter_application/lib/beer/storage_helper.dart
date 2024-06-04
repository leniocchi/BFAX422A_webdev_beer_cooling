import 'package:flutter_application/beer/beer_information.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<void> saveBeerList(List<BeerInformation> beerList) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> beerListJson = beerList.map((beer) => jsonEncode(beer.toJson())).toList();
  await prefs.setStringList('beerList', beerListJson);
}

Future<List<BeerInformation>> loadBeerList() async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? beerListJson = prefs.getStringList('beerList');
  if (beerListJson != null) {
    return beerListJson
        .map((beerJson) => BeerInformation.fromJson(jsonDecode(beerJson)))
        .toList();
  } else {
    return [];
  }
}