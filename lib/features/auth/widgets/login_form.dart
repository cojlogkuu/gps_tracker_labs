import 'package:flutter/material.dart';
import 'package:gps_tracker/core/widgets/general_button.dart';
import 'package:gps_tracker/core/widgets/general_text_field.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final bool isLoading;

  const LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
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
            controller: emailController,
            label: 'EMAIL',
            prefixIcon: Icons.alternate_email,
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                (v == null || v.trim().isEmpty)
                    ? 'Email is required'
                    : null,
          ),
          const SizedBox(height: 16),
          GeneralTextField(
            controller: passwordController,
            label: 'PASSWORD',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textInputAction: TextInputAction.done,
            validator: (v) =>
                (v == null || v.isEmpty)
                    ? 'Password is required'
                    : null,
          ),
          const SizedBox(height: 32),
          GeneralButton(
            label: 'SIGN IN',
            onPressed: onLogin,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
