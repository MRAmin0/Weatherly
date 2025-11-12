import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/weather_models.dart';
import '../utils/city_utils.dart';

class WeatherApiService {
  WeatherApiService({
    required this.apiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String apiKey;
  final http.Client _httpClient;

  bool get isConfigured => apiKey != 'API_KEY_NOT_FOUND';

  Future<Map<String, dynamic>?> resolveCity(String query) async {
    final results = await fetchCitySuggestions(query, limit: 5);
    if (results.isEmpty) return null;
    return sortAndDeduplicateCities(results, query, maxItems: 1).first;
  }

  Future<List<Map<String, dynamic>>> fetchCitySuggestions(
    String query, {
    int limit = 10,
  }) async {
    if (!isConfigured) return const [];
    final lang = isPersianText(query) ? 'fa' : 'en';
    final encoded = Uri.encodeComponent(query);
    final uri = Uri.parse(
      'https://api.openweathermap.org/geo/1.0/direct?q=$encoded&limit=$limit&appid=$apiKey&lang=$lang',
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return const [];

      final data = await _decodeJson<List<dynamic>>(response.body);
      if (data == null) return const [];

      final mapped = data.cast<Map<String, dynamic>>();
      return sortAndDeduplicateCities(mapped, query, maxItems: limit);
    } catch (_) {
      return const [];
    }
  }

  Future<Map<String, dynamic>?> fetchCurrentWeather({
    double? lat,
    double? lon,
    String? cityName,
  }) async {
    if (!isConfigured) return null;
    Uri? uri;

    if (lat != null && lon != null) {
      uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
      );
    } else if (cityName != null && cityName.trim().isNotEmpty) {
      final encoded = Uri.encodeComponent(cityName.trim());
      uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$encoded&appid=$apiKey&units=metric',
      );
    }

    if (uri == null) return null;

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return null;
      return _decodeJson<Map<String, dynamic>>(response.body);
    } catch (_) {
      return null;
    }
  }

  Future<List<dynamic>> fetchForecast({
    required double lat,
    required double lon,
  }) async {
    if (!isConfigured) return const [];

    final uri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return const [];
      final data = await _decodeJson<Map<String, dynamic>>(response.body);
      return (data?['list'] as List<dynamic>? ?? const []);
    } catch (_) {
      return const [];
    }
  }

  Future<HourlyForecastResponse?> fetchHourlyForecast({
    required double lat,
    required double lon,
    int count = 8,
  }) async {
    if (!isConfigured) return null;

    final uri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&cnt=$count',
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return null;
      final data = await _decodeJson<Map<String, dynamic>>(response.body);
      final entries =
          List<Map<String, dynamic>>.from(data?['list'] ?? const []);
      final timezone =
          (data?['city']?['timezone'] as int?) ?? 0;
      return HourlyForecastResponse(
        entries: entries,
        timezoneOffsetSeconds: timezone,
      );
    } catch (_) {
      return null;
    }
  }

  Future<int?> fetchAirQualityIndex({
    required double lat,
    required double lon,
  }) async {
    if (!isConfigured) return null;

    final uri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey',
    );

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) return null;
      final data = await _decodeJson<Map<String, dynamic>>(response.body);
      return data?['list']?[0]?['main']?['aqi'] as int?;
    } catch (_) {
      return null;
    }
  }

  Future<T?> _decodeJson<T>(String source) async {
    try {
      if (kIsWeb) {
        return json.decode(source) as T;
      }
      final decoded = await compute(_parseJson, source);
      return decoded as T?;
    } catch (_) {
      return null;
    }
  }
}

dynamic _parseJson(String source) => json.decode(source);


