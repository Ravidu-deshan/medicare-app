import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.medical_services,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Text('MediCare',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Welcome to MediCare',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('Select your role to continue',
                  style:
                      TextStyle(fontSize: 15, color: AppColors.textSecondary)),
              const SizedBox(height: 40),
              _RoleCard(
                icon: Icons.person,
                title: 'Patient',
                subtitle: 'Order medicines and manage prescriptions',
                color: AppColors.patientRole,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.patientLogin),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.local_pharmacy,
                title: 'Pharmacy',
                subtitle: 'Manage orders and prescriptions',
                color: AppColors.pharmacyRole,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.pharmacyLogin),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.delivery_dining,
                title: 'Delivery Agent',
                subtitle: 'Deliver medicines to customers',
                color: AppColors.deliveryRole,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.deliveryLogin),
              ),
              const Spacer(),
              const Center(
                child: Text('PUSL3190 — University of Plymouth',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: color)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
