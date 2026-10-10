import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../home/home_screen.dart';

void _goHome(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const HomeShell()),
    (route) => false,
  );
}

Widget _heading(String title, String subtitle) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.text)),
      const SizedBox(height: 6),
      Text(subtitle, style: const TextStyle(color: AppColors.muted, height: 1.4)),
      const SizedBox(height: 28),
    ],
  );
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _pass = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final app = context.read<AppState>();
    if (app.signIn(_phone.text, _pass.text)) {
      _goHome(context);
    } else {
      showSnack(context, 'Wrong phone number or password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          children: [
            const LimitaLogo(),
            const SizedBox(height: 44),
            _heading('Welcome Back', 'Hello there, sign in to continue'),
            Form(
              key: _form,
              child: Column(
                children: [
                  AppTextField(
                    label: 'Phone number',
                    controller: _phone,
                    keyboard: TextInputType.phone,
                    hint: '0332249402',
                    icon: Icons.phone_outlined,
                    validator: notEmpty,
                  ),
                  AppTextField(
                    label: 'Password',
                    controller: _pass,
                    password: true,
                    hint: '***********',
                    icon: Icons.lock_outline,
                    validator: notEmpty,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                ),
                child: const Text('Forgot your password ?'),
              ),
            ),
            const SizedBox(height: 10),
            PrimaryButton(label: 'Sign in', onPressed: _submit),
            const SizedBox(height: 26),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                  ),
                  child: const Text('Sign Up', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    context.read<AppState>().register(_name.text, _phone.text, _pass.text);
    _goHome(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            _heading('Welcome to us,', 'Hello there, create New account'),
            Form(
              key: _form,
              child: Column(
                children: [
                  AppTextField(label: 'Name', controller: _name, hint: 'John Weliams', icon: Icons.person_outline, validator: notEmpty),
                  AppTextField(
                    label: 'Phone number',
                    controller: _phone,
                    keyboard: TextInputType.phone,
                    hint: '(+84) 332249402',
                    icon: Icons.phone_outlined,
                    validator: (v) => (v == null || v.trim().length < 8) ? 'Enter a valid phone number' : null,
                  ),
                  AppTextField(
                    label: 'Password',
                    controller: _pass,
                    password: true,
                    hint: '***********',
                    icon: Icons.lock_outline,
                    validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                  ),
                ],
              ),
            ),
            const Text(
              'By creating an account your agree\nto our Term and Conditions',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 18),
            PrimaryButton(label: 'Sign up', onPressed: _submit),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Have an account? '),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Text('Sign In', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _send() {
    if (!_form.currentState!.validate()) return;
    final app = context.read<AppState>();
    if (_phone.text.trim() != app.phone) {
      showSnack(context, 'No account found with this phone number');
      return;
    }
    app.sendResetCode();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VerifyCodeScreen(phone: app.phone)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            _heading('Forgot password', 'Type your phone number and we will text you a code'),
            Form(
              key: _form,
              child: AppTextField(
                label: 'Type your phone number',
                controller: _phone,
                keyboard: TextInputType.phone,
                hint: '(+84) 0398829xxx',
                icon: Icons.phone_outlined,
                validator: notEmpty,
              ),
            ),
            const SizedBox(height: 8),
            PrimaryButton(label: 'Send', onPressed: _send),
          ],
        ),
      ),
    );
  }
}

class VerifyCodeScreen extends StatefulWidget {
  final String phone;

  const VerifyCodeScreen({super.key, required this.phone});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _code = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showSnack(context, 'Your code is ${context.read<AppState>().resetCode}');
    });
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _resend() {
    final c = context.read<AppState>().sendResetCode();
    showSnack(context, 'Your new code is $c');
  }

  void _next() {
    final app = context.read<AppState>();
    if (_code.text.trim() != app.resetCode) {
      showSnack(context, 'Wrong code');
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NewPasswordScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            _heading('Type a code', 'We texted you a code to verify your phone number (+84) ${widget.phone}'),
            AppTextField(
              label: 'Code',
              controller: _code,
              keyboard: TextInputType.number,
              hint: '8422',
              suffix: TextButton(onPressed: _resend, child: const Text('Resend')),
            ),
            const Text(
              "This code will expired 10 minutes after this message. If you don't get a message.",
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Send', onPressed: _next),
          ],
        ),
      ),
    );
  }
}

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    context.read<AppState>().setPassword(_pass.text);
    showMessageDialog(
      context,
      'Change password successfully!',
      'You have successfully change password.\nPlease use the new password when Sign in.',
      onOk: () => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            _heading('Change password', 'Type your new password'),
            Form(
              key: _form,
              child: Column(
                children: [
                  AppTextField(
                    label: 'Password',
                    controller: _pass,
                    password: true,
                    hint: '************',
                    validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                  ),
                  AppTextField(
                    label: 'Confirm password',
                    controller: _confirm,
                    password: true,
                    hint: '************',
                    validator: (v) => v != _pass.text ? 'Passwords do not match' : null,
                  ),
                ],
              ),
            ),
            PrimaryButton(label: 'Send', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
