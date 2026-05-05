import 'package:flutter/material.dart';
import 'package:gps_tracker/features/auth/widgets/auth_footer_link.dart';
import 'package:gps_tracker/features/auth/widgets/login_form.dart';
import 'package:gps_tracker/features/auth/widgets/login_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final hPad = mq.size.width > 600 ? 80.0 : 28.0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, 64, hPad, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const LoginHeader(),
              const SizedBox(height: 48),
              LoginForm(
                formKey: _formKey,
                emailController: _emailCtrl,
                passwordController: _passCtrl,
                onLogin: _onLogin,
              ),
              const SizedBox(height: 40),
              AuthFooterLink(
                question: "Don't have an account? ",
                actionLabel: 'Register',
                onTap: () => Navigator.of(context).pushNamed('/register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
