// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/provider/weather_provider.dart';



class SettingsPage extends StatefulWidget {
  static const routeName = 'settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) => ListView(
          children: [
            SwitchListTile(
              title: Text('Show temperature in fah'),
              subtitle: Text('Default is cel'),
              value: provider.isFah,
              onChanged: (value) async{
                provider.setTempUnit(value);
                await provider.setPreferanceTempUnitValue(value);
                provider.getWeatherData();
              },
            ),

          ],
        ),
      ),
    );
  }
}
