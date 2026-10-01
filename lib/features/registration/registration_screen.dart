import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  String? _selectedShakha;
  List<Map<String, dynamic>> _shakhas = [];
  bool _isLoading = false;
  bool _showQR = false;

  @override
  void initState() {
    super.initState();
    _loadShakhas();
  }

  Future<void> _loadShakhas() async {
    try {
      final csvData = await rootBundle.loadString('assets/shakhas.csv');
      final lines = csvData.split('\n').skip(1); // skip header
      setState(() {
        _shakhas = lines
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.split(','))
            .map((parts) => {
                  'id': parts[0],
                  'name': parts[1],
                  'active': parts[2] == 'true',
                })
            .where((shakha) => shakha['active'] == true)
            .toList();
      });
    } catch (e) {
      // fallback
      setState(() {
        _shakhas = [
          {'id': '1', 'name': 'Bijwasan', 'active': true},
          {'id': '2', 'name': 'Mehrauli', 'active': true},
          {'id': '3', 'name': 'Other', 'active': true},
        ];
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    // For demo, we just show QR; in real app we'd send to server and get signed QR
    setState(() {
      _isLoading = false;
      _showQR = true;
      // Create a simple QR image as bytes (using qr_flutter would require rendering to image)
      // We'll just show the qr_flutter widget directly, so we don't need to convert to bytes now.
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: _showQR
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Registration Successful!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  QrImageView(
                    data: jsonEncode({
                      'name': _nameController.text.trim(),
                      'shakha': _selectedShakha,
                      'mobile': _mobileController.text.trim(),
                      'timestamp': DateTime.now().toIso8601String(),
                    }),
                    version: QrVersions.auto,
                    size: 200.0,
                    gapless: false,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showQR = false;
                        _nameController.clear();
                        _mobileController.clear();
                        _selectedShakha = null;
                      });
                    },
                    child: const Text('Register Another'),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Shakha',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: _selectedShakha,
                            items: _shakhas
                                .map((shakha) => DropdownMenuItem<String>(
                                      value: shakha['id'] as String,
                                      child: Text(shakha['name'] as String),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedShakha = value);
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a shakha';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _mobileController,
                            decoration: const InputDecoration(
                              labelText: 'Mobile Number',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your mobile number';
                              }
                              if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                                return 'Please enter a valid 10-digit mobile number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _register,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Register and Get QR'),
                          ),
                        ],
                      ),
                    ),
            ),
    );
  }
}