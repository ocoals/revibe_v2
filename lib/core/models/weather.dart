/// Weather data from OpenWeatherMap API.
/// Not a Freezed model — simple immutable class (no DB mapping needed).
class Weather {
  final double temperature;
  final int weatherCode;
  final String description;
  final String iconCode;
  final double? rainProbability;
  final String cityName;
  final DateTime fetchedAt;

  const Weather({
    required this.temperature,
    required this.weatherCode,
    required this.description,
    required this.iconCode,
    this.rainProbability,
    required this.cityName,
    required this.fetchedAt,
  });

  /// Parse from OpenWeatherMap Current Weather API JSON response.
  factory Weather.fromOwmJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weatherList = json['weather'] as List;
    final weather = weatherList.first as Map<String, dynamic>;

    return Weather(
      temperature: (main['temp'] as num).toDouble(),
      weatherCode: weather['id'] as int,
      description: _mapWeatherDescription(weather['id'] as int),
      iconCode: weather['icon'] as String,
      rainProbability: null,
      cityName: json['name'] as String,
      fetchedAt: DateTime.now(),
    );
  }

  /// Whether this cached weather data is still fresh (< 30 minutes old).
  bool get isFresh => DateTime.now().difference(fetchedAt).inMinutes < 30;

  /// OpenWeatherMap icon URL.
  String get iconUrl =>
      'https://openweathermap.org/img/wn/$iconCode@2x.png';

  /// Map OWM weather code to Korean description.
  static String _mapWeatherDescription(int code) {
    if (code >= 200 && code < 300) return '뇌우';
    if (code >= 300 && code < 400) return '이슬비';
    if (code >= 500 && code < 600) return '비';
    if (code >= 600 && code < 700) return '눈';
    if (code >= 700 && code < 800) return '안개';
    if (code == 800) return '맑음';
    if (code > 800) return '흐림';
    return '알 수 없음';
  }
}
