import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../services/firestore_service.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});
  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _frequency = 'Once daily';
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  bool _loading = false;

  static const _freqOptions = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Weekly',
    'As needed',
  ];
  static const _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_days.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select at least one day')));
      return;
    }
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final timeStr =
          '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

      await FirestoreService.addMedication(
        userId: uid,
        medicineName: _nameCtrl.text.trim(),
        dosage: _dosageCtrl.text.trim(),
        frequency: _frequency,
        time: timeStr,
        days: List<String>.from(_days),
        notes: _notesCtrl.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medication added!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medication')),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _Card(
                children: [
                  _Label('Medicine Name'),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Panadol, Metformin',
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _Label('Dosage'),
                  TextFormField(
                    controller: _dosageCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 500mg, 1 tablet',
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Card(
                children: [
                  _Label('Frequency'),
                  DropdownButtonFormField<String>(
                    initialValue: _frequency,
                    items: _freqOptions
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (v) => setState(() => _frequency = v!),
                    decoration: const InputDecoration(),
                  ),
                  const SizedBox(height: 16),
                  _Label('Reminder Time'),
                  GestureDetector(
                    onTap: () async {
                      final p = await showTimePicker(
                        context: context,
                        initialTime: _time,
                      );
                      if (p != null) setState(() => _time = p);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _time.format(context),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Card(
                children: [
                  _Label('Days'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _allDays.map((day) {
                      final sel = _days.contains(day);
                      return FilterChip(
                        label: Text(day),
                        selected: sel,
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: sel
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                        ),
                        onSelected: (v) => setState(
                          () => v ? _days.add(day) : _days.remove(day),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Card(
                children: [
                  _Label('Notes (optional)'),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Take after food',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Medication',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
  );
}
