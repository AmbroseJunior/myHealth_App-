import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/db_constants.dart';

class WeatherData {
  final double temperature;
  final int weatherCode;
  final double windSpeed;

  WeatherData({
    required this.temperature,
    required this.weatherCode,
    required this.windSpeed,
  });

  String get description {
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode <= 3) return 'Partly cloudy';
    if (weatherCode <= 49) return 'Foggy';
    if (weatherCode <= 69) return 'Rainy';
    if (weatherCode <= 79) return 'Snowy';
    if (weatherCode <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  String get icon {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 3) return '⛅';
    if (weatherCode <= 49) return '🌫️';
    if (weatherCode <= 69) return '🌧️';
    if (weatherCode <= 79) return '❄️';
    if (weatherCode <= 99) return '⛈️';
    return '🌡️';
  }
}

class WeatherService {
  Future<WeatherData?> fetchWeather() async {
    try {
      final url =
          'https://api.open-meteo.com/v1/forecast?latitude=${DbConstants.heraklionLat}&longitude=${DbConstants.heraklionLon}&current=temperature_2m,weathercode,windspeed_10m&timezone=Europe%2FAthens';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        return WeatherData(
          temperature: (current['temperature_2m'] as num).toDouble(),
          weatherCode: (current['weathercode'] as num).toInt(),
          windSpeed: (current['windspeed_10m'] as num).toDouble(),
        );
      }
    } catch (_) {}
    return null;
  }
}
