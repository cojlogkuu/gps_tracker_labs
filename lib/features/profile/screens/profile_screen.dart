import 'package:flutter/material.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/features/profile/widgets/profile_header.dart';
import 'package:gps_tracker/features/profile/widgets/profile_info_card.dart';
import 'package:gps_tracker/features/profile/widgets/profile_logout_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _name = 'Alex Johnson';
  static const _email = 'alex.johnson@example.com';

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final hPad = mq.size.width > 600 ? 80.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'PROFILE',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 3,
            color: AppColors.accentTeal,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.accentTeal,
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileHeader(name: _name),
              const SizedBox(height: 32),
              _sectionLabel('ACCOUNT DETAILS'),
              const SizedBox(height: 12),
              const ProfileInfoCard(
                items: [
                  ProfileInfoRow(
                    icon: Icons.person_outline,
                    label: 'Full Name',
                    value: _name,
                  ),
                  ProfileInfoRow(
                    icon: Icons.alternate_email,
                    label: 'Email',
                    value: _email,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ProfileLogoutButton(
                onLogout: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (_) => false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        letterSpacing: 2.5,
        color: AppColors.accentTeal,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
