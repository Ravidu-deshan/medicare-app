import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    switch (doc.data()?['role'] as String? ?? '') {
      case 'patient':
        Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
        break;
      case 'pharmacy':
        Navigator.pushReplacementNamed(context, AppRoutes.pharmacyDashboard);
        break;
      case 'agent':
        Navigator.pushReplacementNamed(context, AppRoutes.deliveryDashboard);
        break;
      default:
        Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.medical_services,
                  color: AppColors.primary, size: 56),
            ),
            const SizedBox(height: 24),
            const Text('MediCare',
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2)),
            const SizedBox(height: 8),
            const Text('Medicine Reminder & Delivery',
                style: TextStyle(fontSize: 15, color: Colors.white70)),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
          ],
        ),
      ),
    );
  }
}
