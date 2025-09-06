import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth.dart';
import 'auth_service.dart';
import 'result.dart';
import 'screen.dart' show HomePage;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Generated file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Big Phisher Tester',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF0E0E0E),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: AuthPage(),
    );
  }
}

/// Backend service for validation
class BackendService {
  static Future<Map<String, dynamic>> validateUrl(String url) async {
    if (url.trim().isEmpty) {
      return {
        "status": "invalid",
        "message": "Please enter a URL.",
        "customerCare": "",
      };
    }

    try {
      final idToken = await AuthService.getIdToken(); // Requires AuthService
      if (idToken == null) {
        return {
          "status": "error",
          "message": "Not authenticated. Please log in.",
          "customerCare": "",
        };
      }

      final response = await http.post(
        Uri.parse(
          'https://backend-wszk.onrender.com/validate',
          //'http://10.0.2.2:5000/validate',
        ), // Use 192.168.100.37 for physical device
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url, 'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "error",
          "message": "Error: ${response.body}",
          "customerCare": "",
        };
      }
    } catch (e) {
      return {
        "status": "error",
        "message": "Error connecting to backend: $e",
        "customerCare": "",
      };
    }
  }
}
