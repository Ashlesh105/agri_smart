import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool obscureText = true;

  Future<void> signUp() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      User? user = userCredential.user;

      if(user!=null){
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name':nameController.text.trim(),
          'email':emailController.text.trim(),
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign Up Successful')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign Up Failed: ${e.toString()}')),
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
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: Container(
              height: 500,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Create Account',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    SizedBox(height: 20),
                    CustomTextField(hintText: 'Full Name', icon: Icons.person, controller: nameController),
                    SizedBox(height: 20),
                    CustomTextField(hintText: 'Email', icon: Icons.email, controller: emailController),
                    SizedBox(height: 20),
                    CustomTextField(
                      hintText: 'Password',
                      icon: Icons.lock,
                      isPassword: true,
                      controller: passwordController,
                      obscureText: obscureText,
                      toggleVisibility: () {
                        setState(() => obscureText = !obscureText);
                      },
                    ),
                    SizedBox(height: 30),
                    CustomButton(text: 'Sign Up', onPressed: signUp, isLoading: isLoading),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        decoration: BoxDecoration(color: Color.fromRGBO(
                            255, 255, 255, 0.7725490196078432),borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          'Already have an account? Sign In',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

