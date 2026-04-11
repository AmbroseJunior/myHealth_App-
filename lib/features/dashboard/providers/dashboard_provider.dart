import 'package:flutter/material.dart';
import '../../../core/services/quote_service.dart';
import '../../../core/services/weather_service.dart';
import '../../../core/services/air_quality_service.dart';

class DashboardProvider extends ChangeNotifier {
  final QuoteService _quoteService = QuoteService();
  final WeatherService _weatherService = WeatherService();
  final AirQualityService _aqiService = AirQualityService();

  Map<String, String>? quote;
  WeatherData? weather;
  AirQualityData? airQuality;
  bool isLoading = false;

  Future<void> loadAll() async {
    isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _quoteService.fetchQuote(),
      _weatherService.fetchWeather(),
      _aqiService.fetchAirQuality(),
    ]);

    quote = results[0] as Map<String, String>?;
    weather = results[1] as WeatherData?;
    airQuality = results[2] as AirQualityData?;
    isLoading = false;
    notifyListeners();
  }
}
