// ignore_for_file: unused_local_variable, avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart' as Geo;
import '../model/current_response_model.dart';
import '../model/forecast_response_model.dart';
import '../untils/constants.dart';

class WeatherProvider extends ChangeNotifier {
  CurrentResponseModel? currentResponseModel;
  ForecastResponseModel? forecastResponseModel;
  double latitude = 0.0, longitude = 0.0;
  String unit = 'metric';
  String unitSymbool = celsius;

  bool get hasDataLoaded =>
      currentResponseModel != null && forecastResponseModel != null;

  bool get isFah => unit == imperial;

  setNewLocation(double lat, double lon) {
    latitude = lat;
    longitude = lon;
  }

  void convertAddressToLatLong(String result) async{
    try{
      final locationList = await Geo.locationFromAddress(result);
      if (locationList.isNotEmpty) {
        final location = locationList.first;
        setNewLocation(location.latitude, location.longitude);
        getWeatherData();
      }
      else {
        print('City not found');
      }
    } catch (error) {
      print(error.toString());
    }
  }

  void setTempUnit(bool tag) {
    unit = tag ? imperial : metric;
    unitSymbool = tag ? fahrenheit : celsius;
    notifyListeners();
  }

  Future<bool> setPreferanceTempUnitValue(bool tag) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setBool('unit', tag);
  }

  Future<bool> getPreferanceTempUnitValue() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool('unit') ?? false;
  }

  getWeatherData() {
    getCurrentData();
    getForecastData();
  }

  getCurrentData() async {
    final uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=$unit&appid=$weather_api_key');
    try {
      final response = await get(uri);
      final map = json.decode(response.body);
      if (response.statusCode == 200) {
        currentResponseModel = CurrentResponseModel.fromJson(map);
        print(currentResponseModel!.main!.temp!.round());
        notifyListeners();
      } else {
        print(map['message']);
      }
    } catch (error) {
      print('Error $error');
    }
  }

  getForecastData() async {
    final uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=$unit&appid=$weather_api_key');
    try {
      final response = await get(uri);
      final map = json.decode(response.body);
      if (response.statusCode == 200) {
        forecastResponseModel = ForecastResponseModel.fromJson(map);
        print(forecastResponseModel!.list!.length);
        notifyListeners();
      } else {
        print(map['message']);
      }
    } catch (error) {
      print(error);
    }
  }
}
