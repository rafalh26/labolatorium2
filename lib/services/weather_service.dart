import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String _apiKey = '8d8e26cc8842f8dfa96ad8a16b19a1e1';
  final String _city = 'Cieszyn';
  final String _country = 'PL';

  Future<String> getCurrentWeather() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$_city,$_country&units=metric&appid=$_apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temp = data['main']['temp'];
        final weather = data['weather'][0]['description'];
        return '$weather, ${temp.toStringAsFixed(1)}°C';
      } else {
        return 'Unable to fetch weather';
      }
    } catch (e) {
      return 'Error fetching weather';
    }
  }
}
