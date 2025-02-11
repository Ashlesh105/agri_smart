import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/weather_api_service.dart';

class WeatherForecastPage extends StatefulWidget {
  @override
  _WeatherForecastPageState createState() => _WeatherForecastPageState();
}

class _WeatherForecastPageState extends State<WeatherForecastPage> {
  final WeatherApiService _weatherService = WeatherApiService();
  Map<String, dynamic>? currentWeather;
  List<dynamic>? forecastData;
  List<Map<String, dynamic>> searchedCitiesWeather = [];  // **Store searched cities' weather**
  bool isLoading = true;
  String errorMessage = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final weather = await _weatherService.fetchWeather(position.latitude, position.longitude);
      final forecast = await _weatherService.fetchForecast(position.latitude, position.longitude);

      setState(() {
        currentWeather = weather;
        forecastData = forecast['list'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // **Function to Search Weather by City Name**
  Future<void> _searchWeather(String cityName) async {
    if (cityName.isEmpty) return;
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final cityWeather = await _weatherService.fetchWeatherByCity(cityName);
      setState(() {
        searchedCitiesWeather.insert(0, cityWeather); // **Add the searched city weather at the top**
        isLoading = false;
        _searchController.clear(); // **Clear search bar after search**
      });
    } catch (e) {
      setState(() {
        errorMessage = 'City not found!';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/home_pg_bg.jpg'),fit: BoxFit.cover)
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for a city...',
              hintStyle: TextStyle(color: Colors.white),
              border: InputBorder.none,
            ),
            onSubmitted: _searchWeather,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () => _searchWeather(_searchController.text),
            ),
            IconButton(
              icon: Icon(Icons.refresh,color: Colors.white,),
              onPressed: _fetchWeather,
            ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage))
            : _buildWeatherContent(),
      ),
    );
  }

  Widget _buildWeatherContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...searchedCitiesWeather.map((cityWeather) => _buildWeatherCard(cityWeather)).toList(),
            ],
          ),

          SizedBox(height: 20),
          Text('Your Current Location', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          _buildCurrentWeather(),
          SizedBox(height: 20),
          Text('5-Day Forecast', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          _buildForecastList(),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(Map<String, dynamic> weatherData) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16,left: 10,right: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              weatherData['name'] ?? 'Unknown Location',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '${weatherData['main']['temp'].toStringAsFixed(1)}°C',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              weatherData['weather'][0]['description'] ?? '',
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeather() {
    if (currentWeather == null) return SizedBox.shrink();
    return _buildWeatherCard(currentWeather!);
  }

  Widget _buildForecastList() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecastData?.length ?? 0,
        itemBuilder: (context, index) {
          final forecast = forecastData![index];
          final dateTime = DateTime.parse(forecast['dt_txt']);
          final temperature = forecast['main']['temp'].toStringAsFixed(1);
          final weatherDescription = forecast['weather'][0]['main'];

          return Container(
            width: 120,
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${dateTime.day}/${dateTime.month}',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '$temperature°C',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  weatherDescription,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
