class TaskModel {
  TaskModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.isDone,
  });

  final String id;
  final String title;
  String subtitle;
  final String badge;
  bool isDone;
}
