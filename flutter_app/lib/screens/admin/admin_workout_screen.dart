import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../models/workout_model.dart';

class AdminWorkoutScreen extends StatefulWidget {
  const AdminWorkoutScreen({super.key});

  @override
  State<AdminWorkoutScreen> createState() => _AdminWorkoutScreenState();
}

class _AdminWorkoutScreenState extends State<AdminWorkoutScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isSeeding = false;
  List<WorkoutModel> _workouts = [];
  String? _selectedCategory;

  final List<String> _categories = ['Chest', 'Back', 'Shoulders', 'Arms', 'Legs', 'Abs', 'Full Body'];
  final List<String> _types = ['exercise', 'game', 'challenge'];
  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

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

  Future<void> _seedWorkouts() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Seed Gym Games'),
        content: const Text('This will replace all existing workout plans with 35 pre-built gym game challenges across 7 body parts. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text('Seed Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isSeeding = true);
    try {
      final response = await _apiService.seedWorkouts();
      if (response.statusCode == 201) {
        final count = response.data['count'];
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Seeded $count gym game challenges!'), backgroundColor: Colors.green),
          );
        }
        await _loadWorkouts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isSeeding = false);
  }

  Future<void> _deleteWorkout(WorkoutModel workout) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Workout'),
        content: Text('Delete "${workout.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _apiService.deleteWorkout(workout.id);
      await _loadWorkouts();
    } catch (_) {}
  }

  void _showAddEditDialog({WorkoutModel? workout}) {
    final titleCtrl = TextEditingController(text: workout?.title ?? '');
    final descCtrl = TextEditingController(text: workout?.description ?? '');
    final durationCtrl = TextEditingController(text: workout?.duration ?? '');
    final targetRepsCtrl = TextEditingController(text: workout?.targetReps ?? '');
    String category = workout?.category ?? 'Chest';
    String type = workout?.type ?? 'game';
    String difficulty = workout?.difficulty ?? 'Beginner';
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(workout == null ? '➕ Add Workout Plan' : '✏️ Edit Workout Plan',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField('Title', titleCtrl),
                const SizedBox(height: 12),
                _dialogField('Description', descCtrl, maxLines: 3),
                const SizedBox(height: 12),
                _dialogDropdown('Category', category, _categories, (v) => setDialogState(() => category = v!)),
                const SizedBox(height: 12),
                _dialogDropdown('Type', type, _types, (v) => setDialogState(() => type = v!)),
                const SizedBox(height: 12),
                _dialogDropdown('Difficulty', difficulty, _difficulties, (v) => setDialogState(() => difficulty = v!)),
                const SizedBox(height: 12),
                _dialogField('Duration (e.g. 1 min)', durationCtrl),
                const SizedBox(height: 12),
                _dialogField('Target / Goal (e.g. Max reps)', targetRepsCtrl),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (titleCtrl.text.trim().isEmpty) return;
                      setDialogState(() => isSaving = true);
                      try {
                        final data = {
                          'title': titleCtrl.text.trim(),
                          'description': descCtrl.text.trim(),
                          'category': category,
                          'type': type,
                          'difficulty': difficulty,
                          'duration': durationCtrl.text.trim(),
                          'targetReps': targetRepsCtrl.text.trim(),
                        };
                        if (workout == null) {
                          await _apiService.createWorkout(data);
                        } else {
                          await _apiService.updateWorkout(workout.id, data);
                        }
                        if (mounted) Navigator.pop(ctx);
                        await _loadWorkouts();
                      } catch (_) {
                        setDialogState(() => isSaving = false);
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(workout == null ? 'Add' : 'Save', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _dialogDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Chest': return Colors.red.shade400;
      case 'Back': return Colors.blue.shade400;
      case 'Legs': return Colors.green.shade500;
      case 'Arms': return Colors.orange.shade400;
      case 'Shoulders': return Colors.purple.shade400;
      case 'Abs': return Colors.teal.shade400;
      case 'Full Body': return Colors.deepPurple.shade400;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Workout Plans', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isSeeding ? null : _seedWorkouts,
            icon: _isSeeding
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.auto_fix_high),
            tooltip: 'Seed 35 Gym Games',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats banner
          Container(
            color: Colors.deepPurple,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _statPill('Total', _workouts.length.toString(), Icons.fitness_center),
                const SizedBox(width: 12),
                _statPill('Games', _workouts.where((w) => w.type == 'game').length.toString(), Icons.sports_esports),
                const SizedBox(width: 12),
                _statPill('Challenges', _workouts.where((w) => w.type == 'challenge').length.toString(), Icons.emoji_events),
              ],
            ),
          ),
          // Category filter
          Container(
            color: Colors.white,
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _chip('All', null),
                ..._categories.map((c) => _chip(c, c)),
              ],
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
                            Text('No workout plans yet.', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _seedWorkouts,
                              icon: const Icon(Icons.auto_fix_high),
                              label: const Text('Seed 35 Gym Games'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadWorkouts,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _workouts.length,
                          itemBuilder: (ctx, i) => _buildWorkoutCard(_workouts[i]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Plan'),
      ),
    );
  }

  Widget _statPill(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text('$value $label', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String? cat) {
    final selected = _selectedCategory == cat;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
        selected: selected,
        selectedColor: Colors.deepPurple.shade100,
        checkmarkColor: Colors.deepPurple,
        onSelected: (v) {
          setState(() => _selectedCategory = v ? cat : null);
          _loadWorkouts();
        },
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutModel w) {
    final color = _categoryColor(w.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14))),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_typeIcon(w.type), size: 16, color: color),
                        const SizedBox(width: 6),
                        Expanded(child: Text(w.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                        IconButton(
                          onPressed: () => _showAddEditDialog(workout: w),
                          icon: const Icon(Icons.edit, size: 18),
                          color: Colors.blue,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _deleteWorkout(w),
                          icon: const Icon(Icons.delete, size: 18),
                          color: Colors.red,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    if (w.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(w.description, style: TextStyle(color: Colors.grey[600], fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _tag(w.category, color.withOpacity(0.15), color),
                        _tag(w.difficulty, _diffColor(w.difficulty).withOpacity(0.15), _diffColor(w.difficulty)),
                        if (w.duration.isNotEmpty) _tag('⏱ ${w.duration}', Colors.blue.shade50, Colors.blue.shade700),
                        if (w.targetReps.isNotEmpty) _tag('🎯 ${w.targetReps}', Colors.green.shade50, Colors.green.shade700),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _diffColor(String d) {
    switch (d) {
      case 'Beginner': return Colors.green;
      case 'Intermediate': return Colors.orange;
      case 'Advanced': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _tag(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
