import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // ── Medications ───────────────────────────────────────
  static Future<DocumentReference> addMedication({
    required String userId,
    required String medicineName,
    required String dosage,
    required String frequency,
    required String time,
    required List<String> days,
    String notes = '',
  }) {
    return _db.collection('medications').add({
      'userId': userId,
      'medicineName': medicineName,
      'dosage': dosage,
      'frequency': frequency,
      'time': time,
      'days': days,
      'notes': notes,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> medicationsStream(String userId) {
    return _db
        .collection('medications')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  static Future<void> deleteMedication(String docId) {
    return _db
        .collection('medications')
        .doc(docId)
        .update({'isActive': false});
  }

  // ── Intake logs ───────────────────────────────────────
  static Future<DocumentReference> logIntake({
    required String userId,
    required String medicationId,
    required String scheduledTime,
    String status = 'taken',
  }) {
    return _db.collection('intake_logs').add({
      'userId': userId,
      'medicationId': medicationId,
      'scheduledTime': scheduledTime,
      'status': status,
      'takenAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Orders ────────────────────────────────────────────
  static Future<DocumentReference> createOrder({
    required String patientId,
    required String pharmacyId,
    required List<String> medicines,
  }) {
    return _db.collection('orders').add({
      'patientId': patientId,
      'pharmacyId': pharmacyId,
      'agentId': '',
      'medicines': medicines,
      'status': 'pending',
      'totalAmount': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Live location ─────────────────────────────────────
  static Future<void> updateAgentLocation({
    required String agentId,
    required String orderId,
    required double latitude,
    required double longitude,
  }) {
    return _db.collection('locations').doc('${agentId}_$orderId').set({
      'agentId': agentId,
      'orderId': orderId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
