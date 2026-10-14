import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

// PAGE 2: WEATHER PAGE

const ApiKey = '[YOUR API KEY HERE]';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  bool is_loading = true;
  Map<String, dynamic> weather = {};

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  Future<Position> getLocation() async {
    //Ask for permission

    LocationPermission permission = await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    return position;
  }

  Future<String> getData() async {
    Position loc = await getLocation();
    double lat = loc.latitude;
    double lon = loc.longitude;
    http.Response res = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$ApiKey&units=imperial',
      ),
    );
    print(res.body);
    String weatherData = res.body;
    print(weatherData);

    var weatherDesc = jsonDecode(weatherData)['weather'][0]['description'];
    print(weatherDesc);
    var temp = jsonDecode(weatherData)['main']['temp'];
    print(temp);
    var humidity = jsonDecode(weatherData)['main']['humidity'];
    print(humidity);
    var name = jsonDecode(weatherData)['name'];
    print(name);

    return weatherData;
  }

  loadWeather() async {
    String data = await getData();
    setState(() {
      weather = jsonDecode(data);
      is_loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Current Weather'))),
      body: is_loading
          ? Center(child: SpinKitSpinningLines(color: Colors.blue, size: 40))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://openweathermap.org/img/wn/${weather['weather'][0]['icon']}@4x.png',
                    color: Colors.lightBlue,
                    colorBlendMode: BlendMode.modulate,
                  ),
                  SizedBox(height: 20),
                  Text(weather['name'], style: TextStyle(fontSize: 20)),
                  SizedBox(height: 20),
                  Text(
                    '${weather['main']['temp'].round()}°F',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    weather['weather'][0]['description'],
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),

                  Text('Humidity: ${weather['main']['humidity']}'),

                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      print('back button pressed');
                      Navigator.pop(context);
                    },
                    child: Text('Back to Home'),
                  ),
                ],
              ),
            ),
    );
  }
}
