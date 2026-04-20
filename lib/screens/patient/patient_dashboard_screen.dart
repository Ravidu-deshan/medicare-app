import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../services/gamification_service.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});
  @override
  State<PatientDashboardScreen> createState() =>
      _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  int _tab = 0;
  String _userName = '';
  int _streak = 0;
  int _points = 0;
  double _adherence = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final userDoc = await FirebaseFirestore.instance
        .collection('users').doc(uid).get();
    final achDoc = await FirebaseFirestore.instance
        .collection('achievements').doc(uid).get();
    if (mounted) {
      setState(() {
        _userName   = userDoc.data()?['name'] ?? '';
        _streak     = achDoc.data()?['streakDays'] ?? 0;
        _points     = achDoc.data()?['totalPoints'] ?? 0;
        _adherence  =
            (achDoc.data()?['adherencePercent'] ?? 0.0).toDouble();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('MediCare'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushReplacementNamed(
                  context, AppRoutes.roleSelection);
            },
          )
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          _TodayTab(
              userName: _userName,
              streak: _streak,
              points: _points,
              adherence: _adherence),
          const _PlaceholderTab('Medications', 'Sprint 2'),
          const _PlaceholderTab('Orders', 'Sprint 5'),
          const _PlaceholderTab('Profile', 'Sprint 2'),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Today'),
          NavigationDestination(
              icon: Icon(Icons.medication_outlined),
              selectedIcon: Icon(Icons.medication),
              label: 'Medications'),
          NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined),
              selectedIcon: Icon(Icons.shopping_bag),
              label: 'Orders'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.addMedication)
                      .then((_) => _load()),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

// ── TODAY TAB ─────────────────────────────────────────────
class _TodayTab extends StatelessWidget {
  final String userName;
  final int streak;
  final int points;
  final double adherence;

  const _TodayTab(
      {required this.userName,
      required this.streak,
      required this.points,
      required this.adherence});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Hello, $userName 👋',
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        const Text("Here are today's medications",
            style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),

        // Stats row
        Row(children: [
          _Stat(Icons.local_fire_department,
              '$streak Day Streak', AppColors.streak),
          const SizedBox(width: 8),
          _Stat(Icons.star, '$points pts', AppColors.gold),
          const SizedBox(width: 8),
          _Stat(Icons.check_circle,
              '${adherence.toStringAsFixed(0)}%', AppColors.success),
        ]),
        const SizedBox(height: 12),

        // Progress & Rewards button
        OutlinedButton.icon(
          icon: const Icon(Icons.emoji_events_outlined),
          label: const Text('View Progress & Rewards'),
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.progressRewards),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),

        const Text("Today's Medications",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('medications')
              .where('userId', isEqualTo: uid)
              .where('isActive', isEqualTo: true)
              .snapshots(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) return _EmptyState();
            return Column(
              children: docs
                  .map((doc) =>
                      _MedTile(doc: doc, userId: uid))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Stat(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      );
}

class _MedTile extends StatefulWidget {
  final QueryDocumentSnapshot doc;
  final String userId;
  const _MedTile({required this.doc, required this.userId});
  @override
  State<_MedTile> createState() => _MedTileState();
}

class _MedTileState extends State<_MedTile> {
  bool _taken = false;
  bool _loading = false;

  Future<void> _markTaken() async {
    if (_taken || _loading) return;
    setState(() => _loading = true);

    final data = widget.doc.data() as Map<String, dynamic>;

    // Log intake
    await FirebaseFirestore.instance.collection('intake_logs').add({
      'userId': widget.userId,
      'medicationId': widget.doc.id,
      'scheduledTime': data['time'] ?? '',
      'status': 'taken',
      'takenAt': FieldValue.serverTimestamp(),
    });

    // Update gamification
    await GamificationService.onMedicationTaken(
      userId: widget.userId,
      allMedsTakenToday: false, // simplified — full check in Sprint 3
    );

    setState(() {
      _taken = true;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data() as Map<String, dynamic>;
    final name   = data['medicineName'] ?? 'Unknown';
    final time   = data['time'] ?? '--:--';
    final dosage = data['dosage'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medication,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                Text('$time  ·  $dosage',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          if (_loading)
            const SizedBox(
                width: 24,
                height: 24,
                child:
                    CircularProgressIndicator(strokeWidth: 2))
          else if (_taken)
            _StatusBadge('Taken', AppColors.success)
          else
            GestureDetector(
                onTap: _markTaken,
                child: _StatusBadge('Take Now', AppColors.warning)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style:
                const TextStyle(color: Colors.white, fontSize: 12)),
      );
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            const Icon(Icons.medication_outlined,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            const Text('No medications yet',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Tap + to add your first medication',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      );
}

class _PlaceholderTab extends StatelessWidget {
  final String title;
  final String sprint;
  const _PlaceholderTab(this.title, this.sprint);
  @override
  Widget build(BuildContext context) => Center(
        child: Text('$title — coming in $sprint',
            style:
                const TextStyle(color: AppColors.textSecondary)),
      );
}
