import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _chestController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _armsController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _progressHistory = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _armsController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    // In a real app, load from backend
    // For now, load from local storage or show empty
    setState(() {
      _progressHistory = [];
    });
  }

  Future<void> _saveProgress() async {
    if (_weightController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter at least your weight');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final progressData = {
        'weight': double.tryParse(_weightController.text) ?? 0,
        'chest': _chestController.text.isNotEmpty ? double.tryParse(_chestController.text) : null,
        'waist': _waistController.text.isNotEmpty ? double.tryParse(_waistController.text) : null,
        'arms': _armsController.text.isNotEmpty ? double.tryParse(_armsController.text) : null,
        'date': DateTime.now().toIso8601String(),
      };

      // In production, save to backend
      // For now, add to local list
      setState(() {
        _progressHistory.insert(0, progressData);
        _progressHistory = _progressHistory.take(10).toList(); // Keep last 10 entries
        _weightController.clear();
        _chestController.clear();
        _waistController.clear();
        _armsController.clear();
        _isLoading = false;
      });

      Fluttertoast.showToast(msg: 'Progress saved successfully');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracking'),
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
                      'Record Your Progress',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        prefixIcon: Icon(Icons.monitor_weight),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _chestController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Chest (inches)',
                        prefixIcon: Icon(Icons.straighten),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _waistController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Waist (inches)',
                        prefixIcon: Icon(Icons.straighten),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _armsController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Arms (inches)',
                        prefixIcon: Icon(Icons.straighten),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProgress,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text('Save Progress'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Progress History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _progressHistory.isEmpty
                ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.trending_up, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No progress records yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Start tracking your fitness journey!',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _progressHistory.length,
                    itemBuilder: (context, index) {
                      final progress = _progressHistory[index];
                      final date = DateTime.parse(progress['date']);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                            child: Icon(Icons.fitness_center, color: Colors.white),
                          ),
                          title: Text(
                            DateFormat('MMM dd, yyyy').format(date),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Weight: ${progress['weight']} kg'),
                              if (progress['chest'] != null)
                                Text('Chest: ${progress['chest']} inches'),
                              if (progress['waist'] != null)
                                Text('Waist: ${progress['waist']} inches'),
                              if (progress['arms'] != null)
                                Text('Arms: ${progress['arms']} inches'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
