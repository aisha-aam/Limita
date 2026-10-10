import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';

void startTransaction(
  BuildContext context, {
  required String title,
  required List<MapEntry<String, String>> rows,
  required String successTitle,
  required String successMessage,
  required VoidCallback onComplete,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _ConfirmScreen(
        title: title,
        rows: rows,
        successTitle: successTitle,
        successMessage: successMessage,
        onComplete: onComplete,
      ),
    ),
  );
}

class _ConfirmScreen extends StatelessWidget {
  final String title;
  final List<MapEntry<String, String>> rows;
  final String successTitle;
  final String successMessage;
  final VoidCallback onComplete;

  const _ConfirmScreen({
    required this.title,
    required this.rows,
    required this.successTitle,
    required this.successMessage,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Confirm',
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        InfoCard(rows: rows),
        const SizedBox(height: 28),
        PrimaryButton(
          label: 'Confirm',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _OtpScreen(
                successTitle: successTitle,
                successMessage: successMessage,
                onComplete: onComplete,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OtpScreen extends StatefulWidget {
  final String successTitle;
  final String successMessage;
  final VoidCallback onComplete;

  const _OtpScreen({
    required this.successTitle,
    required this.successMessage,
    required this.onComplete,
  });

  @override
  State<_OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<_OtpScreen> {
  final _otp = TextEditingController();
  String? _sent;

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  void _getOtp() {
    final code = (1000 + Random().nextInt(9000)).toString();
    setState(() => _sent = code);
    showSnack(context, 'Your OTP is $code');
  }

  void _verify() {
    if (_sent == null) {
      showSnack(context, 'Tap Get OTP first');
      return;
    }
    if (_otp.text.trim() != _sent) {
      showSnack(context, 'Wrong OTP, try again');
      return;
    }
    _finish();
  }

  void _finish() {
    widget.onComplete();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => SuccessScreen(title: widget.successTitle, message: widget.successMessage),
      ),
      (route) => route.isFirst,
    );
  }

  Future<void> _faceId() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Use Face ID to verify transaction'),
        content: const Text('Access to the application'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Verify')),
        ],
      ),
    );
    if (ok == true && mounted) _finish();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Verify',
      children: [
        const Text('Get OTP to verify transaction', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: AppTextField(
                label: 'OTP',
                controller: _otp,
                keyboard: TextInputType.number,
                hint: '4 digits',
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _getOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Get OTP'),
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _faceId,
            icon: const Icon(Icons.face),
            label: const Text('Use Face ID instead'),
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(label: 'Confirm', onPressed: _verify),
      ],
    );
  }
}

class SuccessScreen extends StatelessWidget {
  final String title;
  final String message;

  const SuccessScreen({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 56, color: AppColors.success),
              ),
              const SizedBox(height: 28),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, height: 1.4)),
              const SizedBox(height: 36),
              PrimaryButton(label: 'Ok', onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    );
  }
}
