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
        addRememberMe: false,
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
            fieldType: WidgetType.username,
            label: "Username",
          ),
          "Mobile No.": WidgetModel(
            hintText: "Enter Mobile No.",
            fieldType: WidgetType.mobile,
            label: "Mobile",
          ),
          "Email": WidgetModel(
            hintText: "Enter email",
            fieldType: WidgetType.email,
            label: "Email",
          ),
          "Password": WidgetModel(
            hintText: "Enter Password",
            fieldType: WidgetType.password,
            label: "Password",
          ),

          // check custom validation
         /* "temp": WidgetModel(
            hintText: "Enter name",
            fieldType: WidgetType.username,
            label: "temp",
            validator: (value) {
              if (value.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter value')),);
                return false;
              }
              return true;
            },
          ),*/
        },
        actionButtonStyle: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromRGBO(182, 49, 51, 0.9),
          shape: const RoundedRectangleBorder(),
          textStyle: const TextStyle(fontSize: 22.0,)
        ),
        onProcess: (Map<String, dynamic> processData, {bool? isRemember}) {
          if(isRemember != null && isRemember){
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
