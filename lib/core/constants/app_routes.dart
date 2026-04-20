class AppRoutes {
  AppRoutes._();

  // Common
  static const String splash         = '/';
  static const String roleSelection  = '/role-selection';

  // Patient
  static const String patientLogin    = '/patient/login';
  static const String patientRegister = '/patient/register';
  static const String patientDashboard = '/patient/dashboard';
  static const String addMedication   = '/patient/add-medication';
  static const String progressRewards = '/patient/progress-rewards';
  static const String prescriptionUpload = '/patient/prescription-upload';
  static const String pharmacyMap     = '/patient/pharmacy-map';
  static const String orderTracking   = '/patient/order-tracking';

  // Pharmacy
  static const String pharmacyLogin     = '/pharmacy/login';
  static const String pharmacyDashboard = '/pharmacy/dashboard';

  // Delivery
  static const String deliveryLogin     = '/delivery/login';
  static const String deliveryDashboard = '/delivery/dashboard';
}
