import 'package:cloud_firestore/cloud_firestore.dart';

class GamificationService {
  static final _db = FirebaseFirestore.instance;

  static const int pointsPerDose    = 10;
  static const int bonusAllDayDone  = 20;

  static Future<void> onMedicationTaken({
    required String userId,
    required bool allMedsTakenToday,
  }) async {
    final ref = _db.collection('achievements').doc(userId);
    final doc = await ref.get();
    final data = doc.data() ?? {};

    final currentPoints = (data['totalPoints'] ?? 0) as int;
    final currentStreak = (data['streakDays'] ?? 0) as int;
    final lastTaken =
        (data['lastTakenAt'] as Timestamp?)?.toDate();
    final existingBadges =
        List<Map<String, dynamic>>.from(data['badges'] ?? []);

    // Points
    int earned = pointsPerDose;
    if (allMedsTakenToday) earned += bonusAllDayDone;
    final newPoints = currentPoints + earned;

    // Streak
    final now = DateTime.now();
    int newStreak = currentStreak;
    if (allMedsTakenToday) {
      if (lastTaken == null) {
        newStreak = 1;
      } else {
        final diff = now.difference(lastTaken).inDays;
        newStreak = diff == 1 ? currentStreak + 1 : 1;
      }
    }

    // Badges
    final ids =
        existingBadges.map((b) => b['badgeId'] as String).toSet();
    void check(String id, bool cond) {
      if (cond && !ids.contains(id)) {
        existingBadges.add({
          'badgeId': id,
          'earnedAt': FieldValue.serverTimestamp(),
        });
        ids.add(id);
      }
    }

    check('bronze_star',    newPoints >= 50);
    check('silver_achiever', newPoints >= 150);
    check('gold_star',      newPoints >= 300);
    check('weekly_streak',  newStreak >= 7);
    check('discount_coupon', newPoints >= 500);

    // Adherence (simplified)
    final adherence = await _adherence30Days(userId);

    await ref.set({
      'userId': userId,
      'totalPoints': newPoints,
      'streakDays': newStreak,
      'badges': existingBadges,
      'adherencePercent': adherence,
      'lastTakenAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<double> _adherence30Days(String userId) async {
    final since = Timestamp.fromDate(
        DateTime.now().subtract(const Duration(days: 30)));
    final logs = await _db
        .collection('intake_logs')
        .where('userId', isEqualTo: userId)
        .where('takenAt', isGreaterThanOrEqualTo: since)
        .where('status', isEqualTo: 'taken')
        .get();

    final days = <String>{};
    for (final d in logs.docs) {
      final ts = (d.data()['takenAt'] as Timestamp?)?.toDate();
      if (ts != null) {
        days.add('${ts.year}-${ts.month}-${ts.day}');
      }
    }
    return (days.length / 30 * 100).clamp(0, 100);
  }
}
