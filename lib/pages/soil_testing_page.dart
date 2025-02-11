import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/location_services.dart';
import '../services/soil_api_services.dart';

class SoilTestScreen extends StatefulWidget {
  const SoilTestScreen({super.key});

  @override
  _SoilTestScreenState createState() => _SoilTestScreenState();
}

class _SoilTestScreenState extends State<SoilTestScreen> {
  bool isLoading = false;
  Map<String, dynamic>? soilData;

  final TextEditingController depthsController = TextEditingController(text: '0-5cm',);
  final TextEditingController propertiesController = TextEditingController(
      text: 'bdod, cec, cfvo, clay, nitrogen, ocd, ocs, phh2o, sand, silt, soc');
  final TextEditingController valuesController = TextEditingController(text: 'mean');

  Future<void> getSoilData() async {
    setState(() => isLoading = true);

    try {
      LocationService locationService = LocationService();
      final position = await locationService.getCurrentLocation();

      if (position != null) {
        double latitude = position.latitude;
        double longitude = position.longitude;
        SoilApiService apiService = SoilApiService();

        final data = await apiService.fetchSoilData(
          latitude,
          longitude,
          depths: depthsController.text.trim(),
          properties: propertiesController.text.trim(),
          values: valuesController.text.trim(),
        );

        setState(() {
          soilData = data;
        });


        final box = Hive.box('hive_boxes');
        await box.add({'timestamp': DateTime.now().toString(), 'data': data});
        await FirebaseFirestore.instance.collection('soilData').add({'timestamp': DateTime.now().toString(), 'data': data});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching soil data: $e')),
      );
    } finally {
      setState(() => isLoading = false);
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
        appBar: AppBar(title: Text('Soil Testing',style: TextStyle(color: Colors.white),),backgroundColor: Colors.transparent,toolbarOpacity: 1,),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: Color.fromRGBO(
                255, 255, 255, 0.5568627450980392),borderRadius: BorderRadius.circular(10)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parameters Explanation:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                  ),
                  SizedBox(height: 10),
                  Text('Bulk Density (bdod): Indicates the mass of soil per unit volume.', style: TextStyle(fontSize: 18)),
                  Text('Cation Exchange Capacity (cec): Measures the soil\'s ability to hold cations.', style: TextStyle(fontSize: 18)),
                  Text('Coarse Fragments Volume (cfvo): Percentage of coarse fragments in soil.', style: TextStyle(fontSize: 18)),
                  Text('Clay Content (clay): Percentage of clay particles in the soil.', style: TextStyle(fontSize: 18)),
                  Text('Nitrogen Content (nitrogen): Essential nutrient for plant growth.', style: TextStyle(fontSize: 18)),
                  Text('Organic Carbon Density (ocd): Amount of organic carbon in the soil.', style: TextStyle(fontSize: 18)),
                  Text('Organic Carbon Stock (ocs): Total organic carbon stock in the soil.', style: TextStyle(fontSize: 18)),
                  Text('pH Level (phh2o): Measures the acidity or alkalinity of the soil.', style: TextStyle(fontSize: 18)),
                  Text('Sand Content (sand): Percentage of sand particles in the soil.', style: TextStyle(fontSize: 18)),
                  Text('Silt Content (silt): Percentage of silt particles in the soil.', style: TextStyle(fontSize: 18)),
                  Text('Soil Organic Carbon (soc): Organic carbon content in the soil.', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  TextField(
                    controller: depthsController,
                    decoration: InputDecoration(labelText: 'Depths (e.g., 0-5cm)',labelStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                    style: TextStyle(fontSize: 18),
                  ),
                  TextField(
                    controller: propertiesController,
                    decoration: InputDecoration(labelText: 'Properties (comma-separated)',labelStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                    style: TextStyle(fontSize: 18),
                  ),
                  TextField(
                    controller: valuesController,
                    decoration: InputDecoration(labelText: 'Values (e.g., mean)',labelStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Container(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : getSoilData,
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Get Soil Data Using Current Location', style: TextStyle(fontSize: 15),),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (soilData != null) displaySoilData(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget displaySoilData() {
    if (soilData == null) {
      return const Text('No soil data available.', style: TextStyle(fontSize: 15),);
    }

    var properties = soilData!['properties'];
    if (properties == null || properties['layers'] == null) {
      return Text('Unexpected data format: ${soilData.toString()}');
    }

    List<dynamic> layers = properties['layers'];

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Soil Data:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...layers.map((layer) {
            String propertyName = layer['name'] ?? 'Unknown Property';
            String propertyCode = layer['code'] ?? 'N/A';
            var unitMeasure = layer['unit_measure'];

            if (layer['depths'] != null && layer['depths'].isNotEmpty) {
              var depthInfo = layer['depths'][0];
              var meanValue = depthInfo['values']?['mean'];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main heading in bold
                    Text(
                      '$propertyName ($propertyCode):',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),

                    // Display mean value if available
                    if (meanValue != null && meanValue is num)
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(
                          'Mean Value: $meanValue ${unitMeasure?['target_units'] ?? ''}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      )
                    else if (unitMeasure != null)
                    // Display unit_measure details with indentation
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: unitMeasure.entries.map<Widget>((entry) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                '${entry.key}: ${entry.value}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(left: 12.0),
                        child: Text(
                          'Data not available',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '$propertyName ($propertyCode): Depth data not available',
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }
          }),
        ],
      ),
    );
  }





}
