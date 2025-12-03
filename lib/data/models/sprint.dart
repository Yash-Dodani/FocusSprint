enum SprintCategory {
  study,
  coding,
  reading,
  fitness,
  custom,
}

class Sprint {
  final String id;
  final String title;
  final SprintCategory category;
  final int durationMinutes;
  final DateTime createdAt;
  final bool completed;

  Sprint({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.createdAt,
    this.completed = false,
  });

  Sprint copyWith({
    String? id,
    String? title,
    SprintCategory? category,
    int? durationMinutes,
    DateTime? createdAt,
    bool? completed,
  }) {
    return Sprint(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      createdAt: createdAt ?? this.createdAt,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category.name,
      'durationMinutes': durationMinutes,
      'createdAt': createdAt.toIso8601String(),
      'completed': completed,
    };
  }

  factory Sprint.fromMap(Map<String, dynamic> map) {
    return Sprint(
      id: map['id'] as String,
      title: map['title'] as String,
      category: SprintCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => SprintCategory.custom,
      ),
      durationMinutes: map['durationMinutes'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completed: map['completed'] as bool? ?? false,
    );
  }
}
