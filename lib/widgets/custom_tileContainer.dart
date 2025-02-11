import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
class CustomContainer extends StatelessWidget {
  final String jsonPath;
  final String displayText;
  final double? width, height;
  final Widget navigator;

  CustomContainer({
    required this.jsonPath,
    required this.displayText,
    this.height,
    this.width,
    required this.navigator,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: height,
        width: width,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Lottie.asset(
                jsonPath,
                repeat: true,
                fit: BoxFit.contain, // Ensure it scales within the container
              ),
            ),
            SizedBox(height: 10), // Add some space between Lottie and Text
            Text(
              displayText,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => navigator),
        );
      },
    );
  }
}
