import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const _defaultCity = 'Seoul';

  final String _apiKey;
  Weather? _cache;

  WeatherService({required String apiKey}) : _apiKey = apiKey;

  /// Get current weather. Returns cached data if < 30 min old.
  Future<Weather?> getCurrentWeather({String? city}) async {
    if (_cache != null && _cache!.isFresh) {
      return _cache;
    }

    try {
      final targetCity = city ?? _defaultCity;
      final uri = Uri.parse(
        '$_baseUrl/weather?q=$targetCity&appid=$_apiKey&units=metric&lang=kr',
      );

      final response = await http.get(uri).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _cache = Weather.fromOwmJson(json);
        return _cache;
      }

      return _cache;
    } catch (_) {
      return _cache;
    }
  }

  /// Clear cached weather data.
  void clearCache() {
    _cache = null;
  }
}
