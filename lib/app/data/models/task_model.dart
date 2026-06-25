class TaskModel {
  TaskModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.isDone,
    this.createdAt,
    this.scheduledAt,
    this.notes,
  });

  final String id;
  final String title;
  String subtitle;
  final String badge;
  bool isDone;
  final DateTime? createdAt;
  final DateTime? scheduledAt;
  final String? notes;
}
