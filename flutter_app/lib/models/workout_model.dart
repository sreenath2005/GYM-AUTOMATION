class WorkoutModel {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String category;
  final String type;
  final String difficulty;
  final String duration;
  final String targetReps;

  WorkoutModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.category,
    this.type = 'exercise',
    this.difficulty = 'Beginner',
    this.duration = '',
    this.targetReps = '',
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      category: json['category'] ?? '',
      type: json['type'] ?? 'exercise',
      difficulty: json['difficulty'] ?? 'Beginner',
      duration: json['duration'] ?? '',
      targetReps: json['targetReps'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'category': category,
      'type': type,
      'difficulty': difficulty,
      'duration': duration,
      'targetReps': targetReps,
    };
  }
}
