import '../models/sprint.dart';

class SprintRepository {
  // final _db = FirebaseFirestore.instance; // when ready

  Future<void> saveSprint(Sprint sprint) async {
    // try {
    //   await _db
    //       .collection('users')
    //       .doc('<USER_ID>')
    //       .collection('sprints')
    //       .doc(sprint.id)
    //       .set(sprint.toMap());
    // } catch (_) {
    //   // ignore errors for now
    // }
  }

  Future<void> updateSprint(Sprint sprint) async {
    // try {
    //   await _db
    //       .collection('users')
    //       .doc('<USER_ID>')
    //       .collection('sprints')
    //       .doc(sprint.id)
    //       .update(sprint.toMap());
    // } catch (_) {}
  }
}
