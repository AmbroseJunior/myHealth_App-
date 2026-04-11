import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/db_constants.dart';

class AirQualityData {
  final double pm10;
  final double pm25;
  final int europeanAqi;

  AirQualityData({required this.pm10, required this.pm25, required this.europeanAqi});

  String get aqiLabel {
    if (europeanAqi <= 20) return 'Good';
    if (europeanAqi <= 40) return 'Fair';
    if (europeanAqi <= 60) return 'Moderate';
    if (europeanAqi <= 80) return 'Poor';
    if (europeanAqi <= 100) return 'Very Poor';
    return 'Extremely Poor';
  }

  String get aqiColor {
    if (europeanAqi <= 20) return 'green';
    if (europeanAqi <= 40) return 'lightGreen';
    if (europeanAqi <= 60) return 'yellow';
    if (europeanAqi <= 80) return 'orange';
    if (europeanAqi <= 100) return 'red';
    return 'purple';
  }
}

class AirQualityService {
  Future<AirQualityData?> fetchAirQuality() async {
    try {
      final url =
          'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=${DbConstants.heraklionLat}&longitude=${DbConstants.heraklionLon}&current=pm10,pm2_5,european_aqi';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        return AirQualityData(
          pm10: (current['pm10'] as num?)?.toDouble() ?? 0,
          pm25: (current['pm2_5'] as num?)?.toDouble() ?? 0,
          europeanAqi: (current['european_aqi'] as num?)?.toInt() ?? 0,
        );
      }
    } catch (_) {}
    return null;
  }
}
