import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'screens/common/splash_screen.dart';
import 'screens/common/role_selection_screen.dart';
import 'screens/patient/patient_login_screen.dart';
import 'screens/patient/patient_dashboard_screen.dart';
import 'screens/patient/add_medication_screen.dart';
import 'screens/patient/progress_rewards_screen.dart';
import 'screens/pharmacy/pharmacy_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MediCareApp()));
}

class MediCareApp extends StatelessWidget {
  const MediCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.roleSelection: (_) => const RoleSelectionScreen(),
        AppRoutes.patientLogin: (_) => const PatientLoginScreen(),
        AppRoutes.patientRegister: (_) => const PatientRegisterScreen(),
        AppRoutes.patientDashboard: (_) => const PatientDashboardScreen(),
        AppRoutes.addMedication: (_) => const AddMedicationScreen(),
        AppRoutes.progressRewards: (_) => const ProgressRewardsScreen(),
        AppRoutes.pharmacyLogin: (_) => const PharmacyLoginScreen(),
        AppRoutes.pharmacyDashboard: (_) => const PharmacyDashboardScreen(),
        AppRoutes.deliveryLogin: (_) => const DeliveryLoginScreen(),
        AppRoutes.deliveryDashboard: (_) => const DeliveryDashboardScreen(),
      },
    );
  }
}
