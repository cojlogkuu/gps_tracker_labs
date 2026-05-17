import 'package:flutter/material.dart';
import 'package:gps_tracker/core/data/repositories/api_device_repository.dart';
import 'package:gps_tracker/core/providers/auth_provider.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/features/profile/widgets/base_coords_dialog.dart';
import 'package:gps_tracker/features/profile/widgets/delete_account_dialog.dart';
import 'package:gps_tracker/features/profile/widgets/device_list_widget.dart';
import 'package:gps_tracker/features/profile/widgets/profile_header.dart';
import 'package:gps_tracker/features/profile/widgets/profile_info_card.dart';
import 'package:gps_tracker/features/profile/widgets/profile_logout_button.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  final ApiDeviceRepository apiDeviceRepo;

  const ProfileScreen({required this.apiDeviceRepo, super.key});

  static Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      letterSpacing: 2.5,
      color: AppColors.accentTeal,
      fontWeight: FontWeight.w600,
    ),
  );

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDeleteAccountDialog(context);
    if (!confirmed || !context.mounted) return;
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  Future<void> _setBaseCoords(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => const BaseCoordsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final hPad = MediaQuery.of(context).size.width > 600 ? 80.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'PROFILE',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 3,
            color: AppColors.accentTeal,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: AppColors.accentTeal),
            onPressed: () => _setBaseCoords(context),
            tooltip: 'Set Base Coordinates',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: AppColors.errorRed),
            onPressed: () => _deleteAccount(context),
            tooltip: 'Delete Account',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeader(name: user?.fullName ?? ''),
              const SizedBox(height: 32),
              _label('ACCOUNT DETAILS'),
              const SizedBox(height: 12),
              ProfileInfoCard(
                items: [
                  ProfileInfoRow(
                    icon: Icons.person_outline,
                    label: 'Full Name',
                    value: user?.fullName ?? '',
                  ),
                  ProfileInfoRow(
                    icon: Icons.alternate_email,
                    label: 'Email',
                    value: user?.email ?? '',
                  ),
                  ProfileInfoRow(
                    icon: Icons.my_location,
                    label: 'Base Coords',
                    value: user?.hasBaseCoords == true
                        ? '${user!.baseLatitude!.toStringAsFixed(4)}, '
                              '${user.baseLongitude!.toStringAsFixed(4)}'
                        : 'Not set — MQTT blocked',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _label('SAVED DEVICES'),
              const SizedBox(height: 12),
              DeviceListWidget(apiDeviceRepo: apiDeviceRepo),
              const SizedBox(height: 40),
              ProfileLogoutButton(
                onLogout: () async {
                  await context.read<AuthProvider>().logout();
                  if (!context.mounted) return;
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (_) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
