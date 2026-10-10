import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../auth/auth_screens.dart';
import '../utilities/utilities_screens.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    Widget item(IconData icon, String title, Widget Function() page) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page())),
        ),
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Setting', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      Text(app.phone, style: const TextStyle(color: AppColors.muted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          item(Icons.edit_outlined, 'Edit your info', () => const EditInfoScreen()),
          item(Icons.speed, 'Set your limit', () => const SetLimitScreen()),
          item(Icons.lock_outline, 'Change password', () => const ChangePasswordScreen()),
          item(Icons.language, 'Languages', () => const LanguageScreen()),
          item(Icons.info_outline, 'App information', () => const AppInfoScreen()),
          item(Icons.headset_mic_outlined, 'Customer care', () => const CustomerCareScreen()),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Log out',
            color: AppColors.danger,
            outlined: true,
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SignInScreen()),
              (route) => false,
            ),
          ),
        ],
      ),
    );
  }
}

class EditInfoScreen extends StatefulWidget {
  const EditInfoScreen({super.key});

  @override
  State<EditInfoScreen> createState() => _EditInfoScreenState();
}

class _EditInfoScreenState extends State<EditInfoScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _first;
  late final TextEditingController _last;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _first = TextEditingController(text: app.firstName);
    _last = TextEditingController(text: app.lastName);
    _phone = TextEditingController(text: app.phone);
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    context.read<AppState>().updateProfile(_first.text.trim(), _last.text.trim(), _phone.text.trim());
    showMessageDialog(context, 'Saved', 'Your information was updated.', onOk: () => Navigator.of(context).pop());
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Edit your info',
      children: [
        Form(
          key: _form,
          child: Column(
            children: [
              AppTextField(label: 'First Name', controller: _first, validator: notEmpty),
              AppTextField(label: 'Last Name', controller: _last),
              AppTextField(label: 'Phone Number', controller: _phone, keyboard: TextInputType.phone, validator: notEmpty),
            ],
          ),
        ),
        PrimaryButton(label: 'Confirm', onPressed: _save),
      ],
    );
  }
}

class SetLimitScreen extends StatefulWidget {
  const SetLimitScreen({super.key});

  @override
  State<SetLimitScreen> createState() => _SetLimitScreenState();
}

class _SetLimitScreenState extends State<SetLimitScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _amount;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(text: context.read<AppState>().shoppingLimit.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    context.read<AppState>().setLimit(double.parse(_amount.text.trim()));
    showMessageDialog(context, 'Your limit added successfully!', 'We will warn you when you reach 50% of it.', onOk: () => Navigator.of(context).pop());
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Set Your Limit',
      children: [
        const Text('Monthly shopping limit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        Form(
          key: _form,
          child: AmountInput(controller: _amount, amounts: const [500, 1000, 2000, 5000]),
        ),
        const SizedBox(height: 10),
        PrimaryButton(label: 'Add Limit', onPressed: _save),
      ],
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final app = context.read<AppState>();
    if (_old.text != app.password) {
      showSnack(context, 'The recent password is wrong');
      return;
    }
    app.setPassword(_new.text);
    showMessageDialog(
      context,
      'Change password successfully!',
      'You have successfully change password.\nPlease use the new password when Sign in.',
      onOk: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Change password',
      children: [
        Form(
          key: _form,
          child: Column(
            children: [
              AppTextField(label: 'Recent password', controller: _old, password: true, validator: notEmpty),
              AppTextField(
                label: 'New password',
                controller: _new,
                password: true,
                validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
              ),
              AppTextField(
                label: 'Confirm new password',
                controller: _confirm,
                password: true,
                validator: (v) => v != _new.text ? 'Passwords do not match' : null,
              ),
            ],
          ),
        ),
        PrimaryButton(label: 'Confirm', onPressed: _save),
      ],
    );
  }
}

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return PageScaffold(
      title: 'App information',
      children: [
        const SizedBox(height: 10),
        const Center(child: LimitaLogo()),
        const SizedBox(height: 8),
        const Center(child: Text('Limita E-mobile Banking', style: TextStyle(color: AppColors.muted))),
        const SizedBox(height: 24),
        InfoCard(
          rows: [
            const MapEntry('Date of manufacture', 'Dec 2019'),
            const MapEntry('Version', '9.0.2'),
            MapEntry('Language', app.language),
          ],
        ),
      ],
    );
  }
}

class CustomerCareScreen extends StatefulWidget {
  const CustomerCareScreen({super.key});

  @override
  State<CustomerCareScreen> createState() => _CustomerCareScreenState();
}

class _CustomerCareScreenState extends State<CustomerCareScreen> {
  final _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void _send() {
    if (_message.text.trim().isEmpty) {
      showSnack(context, 'Type something first');
      return;
    }
    _message.clear();
    showMessageDialog(context, 'Thanks!', 'Our team will get back to you soon.');
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Customer care',
      children: [
        const InfoCard(
          rows: [
            MapEntry('Hotline', '18009898'),
            MapEntry('Email', 'support@limita.bank'),
            MapEntry('Working hours', '8:00 - 18:00'),
          ],
        ),
        const SizedBox(height: 22),
        AppTextField(label: 'Message', controller: _message, hint: 'Type something....', maxLines: 5),
        PrimaryButton(label: 'Send', onPressed: _send),
      ],
    );
  }
}
