import 'package:flutter/material.dart';
import 'package:gps_tracker/core/providers/auth_provider.dart';
import 'package:gps_tracker/core/providers/mqtt_provider.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:provider/provider.dart';

class BaseCoordsDialog extends StatefulWidget {
  const BaseCoordsDialog({super.key});

  @override
  State<BaseCoordsDialog> createState() => _BaseCoordsDialogState();
}

class _BaseCoordsDialogState extends State<BaseCoordsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _latCtrl = TextEditingController();
    _lngCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final lat = double.parse(_latCtrl.text);
    final lng = double.parse(_lngCtrl.text);

    setState(() => _loading = true);

    try {
      await context.read<AuthProvider>().updateBaseCoords(lat, lng);
      if (!mounted) return;
      await context.read<MqttProvider>().setBase(lat, lng);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Base coordinates updated successfully.'),
          backgroundColor: AppColors.accentTeal,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update base coordinates.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBg,
      title: const Text(
        'Set Base Coordinates',
        style: TextStyle(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _latCtrl,
              style: const TextStyle(color: Colors.white),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Latitude',
                labelStyle: TextStyle(color: AppColors.accentTeal),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.accentTeal),
                ),
              ),
              validator:
                  (val) =>
                      val == null || double.tryParse(val) == null
                          ? 'Invalid'
                          : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _lngCtrl,
              style: const TextStyle(color: Colors.white),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Longitude',
                labelStyle: TextStyle(color: AppColors.accentTeal),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.accentTeal),
                ),
              ),
              validator:
                  (val) =>
                      val == null || double.tryParse(val) == null
                          ? 'Invalid'
                          : null,
            ),
          ],
        ),
      ),
      actions: [
        if (!_loading)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(8),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accentTeal,
              ),
            ),
          ),
        if (!_loading)
          TextButton(
            onPressed: _submit,
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.accentTeal),
            ),
          ),
      ],
    );
  }
}
