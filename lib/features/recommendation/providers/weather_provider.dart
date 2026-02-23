import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/weather.dart';
import '../../../core/services/weather_service.dart';

/// Weather service singleton.
final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService(
    apiKey: const String.fromEnvironment('OWM_API_KEY'),
  );
});

/// Current weather data (auto-cached 30 min by WeatherService).
final currentWeatherProvider = FutureProvider<Weather?>((ref) async {
  final service = ref.watch(weatherServiceProvider);
  return service.getCurrentWeather();
});
