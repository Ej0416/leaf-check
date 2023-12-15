import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

// class WeatherApiClient {
//   Future<WeatherModel>? getCurrentWeather(String? location) async {
//     var endpoint = Uri.parse(
//         "https://api.openweathermap.org/data/2.5/weather?q=$location&appid=3ccbe80410b1da653384fb1b8b4b2172&units=metric");

//     var response = await http.get(endpoint);
//     if (response.statusCode == 200) {
//       var body = jsonDecode(response.body);
//       // print(WeatherModel.fromJson(body).icon);
//       return WeatherModel.fromJson(body);
//     } else {
//       return WeatherModel();
//     }
//   }
// }

class WeatherApiClient {
  Future<WeatherModel> getCurrentWeather(String? location) async {
    try {
      var endpoint = Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?q=$location&appid=3ccbe80410b1da653384fb1b8b4b2172&units=metric");

      var response = await http.get(endpoint);
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        return WeatherModel.fromJson(body);
      } else {
        return Future.error('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      return Future.error('Failed to fetch data: $e');
    }
  }
}
