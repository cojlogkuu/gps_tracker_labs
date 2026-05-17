import 'package:flutter/material.dart';
import 'package:gps_tracker/core/providers/mqtt_provider.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:provider/provider.dart';

class NetworkSettingsWidget extends StatelessWidget {
  const NetworkSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final mqttProvider = context.watch<MqttProvider>();
    final isHiveMQ = mqttProvider.environment == BrokerEnvironment.hiveMQ;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SwitchListTile(
        title: const Text(
          'Cloud Broker (HiveMQ)',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        subtitle: Text(
          isHiveMQ ? 'Connected to HiveMQ' : 'Connected to Local Mosquitto',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        activeThumbColor: AppColors.accentTeal,
        value: isHiveMQ,
        onChanged: (bool value) async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Switching broker environment...'),
              duration: Duration(seconds: 2),
            ),
          );
          await context.read<MqttProvider>().switchEnvironment(
            value ? BrokerEnvironment.hiveMQ : BrokerEnvironment.local,
          );
        },
      ),
    );
  }
}
