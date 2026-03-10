import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../models/workout_model.dart';

class UserWorkoutScreen extends StatefulWidget {
  const UserWorkoutScreen({super.key});

  @override
  State<UserWorkoutScreen> createState() => _UserWorkoutScreenState();
}

class _UserWorkoutScreenState extends State<UserWorkoutScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<WorkoutModel> _workouts = [];
  String? _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.apps, 'color': Colors.deepPurple},
    {'name': 'Chest', 'icon': Icons.accessibility_new, 'color': Colors.red},
    {'name': 'Back', 'icon': Icons.airline_seat_flat, 'color': Colors.blue},
    {'name': 'Legs', 'icon': Icons.directions_walk, 'color': Colors.green},
    {'name': 'Arms', 'icon': Icons.fitness_center, 'color': Colors.orange},
    {'name': 'Shoulders', 'icon': Icons.sports_gymnastics, 'color': Colors.purple},
    {'name': 'Abs', 'icon': Icons.self_improvement, 'color': Colors.teal},
    {'name': 'Full Body', 'icon': Icons.sports_martial_arts, 'color': Colors.indigo},
  ];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getWorkouts(category: _selectedCategory);
      if (response.statusCode == 200 && response.data['success']) {
        setState(() {
          _workouts = (response.data['data'] as List).map((j) => WorkoutModel.fromJson(j)).toList();
        });
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Chest': return Colors.red.shade500;
      case 'Back': return Colors.blue.shade500;
      case 'Legs': return Colors.green.shade600;
      case 'Arms': return Colors.orange.shade500;
      case 'Shoulders': return Colors.purple.shade500;
      case 'Abs': return Colors.teal.shade500;
      case 'Full Body': return Colors.indigo.shade500;
      default: return Colors.deepPurple;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Chest': return Icons.accessibility_new;
      case 'Back': return Icons.airline_seat_flat;
      case 'Legs': return Icons.directions_walk;
      case 'Arms': return Icons.fitness_center;
      case 'Shoulders': return Icons.sports_gymnastics;
      case 'Abs': return Icons.self_improvement;
      case 'Full Body': return Icons.sports_martial_arts;
      default: return Icons.fitness_center;
    }
  }

  Color _diffColor(String d) {
    switch (d) {
      case 'Beginner': return Colors.green;
      case 'Intermediate': return Colors.orange;
      case 'Advanced': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'game': return Icons.sports_esports;
      case 'challenge': return Icons.emoji_events;
      default: return Icons.fitness_center;
    }
  }

  // Group workouts by category
  Map<String, List<WorkoutModel>> _grouped() {
    final Map<String, List<WorkoutModel>> map = {};
    for (final w in _workouts) {
      map.putIfAbsent(w.category, () => []).add(w);
    }
    return map;
  }

  void _showDetail(WorkoutModel w) {
    final color = _categoryColor(w.category);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: ctrl,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, color.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_typeIcon(w.type), color: Colors.white, size: 28),
                          const SizedBox(width: 10),
                          Expanded(child: Text(w.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (w.description.isNotEmpty)
                        Text(w.description, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _detailCard('Category', w.category, Icons.category, color),
                      const SizedBox(width: 12),
                      _detailCard('Difficulty', w.difficulty, Icons.bar_chart, _diffColor(w.difficulty)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _detailCard('Duration', w.duration.isNotEmpty ? w.duration : '-', Icons.timer, Colors.blue),
                      const SizedBox(width: 12),
                      _detailCard('Target', w.targetReps.isNotEmpty ? w.targetReps : '-', Icons.flag, Colors.green),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _selectedCategory == null ? _grouped() : {_selectedCategory!: _workouts};

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Workout Plans', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header banner
          Container(
            color: Colors.deepPurple,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💪 Gym Challenges & Games', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text('${_workouts.length} Plans Available', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Category scroll row
          Container(
            color: Colors.white,
            height: 82,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final name = cat['name'] as String;
                final isAll = name == 'All';
                final catKey = isAll ? null : name;
                final selected = _selectedCategory == catKey;
                final color = cat['color'] as Color;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = catKey);
                    _loadWorkouts();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? color : color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? color : color.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat['icon'] as IconData, size: 16, color: selected ? Colors.white : color),
                        const SizedBox(width: 6),
                        Text(name, style: TextStyle(color: selected ? Colors.white : color, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
                : _workouts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fitness_center, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text('No workout plans available yet.', style: TextStyle(color: Colors.grey[500])),
                            const SizedBox(height: 4),
                            Text('Ask your gym owner to add plans!', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadWorkouts,
                        child: ListView(
                          padding: const EdgeInsets.all(12),
                          children: [
                            // If showing all, group by category
                            if (_selectedCategory == null)
                              ...grouped.entries.map((entry) => _buildCategorySection(entry.key, entry.value)).toList()
                            else
                              ..._workouts.map(_buildWorkoutCard).toList(),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category, List<WorkoutModel> workouts) {
    final color = _categoryColor(category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(_categoryIcon(category), color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(category, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(width: 8),
              Text('${workouts.length} plans', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
        ),
        ...workouts.map(_buildWorkoutCard).toList(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildWorkoutCard(WorkoutModel w) {
    final color = _categoryColor(w.category);
    return GestureDetector(
      onTap: () => _showDetail(w),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Color bar
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
                ),
              ),
              // Icon circle
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(_typeIcon(w.type), color: color, size: 22),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(w.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      if (w.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(w.description, style: TextStyle(color: Colors.grey[500], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: [
                          _tag(w.difficulty, _diffColor(w.difficulty)),
                          if (w.duration.isNotEmpty) _tag('⏱ ${w.duration}', Colors.blue),
                          if (w.targetReps.isNotEmpty) _tag('🎯 ${w.targetReps}', Colors.green.shade700),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[300]),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
