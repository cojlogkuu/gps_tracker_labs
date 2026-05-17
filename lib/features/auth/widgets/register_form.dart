import 'package:flutter/material.dart';
import 'package:gps_tracker/core/widgets/general_button.dart';
import 'package:gps_tracker/core/widgets/general_text_field.dart';

class RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final VoidCallback onRegister;
  final bool isLoading;

  const RegisterForm({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.onRegister,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          GeneralTextField(
            controller: nameController,
            label: 'FULL NAME',
            prefixIcon: Icons.person_outline,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Name is required';
              if (v.contains(RegExp(r'[0-9]'))) {
                return 'Name cannot contain numbers';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          GeneralTextField(
            controller: emailController,
            label: 'EMAIL',
            prefixIcon: Icons.alternate_email,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Invalid email address';
              return null;
            },
          ),
          const SizedBox(height: 16),
          GeneralTextField(
            controller: passwordController,
            label: 'PASSWORD',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            validator: (v) =>
                (v == null || v.length < 6) ? 'Min. 6 characters' : null,
          ),
          const SizedBox(height: 16),
          GeneralTextField(
            controller: confirmController,
            label: 'CONFIRM PASSWORD',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textInputAction: TextInputAction.done,
            validator: (v) =>
                v != passwordController.text ? 'Passwords do not match' : null,
          ),
          const SizedBox(height: 32),
          GeneralButton(
            label: 'CREATE ACCOUNT',
            onPressed: onRegister,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
