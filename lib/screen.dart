import 'package:flutter/material.dart';
import 'package:fraud_detection_sys/result.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart' show BackendService;

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController inputController = TextEditingController();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? _errorText;
  bool showResult = false;
  Map<String, dynamic>? _result;

  Future<void> checkForPhishing() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _errorText = null;
      isLoading = true;
      showResult = false; // Reset result
    });

    try {
      final result = await BackendService.validateUrl(
        inputController.text.trim(),
      );
      if (result['status'] == 'error' &&
          result['message'].contains('authenticated')) {
        setState(() {
          _errorText = "Please log in to validate URLs.";
          isLoading = false;
        });
        return;
      }
      setState(() {
        _result = result;
        isLoading = false;
        showResult = true; // Show result
      });
    } catch (e) {
      setState(() {
        _errorText = "Error: $e";
        isLoading = false;
      });
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Analysis complete!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield, color: Color(0xFF5EEAD4)),
                        SizedBox(width: 8),
                        Text(
                          'Big Phisher',
                          style: TextStyle(
                            color: Color(0xFF5EEAD4),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.white70,
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Text('Tips', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 16),
                        Icon(
                          Icons.history_outlined,
                          color: Colors.white70,
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Text('History', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 60),

                // Center icon
                Icon(Icons.search_rounded, size: 60, color: Color(0xFF5EEAD4)),
                SizedBox(height: 24),

                // Main heading
                Text(
                  'Is It a Scam? Leave that to Big Phisher!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),

                // Subtitle
                Text(
                  'Paste any suspicious URL or message below. Our AI will analyze it for potential phishing threats and give you a detailed report. Helping you stay safe online!',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),

                // Input Field
                TextFormField(
                  controller: inputController,
                  style: TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Enter URL or Message",
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Color(0xFF1C1C1C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.greenAccent),
                    ),
                    errorText: _errorText,
                    hintText:
                        "e.g., http://example.com or 'Congratulations! You’ve won...'",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 5) {
                      return "Input must be at least 5 characters long.";
                    }
                    final urlRegex = RegExp(
                      r'^(https?:\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}.*$',
                    );
                    if (!urlRegex.hasMatch(value.trim())) {
                      return "Please enter a valid URL or message.";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                // Check Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF407C78),
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isLoading ? null : checkForPhishing,
                    child: isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Analyzing...",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search),
                              SizedBox(width: 10),
                              Text(
                                "Check for Phishing",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                SizedBox(height: 10),

                if (showResult && _result != null)
                  ResultPage(
                    domain: inputController.text.trim(),
                    status: _result!['status'],
                    message: _result!['message'],
                    customerCare: _result!['customerCare'],
                  ),

                SizedBox(height: 10),

                // Bottom Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFF1C1C1C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Why Use Big Phisher?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5EEAD4),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Phishing attacks are becoming more sophisticated. Big Phisher uses advanced AI and threat intelligence to help you identify malicious links and messages before they can cause harm. Protect your personal information and browse with confidence.',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
