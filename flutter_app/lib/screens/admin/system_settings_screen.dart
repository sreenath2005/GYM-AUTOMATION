import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final TextEditingController _gymNameController = TextEditingController();
  final TextEditingController _gymAddressController = TextEditingController();
  final TextEditingController _gymPhoneController = TextEditingController();
  final TextEditingController _gymEmailController = TextEditingController();

  final Map<String, double> _planPrices = {
    '1 Month': 1000,
    '3 Months': 2700,
    '6 Months': 4800,
    '1 Year': 8400,
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _gymNameController.dispose();
    _gymAddressController.dispose();
    _gymPhoneController.dispose();
    _gymEmailController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    // In production, load from backend
    _gymNameController.text = 'My Gym';
    _gymAddressController.text = '123 Fitness Street';
    _gymPhoneController.text = '+91 1234567890';
    _gymEmailController.text = 'gym@example.com';
  }

  Future<void> _saveSettings() async {
    // In production, save to backend
    Fluttertoast.showToast(msg: 'Settings saved successfully');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gym Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _gymNameController,
                      decoration: InputDecoration(
                        labelText: 'Gym Name',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _gymAddressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _gymPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _gymEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Membership Plan Prices',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ..._planPrices.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: TextFormField(
                                initialValue: entry.value.toStringAsFixed(0),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  prefixText: '₹',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onChanged: (value) {
                                  final price = double.tryParse(value);
                                  if (price != null) {
                                    _planPrices[entry.key] = price;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
