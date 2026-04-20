import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';

// ────────────────────────────────────────────────────────────
// PATIENT LOGIN
// ────────────────────────────────────────────────────────────
class PatientLoginScreen extends StatefulWidget {
  const PatientLoginScreen({super.key});
  @override
  State<PatientLoginScreen> createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends State<PatientLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Login failed');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: _AuthCard(
                children: [
                  _BackButton(),
                  const SizedBox(height: 16),
                  const _RoleIcon(icon: Icons.person_outline,
                      color: AppColors.patientRole),
                  const SizedBox(height: 12),
                  const _CardTitle('Patient Login'),
                  const _CardSubtitle('Sign in to access your account'),
                  const SizedBox(height: 28),
                  _Field('Email', _emailCtrl, Icons.email_outlined,
                      'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      validator: _emailValidator),
                  const SizedBox(height: 16),
                  _PasswordField(controller: _passCtrl, obscure: _obscure,
                      onToggle: () =>
                          setState(() => _obscure = !_obscure)),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? _Spinner()
                        : const Text('Login',
                            style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 16),
                  _RegisterLink(
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.patientRegister),
                    label: "Don't have an account? ",
                    linkText: 'Create an account',
                    color: AppColors.patientRole,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// PATIENT REGISTER
// ────────────────────────────────────────────────────────────
class PatientRegisterScreen extends StatefulWidget {
  const PatientRegisterScreen({super.key});
  @override
  State<PatientRegisterScreen> createState() =>
      _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends State<PatientRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      final uid = cred.user!.uid;

      // Save user profile
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'role': 'patient',
        'preferredLanguage': 'en',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create initial achievements document
      await FirebaseFirestore.instance
          .collection('achievements')
          .doc(uid)
          .set({
        'userId': uid,
        'streakDays': 0,
        'totalPoints': 0,
        'adherencePercent': 0.0,
        'badges': [],
        'lastTakenAt': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.message ?? 'Registration failed'),
            backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: _AuthCard(
                children: [
                  _BackButton(),
                  const SizedBox(height: 16),
                  const _CardTitle('Create Account'),
                  const _CardSubtitle('Join MediCare as a patient'),
                  const SizedBox(height: 28),
                  _Field('Full Name', _nameCtrl, Icons.person_outline,
                      'Enter your full name',
                      validator: _requiredValidator),
                  const SizedBox(height: 16),
                  _Field('Email', _emailCtrl, Icons.email_outlined,
                      'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      validator: _emailValidator),
                  const SizedBox(height: 16),
                  _Field('Phone Number', _phoneCtrl, Icons.phone_outlined,
                      'Enter your phone',
                      keyboardType: TextInputType.phone,
                      validator: _requiredValidator),
                  const SizedBox(height: 16),
                  _PasswordField(
                      controller: _passCtrl,
                      obscure: _obscure,
                      onToggle: () =>
                          setState(() => _obscure = !_obscure)),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? _Spinner()
                        : const Text('Create Account',
                            style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ────────────────────────────────────────────────────────────
class _AuthCard extends StatelessWidget {
  final List<Widget> children;
  const _AuthCard({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back,
            color: AppColors.textSecondary),
      );
}

class _RoleIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _RoleIcon({required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Center(
        child: Icon(icon, size: 64, color: color),
      );
}

class _CardTitle extends StatelessWidget {
  final String text;
  const _CardTitle(this.text);
  @override
  Widget build(BuildContext context) => Center(
        child: Text(text,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
      );
}

class _CardSubtitle extends StatelessWidget {
  final String text;
  const _CardSubtitle(this.text);
  @override
  Widget build(BuildContext context) => Center(
        child: Text(text,
            style:
                const TextStyle(color: AppColors.textSecondary)),
      );
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _Field(this.label, this.controller, this.icon, this.hint,
      {this.keyboardType = TextInputType.text, this.validator});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
              hintText: hint, prefixIcon: Icon(icon)),
          validator: validator,
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField(
      {required this.controller,
      required this.obscure,
      required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Password',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: 'Minimum 6 characters',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: onToggle,
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Password is required';
            if (v.length < 6) return 'Minimum 6 characters';
            return null;
          },
        ),
      ],
    );
  }
}

class _RegisterLink extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final String linkText;
  final Color color;

  const _RegisterLink(
      {required this.onTap,
      required this.label,
      required this.linkText,
      required this.color});

  @override
  Widget build(BuildContext context) => Center(
        child: GestureDetector(
          onTap: onTap,
          child: Text.rich(TextSpan(
            text: label,
            style: const TextStyle(color: AppColors.textSecondary),
            children: [
              TextSpan(
                  text: linkText,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w600)),
            ],
          )),
        ),
      );
}

class _Spinner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
            color: Colors.white, strokeWidth: 2),
      );
}

// Validators
String? _emailValidator(String? v) {
  if (v == null || v.isEmpty) return 'Email is required';
  if (!v.contains('@')) return 'Enter a valid email';
  return null;
}

String? _requiredValidator(String? v) =>
    (v == null || v.isEmpty) ? 'This field is required' : null;
