import 'package:flutter/material.dart';
import 'package:gps_tracker/core/data/repositories/auth_repository.dart';
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
  final IAuthRepository _auth = SharedPrefsAuthRepository();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    final ok = await _auth.verifyCredentials(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      await Navigator.of(context).pushReplacementNamed('/home');
    } else {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid email or password.',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Color(0xFFA91818),
          ),
        );
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
                isLoading: _loading,
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
