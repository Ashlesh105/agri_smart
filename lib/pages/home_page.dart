import 'package:agri_smart/pages/signin.dart';
import 'package:agri_smart/pages/soil_testing_page.dart';
import 'package:agri_smart/pages/test_data_page.dart';
import 'package:agri_smart/pages/weather_forecast_page.dart';
import 'package:agri_smart/widgets/custom_tileContainer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<StatefulWidget> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  String username = '';
  bool isLoading = true;
  double? _deviceWidth, _deviceHeight;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserName();
  }

  Future<void> getUserName() async {
    try {
      User? user = await FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            username = userDoc['name'];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/home_pg_bg.jpg'),
                fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: isLoading
                ? CircularProgressIndicator()
                : Container(
                    padding: EdgeInsets.all(10),
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Welcome, ${username!}',
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                    ),
                  ),
            backgroundColor: Colors.transparent,
            toolbarHeight: _deviceHeight! * 0.1,
            actions: [
              IconButton(onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignInScreen()));
              }, icon: Icon(Icons.logout,color: Colors.white,))
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.count(
                crossAxisCount: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
                // Ensures square tiles
                children: [
                  CustomContainer(
                    height: _deviceHeight! * 0.25,
                    width: _deviceWidth! * 0.4,
                    jsonPath: 'assets/custom_containerImages/Soil_testing.json',
                    displayText: 'Soil Testing',
                    navigator: SoilTestScreen(),
                  ),
                  CustomContainer(
                    height: _deviceHeight! * 0.25,
                    width: _deviceWidth! * 0.4,
                    jsonPath:
                        'assets/custom_containerImages/crop_health_monitoring.json',
                    displayText: 'Soil Test History',
                    navigator: TestHistoryScreen(),
                  ),
                  CustomContainer(
                    height: _deviceHeight! * 0.25,
                    width: _deviceWidth! * 0.4,
                    jsonPath:
                        'assets/custom_containerImages/weather_forecast.json',
                    displayText: 'Weather Forecast',
                    navigator: WeatherForecastPage(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
