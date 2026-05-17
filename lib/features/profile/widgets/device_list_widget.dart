import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gps_tracker/core/data/models/device_model.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/features/device/cubit/device_cubit.dart';
import 'package:gps_tracker/features/device/cubit/device_state.dart';
import 'package:gps_tracker/features/profile/widgets/device_card.dart';

class DeviceListWidget extends StatelessWidget {
  const DeviceListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentTeal,
            foregroundColor: AppColors.primaryBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.add),
          label: const Text('CREATE NEW DEVICE'),
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => const CreateDeviceDialog(),
          ),
        ),
        const SizedBox(height: 16),
        BlocConsumer<DeviceCubit, DeviceState>(
          listener: (context, state) {
            if (state is DeviceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Offline — showing cached devices'),
                  backgroundColor: AppColors.errorRed,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is DeviceInitial) {
              // Trigger fetch lazily if in initial state
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<DeviceCubit>().fetchDevices();
              });
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accentTeal),
              );
            }

            if (state is DeviceLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accentTeal),
              );
            }

            final devices = state is DeviceLoaded
                ? state.devices
                : (state is DeviceError
                      ? state.cachedDevices
                      : <DeviceModel>[]);

            if (devices.isEmpty) {
              return const Text(
                'No devices yet. Create one above.',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              );
            }

            return Column(
              children: devices
                  .map((d) => DeviceCard(key: ValueKey(d.id), device: d))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class CreateDeviceDialog extends StatefulWidget {
  const CreateDeviceDialog({super.key});

  @override
  State<CreateDeviceDialog> createState() => _CreateDeviceDialogState();
}

class _CreateDeviceDialogState extends State<CreateDeviceDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBg,
      title: const Text('Create Device', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: _ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          labelText: 'Device Name',
          labelStyle: TextStyle(color: AppColors.accentTeal),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.accentTeal),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () {
            final name = _ctrl.text.trim();
            if (name.isNotEmpty) {
              context.read<DeviceCubit>().createDevice(name);
            }
            Navigator.of(context).pop();
          },
          child: const Text(
            'Create',
            style: TextStyle(color: AppColors.accentTeal),
          ),
        ),
      ],
    );
  }
}
