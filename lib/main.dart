import 'package:flutter/material.dart';
import 'dialogflow.dart'; // Import the dialogflowpage.dart file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        primarySwatch: Colors.blue,
      ),
      home: Chatbot(), // Replace MyHomePage with Chatbot
    );
  }
}
