import 'package:flutter/material.dart';

import '../models/models.dart';
import 'theme.dart';

String money(double value, {int decimals = 0}) {
  final fixed = value.abs().toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final digits = parts[0];
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    out.write(digits[i]);
    final left = digits.length - i - 1;
    if (left > 0 && left % 3 == 0) out.write(',');
  }
  if (decimals > 0) out.write('.${parts[1]}');
  return out.toString();
}

String usd(double value, {int decimals = 0}) {
  final sign = value < 0 ? '-' : '';
  return '$sign\$${money(value, decimals: decimals)}';
}

String two(int n) => n.toString().padLeft(2, '0');

String fmtDate(DateTime d) => '${two(d.day)}/${two(d.month)}/${d.year}';

String dayLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final that = DateTime(d.year, d.month, d.day);
  final diff = today.difference(that).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return fmtDate(d);
}

String? notEmpty(String? v) {
  if (v == null || v.trim().isEmpty) return 'This field is required';
  return null;
}

String? positiveNumber(String? v) {
  final n = double.tryParse((v ?? '').trim());
  if (n == null || n <= 0) return 'Enter a valid amount';
  return null;
}

void showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

Future<void> showMessageDialog(
  BuildContext context,
  String title,
  String message, {
  VoidCallback? onOk,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            if (onOk != null) onOk();
          },
          child: const Text('Ok'),
        ),
      ],
    ),
  );
}

Future<String?> pickFromList(
  BuildContext context,
  String title,
  List<String> items, {
  String? current,
}) {
  return showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final item in items)
                  ListTile(
                    title: Text(item),
                    trailing: item == current ? const Icon(Icons.check, color: AppColors.primary) : null,
                    onTap: () => Navigator.of(ctx).pop(item),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class PageScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final List<Widget>? actions;

  const PageScaffold({
    super.key,
    required this.title,
    required this.children,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: children,
        ),
      ),
    );
  }
}

class LimitaLogo extends StatelessWidget {
  const LimitaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.account_balance, color: Colors.white),
        ),
        const SizedBox(width: 10),
        const Text(
          'Limita',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.text),
        ),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: c,
                side: BorderSide(color: c),
                shape: shape,
              ),
              child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: c,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: shape,
              ),
              child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
    );
  }
}

OutlineInputBorder _border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    );

class AppTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final bool password;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final int maxLines;
  final IconData? icon;
  final Widget? suffix;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.password = false,
    this.keyboard,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.maxLines = 1,
    this.icon,
    this.suffix,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: const TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextFormField(
            controller: widget.controller,
            obscureText: widget.password && _hidden,
            keyboardType: widget.keyboard,
            validator: widget.validator,
            onChanged: widget.onChanged,
            readOnly: widget.readOnly,
            maxLines: widget.password ? 1 : widget.maxLines,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: AppColors.muted),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              prefixIcon: widget.icon != null ? Icon(widget.icon, color: AppColors.muted) : null,
              suffixIcon: widget.password
                  ? IconButton(
                      icon: Icon(_hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.muted),
                      onPressed: () => setState(() => _hidden = !_hidden),
                    )
                  : widget.suffix,
              border: _border(AppColors.border),
              enabledBorder: _border(AppColors.border),
              focusedBorder: _border(AppColors.primary),
              errorBorder: _border(AppColors.danger),
              focusedErrorBorder: _border(AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class PickerField extends StatelessWidget {
  final String label;
  final String value;
  final String placeholder;
  final VoidCallback onTap;

  const PickerField({
    super.key,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value.isEmpty ? placeholder : value,
                      style: TextStyle(color: value.isEmpty ? AppColors.muted : AppColors.text),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.muted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final List<MapEntry<String, String>> rows;

  const InfoCard({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r.key, style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      r.value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.text),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

Widget _amountChip(String text, bool selected, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppColors.primary : AppColors.border),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : AppColors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final List<int> amounts;

  const AmountInput({
    super.key,
    required this.controller,
    this.amounts = const [10, 50, 100, 150, 200],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose amount', style: TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final presets = amounts.map((a) => '$a').toList();
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final a in amounts)
                  _amountChip('\$$a', value.text == '$a', () => controller.text = '$a'),
                _amountChip(
                  'Other',
                  value.text.isNotEmpty && !presets.contains(value.text),
                  () => controller.clear(),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Amount',
          controller: controller,
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          hint: '0',
          validator: positiveNumber,
        ),
      ],
    );
  }
}

class AccountPicker extends StatelessWidget {
  final List<Account> accounts;
  final Account selected;
  final ValueChanged<Account> onChanged;

  const AccountPicker({
    super.key,
    required this.accounts,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose account / card', style: TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              final labels = accounts.map((a) => a.label).toList();
              final r = await pickFromList(context, 'Choose account / card', labels, current: selected.label);
              if (r != null) onChanged(accounts.firstWhere((a) => a.label == r));
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(selected.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(
                          'Available balance : ${usd(selected.balance)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.muted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BankCardView extends StatelessWidget {
  final String title;
  final String number;
  final String holder;
  final double balance;

  const BankCardView({
    super.key,
    required this.title,
    required this.number,
    required this.holder,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
              const Icon(Icons.nfc, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            number,
            style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Card holder', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(holder, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Balance', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    usd(balance, decimals: 2),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TxTile extends StatelessWidget {
  final TxRecord tx;

  const TxTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final income = tx.amount > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: (income ? AppColors.success : AppColors.danger).withOpacity(0.12),
            child: Icon(
              income ? Icons.south_west : Icons.north_east,
              size: 18,
              color: income ? AppColors.success : AppColors.danger,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  tx.success ? dayLabel(tx.date) : '${dayLabel(tx.date)} · Unsuccessfully',
                  style: TextStyle(fontSize: 12, color: tx.success ? AppColors.muted : AppColors.danger),
                ),
              ],
            ),
          ),
          Text(
            '${income ? '+' : '-'}${usd(tx.amount.abs())}',
            style: TextStyle(fontWeight: FontWeight.w700, color: income ? AppColors.success : AppColors.text),
          ),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
    );
  }
}

class EmptyNote extends StatelessWidget {
  final String text;

  const EmptyNote(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(child: Text(text, style: const TextStyle(color: AppColors.muted))),
    );
  }
}
