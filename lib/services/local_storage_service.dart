import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/sprint.dart';

class LocalState {
  final int xp;
  final int streak;
  final int dailyTarget;
  final List<Sprint> sprints;

  LocalState({
    required this.xp,
    required this.streak,
    required this.dailyTarget,
    required this.sprints,
  });
}

class LocalStorageService {
  static const _keyState = 'focus_sprint_state_v1';

  Future<void> saveState({
    required int xp,
    required int streak,
    required int dailyTarget,
    required List<Sprint> sprints,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'xp': xp,
      'streak': streak,
      'dailyTarget': dailyTarget,
      'todaySprints': sprints.map((s) => s.toMap()).toList(),
    };
    await prefs.setString(_keyState, jsonEncode(map));
  }

  Future<LocalState?> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyState);
    if (jsonString == null) return null;

    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      final xp = map['xp'] as int? ?? 0;
      final streak = map['streak'] as int? ?? 1;
      final dailyTarget = map['dailyTarget'] as int? ?? 5;
      final list = map['todaySprints'] as List<dynamic>? ?? [];
      final sprints = list
          .map((e) => Sprint.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      return LocalState(
        xp: xp,
        streak: streak,
        dailyTarget: dailyTarget,
        sprints: sprints,
      );
    } catch (_) {
      return null;
    }
  }
}
