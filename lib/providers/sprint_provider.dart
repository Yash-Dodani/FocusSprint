import 'package:flutter/material.dart';
import '../data/models/sprint.dart';
import '../data/repositories/sprint_repository.dart';
import '../services/local_storage_service.dart';

class SprintProvider extends ChangeNotifier {
  final SprintRepository _repository;
  final LocalStorageService _storage = LocalStorageService();

  SprintProvider(this._repository) {
    _loadFromStorage();
  }

  final List<Sprint> _todaySprints = [];
  int _xp = 0;
  int _streak = 1;
  int _dailyTarget = 10; // default 10 sprints/day

  List<Sprint> get todaySprints => List.unmodifiable(_todaySprints);
  int get xp => _xp;
  int get streak => _streak;
  int get dailyTarget => _dailyTarget;

  int get completedCount => _todaySprints.where((s) => s.completed).length;

  double get todayProgress =>
      _dailyTarget == 0 ? 0 : completedCount / _dailyTarget;

  // ---------- Local load / save ----------

  Future<void> _loadFromStorage() async {
    final state = await _storage.loadState();
    if (state == null) return;

    _xp = state.xp;
    _streak = state.streak;
    _dailyTarget = state.dailyTarget;
    _todaySprints
      ..clear()
      ..addAll(state.sprints);
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storage.saveState(
      xp: _xp,
      streak: _streak,
      dailyTarget: _dailyTarget,
      sprints: _todaySprints,
    );
  }

  // ---------- Public API ----------

  void setDailyTarget(int value) {
    _dailyTarget = value;
    notifyListeners();
    _persist();
  }

  Future<void> addSprint(Sprint sprint) async {
    _todaySprints.insert(0, sprint);
    notifyListeners();
    await _repository.saveSprint(sprint);
    await _persist();
  }

  Future<void> completeSprint(String id, {int gainedXp = 10}) async {
    final index = _todaySprints.indexWhere((s) => s.id == id);
    if (index == -1) return;
    final updated = _todaySprints[index].copyWith(completed: true);
    _todaySprints[index] = updated;
    _xp += gainedXp;
    notifyListeners();
    await _repository.updateSprint(updated);
    await _persist();
  }

  void doubleLastSprintXp() {
    _xp += 10;
    notifyListeners();
    _persist();
  }

  bool canSpendXp(int amount) => _xp >= amount;

  bool spendXp(int amount) {
    if (_xp < amount) return false;
    _xp -= amount;
    notifyListeners();
    _persist();
    return true;
  }

  void addXpFromIap(int amount) {
    // FUTURE: real IAP callback se call karo
    _xp += amount;
    notifyListeners();
    _persist();
  }
}
