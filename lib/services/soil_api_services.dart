import 'dart:convert';
import 'package:http/http.dart' as http;

class SoilApiService {
  final String baseUrl = 'https://api.openepi.io/soil/property';

  Future fetchSoilData(double latitude, double longitude,
      {required String depths,
      required String properties,
      required String values}) async {
    // Construct the URL with query parameters
    final url = Uri.parse(baseUrl).replace(queryParameters: {
      'lon': longitude.toString(),
      'lat': latitude.toString(),
      'depths': depths,
      'properties': properties.split(',').map((prop) => prop.trim()).toList(),
      'values': values,
    });


    print('Request URL: $url'); // Debugging: Check the full request URL

    final response = await http.get(url);

    print(
        'Response body: ${response.body}'); // Debugging: Check the response body

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch soil data');
    }
  }
}
