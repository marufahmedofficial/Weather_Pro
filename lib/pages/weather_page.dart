import 'package:Weather_Pro/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../provider/weather_provider.dart';
import '../untils/color.dart';
import '../untils/constants.dart';
import '../untils/helper_function.dart';
import '../untils/location_service.dart';
import '../untils/text_styles.dart';

class WeatherPage extends StatefulWidget {
  static const routeName = '/';

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late Size mediaQueary;
  late WeatherProvider provider;
  bool inInit = true;

  @override
  void didChangeDependencies() {
    if (inInit) {
      mediaQueary = MediaQuery.of(context).size;
      provider = Provider.of<WeatherProvider>(context);
      _getData();
      inInit = false;
    }
    super.didChangeDependencies();
  }

  _getData() async {
    final locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled) {
      EasyLoading.showToast('Location is disabled');
      await Geolocator.getCurrentPosition();
      _getData();
    }
    try {
      final position = await determinePosition();
      provider.setNewLocation(position.latitude, position.longitude);
      provider.setTempUnit(await provider.getPreferanceTempUnitValue());
      provider.getWeatherData();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff08677D),
      appBar: AppBar(

        elevation: 0,
        title: const Text('Weather'),
        actions: [
          IconButton(
            onPressed: () {
              _getData();
            },
            icon: const Icon(Icons.my_location),
          ),
          IconButton(
            onPressed: () async {
              final result = await showSearch(context: context, delegate: _citySearchDeligate());
              if(result != null && result.isNotEmpty) {
                //print(result);
                provider.convertAddressToLatLong(result);
              }
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, SettingsPage.routeName),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body:
      Stack(
        children: [

          // Image.asset(
          //   'images/bg2.jpg',
          //   height: mediaQueary.height,
          //   width: mediaQueary.width,
          //   fit: BoxFit.cover,
          // ),
          provider.hasDataLoaded
              ? SingleChildScrollView(
                child: Column(
                    children: [
                      _currentWeatherSection(),
                      _forecastWeatherSection(),
                      _sunRiseSunSetSection(),
                    ],
                  ),
              )
              : Center(
                  child: Text(
                  'Please Wait',
                  style: TextStyle(color: Colors.white),
                )),
        ],
      ),
    );
  }

  Widget _currentWeatherSection() {
    final response = provider.currentResponseModel;
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 2),
          padding: EdgeInsets.symmetric(horizontal: 15),
          width: mediaQueary.width,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: Colors.white.withOpacity(0.030),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FittedBox(
                        child: Text(
                          '${response!.name}, ${response.sys!.country!}',
                          style: txtAddress20,
                        ),
                      ),
                      Text(
                        getFormattedDateTime(response.dt!, 'MMM dd yyyy'),
                        style: txtDateHeader16,
                      ),
                    ],
                  ),
                  SizedBox(height: 17),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        '$iconPrefix${response.weather![0].icon}$iconSuffix',
                        fit: BoxFit.cover,
                        color: Colors.white,
                      ),
                      Text(
                        '${response.main!.temp!.round()} $degree${provider.unitSymbool}',
                        style: txtTempBig60,
                      ),
                      SizedBox(
                        width: 30,
                      )
                    ],
                  ),
                  SizedBox(height: 7),
                  Center(
                    child: Chip(
                        backgroundColor: cardColor.withOpacity(0.9),
                        label: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            response.weather![0].description!,
                            style: txtNormal14B,
                          ),
                        ),
                      ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                              child: Text(
                        'feels like ${response.main!.feelsLike!.round()}$degree${provider.unitSymbool}',
                        style: txtNormal16,
                      ))),
                      Expanded(
                          child: Container(
                              child: Text(
                        '${response.weather![0].main}, ${response.weather![0].description}',
                        style: txtNormal16,
                      ))),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                              child: Text(
                        'Humidity ${response.main!.humidity}%',
                        style: txtNormal16,
                      ))),
                      Expanded(
                          child: Container(
                              child: Text(
                        'Pressure ${response.main!.pressure} hPa',
                        style: txtNormal16,
                      ))),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                              child: Text(
                        'Visibility ${response.visibility} m',
                        style: txtNormal16,
                      ))),
                      Expanded(
                          child: Container(
                              child: Text(
                        'Wind ${response.wind!.speed} m/s',
                        style: txtNormal16,
                      ))),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Degree ${response.wind!.deg}$degree',
                    style: txtNormal16,
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _forecastWeatherSection() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      height: mediaQueary.height*.25,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.forecastResponseModel!.list!.length,
        itemBuilder: (context, index) {
          final forecastM = provider.forecastResponseModel!.list![index];
          return Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    height: 170,
                    width: 160,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 8,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            getFormattedDateTime(forecastM.dt!, 'MMM dd yyyy'),
                            style: txtNormal14,
                          ),
                          SizedBox(height: 5),
                          Text(
                            getFormattedDateTime(forecastM.dt!, 'hh mm a'),
                            style: txtNormal14,
                          ),
                          Image.network(
                            '$iconPrefix${forecastM.weather![0].icon}$iconSuffix',
                            fit: BoxFit.cover,
                            height: 50,
                            width: 50,
                            color: Colors.white,
                          ),
                          Text(
                            '${forecastM.main!.temp!.round()} $degree${provider.unitSymbool}',
                            style: txtNormal16W,
                          ),
                          Chip(
                            backgroundColor: cardColor,
                            label: Text(
                              forecastM.weather![0].description!,
                              style: txtNormal14B,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sunRiseSunSetSection() {
    final response = provider.currentResponseModel;
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 15, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Container(
              height: 50,
              width: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white.withOpacity(0.13)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sun Rise  :  ', style: txtNormal15,),
                    Text(getFormattedDateTime(response!.sys!.sunrise!, 'hh mm a'), style: txtNormal15,),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Container(
              height: 50,
              width: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white.withOpacity(0.13)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sun Set  :  ', style: txtNormal15),
                    Text(getFormattedDateTime(response.sys!.sunset!, 'hh mm a'), style: txtNormal15,),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _citySearchDeligate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      title: Text(query),
      leading: Icon(Icons.search),
      onTap: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filterList = query.isEmpty
        ? cities
        : cities
            .where((city) => city.toLowerCase().startsWith(query.toLowerCase()))
            .toList();
    return ListView.builder(
      itemCount: filterList.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(filterList[index]),
        onTap: () {
          query = filterList[index];
          close(context, query);
        },
      ),
    );
  }
}
