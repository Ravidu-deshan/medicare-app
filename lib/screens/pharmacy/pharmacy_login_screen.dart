import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// ── PHARMACY LOGIN ────────────────────────────────────────
class PharmacyLoginScreen extends StatelessWidget {
  const PharmacyLoginScreen({super.key});
  @override
  Widget build(BuildContext context) => _Stub(
    'Pharmacy Login',
    AppColors.pharmacyRole,
    Icons.local_pharmacy,
    'Sprint 6 — Coming soon',
    context,
  );
}

// ── PHARMACY DASHBOARD ───────────────────────────────────
class PharmacyDashboardScreen extends StatelessWidget {
  const PharmacyDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Pharmacy Dashboard'),
      backgroundColor: AppColors.pharmacyRole,
    ),
    body: const Center(
      child: Text(
        'Pharmacy Dashboard — Sprint 6',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    ),
  );
}

// ── DELIVERY LOGIN ───────────────────────────────────────
class DeliveryLoginScreen extends StatelessWidget {
  const DeliveryLoginScreen({super.key});
  @override
  Widget build(BuildContext context) => _Stub(
    'Delivery Agent Login',
    AppColors.deliveryRole,
    Icons.delivery_dining,
    'Sprint 7 — Coming soon',
    context,
  );
}

// ── DELIVERY DASHBOARD ───────────────────────────────────
class DeliveryDashboardScreen extends StatelessWidget {
  const DeliveryDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Delivery Dashboard'),
      backgroundColor: AppColors.deliveryRole,
    ),
    body: const Center(
      child: Text(
        'Delivery Dashboard — Sprint 7',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    ),
  );
}

// ── SHARED STUB BUILDER ──────────────────────────────────
Widget _Stub(
  String title,
  Color color,
  IconData icon,
  String note,
  BuildContext context,
) {
  return Scaffold(
    backgroundColor: Colors.grey.shade100,
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                note,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  minimumSize: const Size(160, 48),
                ),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
