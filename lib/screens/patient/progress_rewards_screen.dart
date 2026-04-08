import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';

class ProgressRewardsScreen extends StatelessWidget {
  const ProgressRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Progress & Rewards')),
      backgroundColor: AppColors.background,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('achievements')
            .doc(uid)
            .snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = snap.data!.data() as Map<String, dynamic>? ?? {};
          final streak    = (d['streakDays'] ?? 0) as int;
          final adherence =
              (d['adherencePercent'] ?? 0.0).toDouble();
          final points    = (d['totalPoints'] ?? 0) as int;
          final badges    =
              List<Map<String, dynamic>>.from(d['badges'] ?? []);
          final badgeIds  =
              badges.map((b) => b['badgeId'] as String).toSet();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Adherence card ──────────────────────────
              _Card(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Adherence This Month',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                      Text(
                        '${adherence.toStringAsFixed(0)}%',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: adherence / 100,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    const Icon(Icons.local_fire_department,
                        color: AppColors.streak, size: 28),
                    const SizedBox(width: 8),
                    Text('$streak Days',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.streak)),
                    const SizedBox(width: 8),
                    const Text('Current streak',
                        style: TextStyle(
                            color: AppColors.textSecondary)),
                  ]),
                ],
              )),
              const SizedBox(height: 12),

              // ── Points ──────────────────────────────────
              _Card(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Earned Points',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('$points pts',
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                ],
              )),
              const SizedBox(height: 16),

              // ── Badges ──────────────────────────────────
              const Text('Rewards Earned',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Row(children: [
                _Badge('Bronze Badge', '50 pts',
                    AppColors.bronze, Icons.star,
                    badgeIds.contains('bronze_star')),
                const SizedBox(width: 10),
                _Badge('Silver Badge', '150 pts',
                    AppColors.silver, Icons.star,
                    badgeIds.contains('silver_achiever')),
                const SizedBox(width: 10),
                _Badge('Gold Star', '300 pts',
                    AppColors.gold, Icons.star,
                    badgeIds.contains('gold_star')),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                _Badge('Weekly Streak', '7 days',
                    AppColors.streak,
                    Icons.local_fire_department,
                    badgeIds.contains('weekly_streak')),
                const SizedBox(width: 10),
                _Badge('Discount Coupon', '20% OFF',
                    AppColors.secondary, Icons.local_offer,
                    badgeIds.contains('discount_coupon')),
                const Expanded(child: SizedBox()),
              ]),
              const SizedBox(height: 20),

              // ── Monthly calendar ─────────────────────────
              const Text('Monthly Calendar',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              _MonthlyCalendar(uid: uid),
            ],
          );
        },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: child,
      );
}

class _Badge extends StatelessWidget {
  final String label;
  final String sub;
  final Color color;
  final IconData icon;
  final bool earned;

  const _Badge(this.label, this.sub, this.color, this.icon, this.earned);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: earned
                ? color.withOpacity(0.12)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: earned
                    ? color.withOpacity(0.4)
                    : Colors.grey.shade300),
          ),
          child: Column(children: [
            Icon(icon,
                size: 32,
                color: earned ? color : Colors.grey.shade400),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: earned
                        ? color
                        : AppColors.textSecondary),
                textAlign: TextAlign.center),
            Text(sub,
                style: TextStyle(
                    fontSize: 10,
                    color: earned
                        ? color.withOpacity(0.8)
                        : Colors.grey)),
          ]),
        ),
      );
}

class _MonthlyCalendar extends StatelessWidget {
  final String uid;
  const _MonthlyCalendar({required this.uid});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth =
        DateTime(now.year, now.month + 1, 0).day;
    final firstDay =
        DateTime(now.year, now.month, 1).weekday % 7;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('intake_logs')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (ctx, snap) {
        final takenDays = <int>{};
        if (snap.hasData) {
          for (final doc in snap.data!.docs) {
            final d = doc.data() as Map<String, dynamic>;
            final ts = d['takenAt'];
            if (ts != null) {
              final dt = (ts as Timestamp).toDate();
              if (dt.year == now.year && dt.month == now.month) {
                takenDays.add(dt.day);
              }
            }
          }
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ]),
          child: Column(children: [
            Row(
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(d,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                  fontSize: 13)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: firstDay + daysInMonth,
              itemBuilder: (ctx, i) {
                if (i < firstDay) return const SizedBox();
                final day = i - firstDay + 1;
                final past    = day < now.day;
                final isToday = day == now.day;
                final taken   = takenDays.contains(day);

                Color? bg;
                Widget? ico;
                if (past) {
                  bg = taken
                      ? AppColors.success.withOpacity(0.12)
                      : AppColors.error.withOpacity(0.12);
                  ico = Icon(
                      taken ? Icons.check_circle : Icons.cancel,
                      size: 18,
                      color: taken
                          ? AppColors.success
                          : AppColors.error);
                }

                return Container(
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.primary.withOpacity(0.15)
                        : bg,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(
                            color: AppColors.primary, width: 1.5)
                        : null,
                  ),
                  child: ico ??
                      Center(
                        child: Text('$day',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: isToday
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isToday
                                    ? AppColors.primary
                                    : AppColors.textSecondary)),
                      ),
                );
              },
            ),
          ]),
        );
      },
    );
  }
}
