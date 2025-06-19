class Todo {
  final String id;
  final String title;
  final String description;
  final bool completed;
  final DateTime creationDate;
  final String category;
  final DateTime? dueDate;
  final String userId;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.creationDate,
    required this.category,
    this.dueDate,
    required this.userId,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    DateTime? creationDate,
    String? category,
    DateTime? dueDate,
    String? userId,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      creationDate: creationDate ?? this.creationDate,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'creationDate': creationDate.toIso8601String(),
      'category': category,
      'dueDate': dueDate?.toIso8601String(),
      'userId': userId,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      completed: json['completed'],
      creationDate: DateTime.parse(json['creationDate']),
      category: json['category'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      userId: json['userId'],
    );
  }

  factory Todo.fromApiJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'].toString(),
      title: json['todo'] ?? '',
      description: '', // No description in API, set as empty
      completed: json['completed'] ?? false,
      creationDate: DateTime.now(), // No creationDate in API, set as now
      category: '', // No category in API, set as empty
      dueDate: null, // No dueDate in API, set as null
      userId: json['userId'].toString(),
    );
  }

  bool get isOverdue {
    if (dueDate?.isBefore(DateTime.now()) ?? false || completed) return false;
    return true;
  }

  String get formattedCreationDate {
    return '${creationDate.day}/${creationDate.month}/${creationDate.year}';
  }

  String get formattedDueDate {
    return '${dueDate?.day}/${dueDate?.month}/${dueDate?.year}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, completed: $completed)';
  }
} 