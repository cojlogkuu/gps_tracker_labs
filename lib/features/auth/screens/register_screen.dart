import 'package:flutter/material.dart';
import 'package:gps_tracker/core/data/repositories/auth_repository.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/features/auth/widgets/auth_footer_link.dart';
import 'package:gps_tracker/features/auth/widgets/register_form.dart';
import 'package:gps_tracker/features/auth/widgets/register_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final IAuthRepository _auth = SharedPrefsAuthRepository();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    await _auth.saveUser(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final hPad = mq.size.width > 600 ? 80.0 : 28.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RegisterHeader(),
              const SizedBox(height: 40),
              RegisterForm(
                formKey: _formKey,
                nameController: _nameCtrl,
                emailController: _emailCtrl,
                passwordController: _passCtrl,
                confirmController: _confirmCtrl,
                onRegister: _onRegister,
                isLoading: _loading,
              ),
              const SizedBox(height: 32),
              AuthFooterLink(
                question: 'Already have an account? ',
                actionLabel: 'Sign In',
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
