import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URL Validator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController();
  List<Map<String, dynamic>> _processSteps =
      []; // Store step text and completion status
  String _finalResult = '';
  Color _resultColor = Colors.black;
  String _customerCare = '';

  Future<void> _validateUrl() async {
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      setState(() {
        _processSteps = [
          {'text': 'Please enter a URL.', 'completed': true},
        ];
        _finalResult = '';
        _customerCare = '';
      });
      return;
    }

    setState(() {
      _processSteps = [
        {'text': 'Starting validation...', 'completed': false},
        {'text': 'Rolling carousel...', 'completed': false},
      ];
      _finalResult = '';
      _customerCare = '';
    });

    try {
      // Simulate process steps with rolling icons
      await _updateStep('Checking domain...');
      await Future.delayed(const Duration(milliseconds: 300));

      await _updateStep('Domain confirmed.');
      await Future.delayed(const Duration(milliseconds: 300));

      await _updateStep('Performing DNS query...');
      await Future.delayed(const Duration(milliseconds: 300));

      await _updateStep('Validating SSL certificate...');
      await Future.delayed(const Duration(milliseconds: 300));

      // Call backend
      final response = await http.post(
        Uri.parse(
          'http://10.0.2.2:5000/validate',
        ), // Use your IP (e.g., 192.168.100.34 for device)
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _processSteps.add({
            'text': 'Validation complete.',
            'completed': true,
          });
          _finalResult = data['message'];
          _resultColor = data['status'] == 'safe'
              ? Colors.green
              : data['status'] == 'phishing'
              ? Colors.red
              : data['status'] == 'invalid'
              ? Colors.orange
              : Colors.orange; // uncertain
          _customerCare = data['customerCare'] ?? '';
        });
      } else {
        setState(() {
          _processSteps.add({'text': 'Validation failed.', 'completed': true});
          _finalResult = 'Error: ${response.body}';
          _resultColor = Colors.red;
          _customerCare = '';
        });
      }
    } catch (e) {
      setState(() {
        _processSteps.add({'text': 'Connection error.', 'completed': true});
        _finalResult = 'Error connecting to backend: $e';
        _resultColor = Colors.red;
        _customerCare = '';
      });
    }
  }

  Future<void> _updateStep(String text) async {
    setState(() {
      _processSteps.add({'text': text, 'completed': false});
    });
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _processSteps.last['completed'] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('URL Valdator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Paste URL here',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _validateUrl,
              child: const Text('Validate URL'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 70, // Fixed height to limit space for the details part
              child: ListView.builder(
                itemCount: _processSteps.length,
                itemBuilder: (context, index) {
                  final step = _processSteps[index];
                  return ListTile(
                    leading: step['completed']
                        ? const Icon(Icons.check, color: Colors.green, size: 16)
                        : const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                            strokeWidth: 2,
                            value: null,
                          ),
                    title: Text(
                      step['text'],
                      style: TextStyle(
                        color:
                            index == _processSteps.length - 1 &&
                                step['completed']
                            ? _resultColor
                            : Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 2.0),
                  );
                },
              ),
            ),
            // if (_finalResult.isEmpty) ...[
            //   const SizedBox(height: 16),
            //   Text(
            //     _finalResult,
            //     style: TextStyle(color: _resultColor, fontSize: 16),
            //   ),
            // ],
            // if (_customerCare.isNotEmpty) ...[
            //   const SizedBox(height: 16),
            //   Text(
            //     'Contact customer care: $_customerCare',
            //     style: const TextStyle(fontSize: 14, color: Colors.blue),
            //   ),
            //],
          ],
        ),
      ),
    );
  }
}
