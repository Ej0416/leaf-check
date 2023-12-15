class WeatherModel {
  String? cityName;
  String? temp;
  String? wind;
  String? humidity;
  String? feelsLike;
  String? pressure;
  String? icon;
  String? desc;

  WeatherModel({
    this.cityName,
    this.temp,
    this.wind,
    this.humidity,
    this.feelsLike,
    this.pressure,
    this.icon,
    this.desc,
  });

  WeatherModel.fromJson(Map<String, dynamic> json) {
    cityName = json["name"];
    temp = json["main"]["temp"].toString();
    wind = json["wind"]["speed"].toString();
    humidity = json["main"]["humidity"].toString();
    feelsLike = json["main"]["feels_like"].toString();
    pressure = json["main"]["pressure"].toString();
    icon = json["weather"][0]["icon"];
    desc = json["weather"][0]["description"];
  }
}
