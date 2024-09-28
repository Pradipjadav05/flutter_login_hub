import 'package:flutter/material.dart';
import 'package:flutter_login_hub/flutter_login_hub.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterLoginHub(
        addRememberMe: true,
        screenHeading: "Register",
        actionButtonName: "Register",
        headingStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 34,
          color: Color.fromRGBO(182, 49, 51, 0.9),
        ),
        image: ImageModel(imgPath:  "assets/login.png",),
        inputFields: {
          "Username": WidgetModel(
            hintText: "Enter username",
            label: "Username",
            // add error msg
            errorMsg: "Enter Username",
          ),
          // check custom validation
          "Mobile No.": WidgetModel(
              hintText: "Enter Mobile No.",
              isNumberField: true,
              label: "Mobile",
              errorMsg: "Enter Mobile",
              maxLength: 10,
              validator: (value){
                if (!RegExp(r'^[0-9]+$').hasMatch(value) || value.length != 10) {
                  return false;
                }
                return true;
              }
          ),
          "Email": WidgetModel(
            hintText: "Enter email",
            errorMsg: "Enter email",
            validationExp: RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
            label: "Email",
          ),
          "Password": WidgetModel(
            hintText: "Enter Password",
            isObscureText: true,
            showHidePassToggle: true,
            isStrongPasswordRequired: true,
            label: "Password",
          ),
        },
        actionButtonStyle: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromRGBO(182, 49, 51, 0.9),
            shape: const RoundedRectangleBorder(),
            textStyle: const TextStyle(fontSize: 22.0,)
        ),
        onProcess: (Map<String, dynamic> processData, {bool isRemember = false}) async{
          if(isRemember){
            // Proceed with further processing like pref, etc.
          }

          // Proceed with further processing like API calls, etc.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Processing Data from main')),
          );

          debugPrint(processData.toString());
        },
      ),
    );
  }
}
