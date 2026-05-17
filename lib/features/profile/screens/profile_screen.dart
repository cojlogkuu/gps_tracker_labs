import 'package:flutter/material.dart';
import 'package:gps_tracker/core/data/repositories/auth_repository.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/features/profile/widgets/delete_account_dialog.dart';
import 'package:gps_tracker/features/profile/widgets/edit_name_dialog.dart';
import 'package:gps_tracker/features/profile/widgets/profile_header.dart';
import 'package:gps_tracker/features/profile/widgets/profile_info_card.dart';
import 'package:gps_tracker/features/profile/widgets/profile_logout_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final IAuthRepository _auth = SharedPrefsAuthRepository();
  String _name = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name = await _auth.getName();
    final email = await _auth.getEmail();
    if (!mounted) return;
    setState(() {
      _name = name ?? '';
      _email = email ?? '';
    });
  }

  Future<void> _editName() async {
    final newName = await showEditNameDialog(context, _name);
    if (newName == null || newName.isEmpty) return;
    await _auth.updateName(newName);
    _loadProfile();
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDeleteAccountDialog(context);
    if (!confirmed) return;
    await _auth.deleteAccount();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  static Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      letterSpacing: 2.5,
      color: AppColors.accentTeal,
      fontWeight: FontWeight.w600,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.of(context).size.width > 600 ? 80.0 : 24.0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
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
            icon: const Icon(Icons.edit, color: AppColors.accentTeal),
            onPressed: _editName,
            tooltip: 'Edit Name',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: AppColors.errorRed),
            onPressed: _deleteAccount,
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
              ProfileHeader(name: _name),
              const SizedBox(height: 32),
              _sectionLabel('ACCOUNT DETAILS'),
              const SizedBox(height: 12),
              ProfileInfoCard(
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
}
