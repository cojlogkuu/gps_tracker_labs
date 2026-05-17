import 'package:flutter/material.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';

class BaseCoordsPanel extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final void Function(double lat, double lng) onSave;

  const BaseCoordsPanel({
    required this.onSave,
    this.initialLat,
    this.initialLng,
    super.key,
  });

  @override
  State<BaseCoordsPanel> createState() => _BaseCoordsPanelState();
}

class _BaseCoordsPanelState extends State<BaseCoordsPanel> {
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;

  @override
  void initState() {
    super.initState();
    _latCtrl = TextEditingController(
      text: widget.initialLat?.toStringAsFixed(6) ?? '',
    );
    _lngCtrl = TextEditingController(
      text: widget.initialLng?.toStringAsFixed(6) ?? '',
    );
  }

  @override
  void dispose() {
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());
    if (lat == null || lng == null) return;
    widget.onSave(lat, lng);

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Base coordinates saved successfully.',
            style: TextStyle(
              color: AppColors.primaryBg,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.accentTeal,
          duration: Duration(seconds: 2),
        ),
      );
  }

  Widget _field(TextEditingController c, String label) => TextField(
    controller: c,
    keyboardType: const TextInputType.numberWithOptions(
      decimal: true,
      signed: true,
    ),
    style: const TextStyle(color: Colors.white, fontSize: 13),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.accentTeal, fontSize: 11),
      filled: true,
      fillColor: AppColors.primaryBg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BASE COORDINATES',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2.5,
              color: AppColors.accentTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _field(_latCtrl, 'Latitude')),
              const SizedBox(width: 12),
              Expanded(child: _field(_lngCtrl, 'Longitude')),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentTeal,
                foregroundColor: AppColors.primaryBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _save,
              child: const Text(
                'SET BASE',
                style: TextStyle(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
