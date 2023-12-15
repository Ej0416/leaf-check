import 'package:flutter/material.dart';
import 'package:leafcheck_project_v2/models/weather_model.dart';
import 'package:leafcheck_project_v2/services/weather_api_client.dart';

import '../../../services/firebase_helper.dart';
import '../../../styles/font_styles.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({
    super.key,
  });

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  WeatherApiClient weatherClient = WeatherApiClient();
  WeatherModel? weatherData;

  Future getWeatherData() async {
    try {
      weatherData = await weatherClient.getCurrentWeather("panabo");
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  CustomFontStyles fonts = CustomFontStyles();
  String? uid = FirebaseHelper.getCurrentUserId();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getWeatherData(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Icon(
              Icons.cloud_off_rounded,
              size: 100,
              color: Colors.grey,
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Weather",
                    style: fonts.weatherWidgetTitle,
                  ),
                  Text(
                    "${weatherData!.temp} ℃",
                    style: fonts.weatherTemperatur,
                  ),
                  Text(
                    "${weatherData!.desc}",
                    style: fonts.weatherDesc,
                  ),
                ],
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(50, 72, 71, 71),
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                height: 100,
                width: 100,
                child: Image.network(
                  'http://openweathermap.org/img/wn/${weatherData!.icon}@2x.png',
                  fit: BoxFit.fill,
                ),
              ),
            ],
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text("Error Occured!"),
          );
        }
        return const Center(
          child: Text("Error Occured!"),
        );
      },
    );
  }
}
