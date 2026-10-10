import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../common/flow.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _form = GlobalKey<FormState>();
  final _card = TextEditingController();
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  late Account _from;
  int _mode = 0;
  String _bank = '';
  String _branch = '';
  bool _save = false;

  static const double _fee = 10;

  static const _modes = [
    ['Transfer via\ncard number', 'card'],
    ['Transfer to\nthe same bank', 'same'],
    ['Transfer to\nanother bank', 'other'],
  ];

  @override
  void initState() {
    super.initState();
    _from = context.read<AppState>().accounts.first;
  }

  @override
  void dispose() {
    _card.dispose();
    _name.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  IconData _modeIcon(int i) {
    if (i == 0) return Icons.credit_card;
    if (i == 1) return Icons.account_balance;
    return Icons.public;
  }

  Future<void> _pickBeneficiary() async {
    final app = context.read<AppState>();
    if (app.beneficiaries.isEmpty) {
      showSnack(context, 'Your directory is empty');
      return;
    }
    final names = app.beneficiaries.map((b) => b.name).toList();
    final r = await pickFromList(context, 'Choose beneficiary', names);
    if (r == null) return;
    final b = app.beneficiaries.firstWhere((x) => x.name == r);
    setState(() {
      _name.text = b.name;
      _card.text = b.cardNumber;
      if (_mode == 2) _bank = b.bank;
    });
  }

  void _next() {
    if (!_form.currentState!.validate()) return;
    final amount = double.parse(_amount.text.trim());
    if (amount + _fee > _from.balance) {
      showSnack(context, 'Your balance is not enough');
      return;
    }
    if (_mode == 2 && (_bank.isEmpty || _branch.isEmpty)) {
      showSnack(context, 'Please choose the bank and the branch');
      return;
    }
    final app = context.read<AppState>();
    final note = _note.text.trim().isEmpty ? 'From ${app.firstName}' : _note.text.trim();
    final name = _name.text.trim();
    final card = _card.text.trim();
    final bank = _mode == 2 ? _bank : 'Limita';
    final save = _save;
    final from = _from;

    startTransaction(
      context,
      title: 'Confirm transaction information',
      rows: [
        MapEntry('From', from.label),
        MapEntry('To', name),
        MapEntry('Card number', card),
        if (_mode == 2) MapEntry('Beneficiary bank', '$_bank ($_branch)'),
        MapEntry('Amount', usd(amount)),
        MapEntry('Transaction fee', usd(_fee)),
        MapEntry('Content', note),
      ],
      successTitle: 'Transfer successful!',
      successMessage: 'You have successfully transferred ${usd(amount)} to $name!',
      onComplete: () => app.transfer(
        from: from,
        toName: name,
        card: card,
        bank: bank,
        amount: amount,
        fee: _fee,
        save: save,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return PageScaffold(
      title: 'Transfer',
      children: [
        AccountPicker(
          accounts: app.accounts,
          selected: _from,
          onChanged: (a) => setState(() => _from = a),
        ),
        const Text('Choose transaction', style: TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < _modes.length; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == _modes.length - 1 ? 0 : 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => _mode = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                      decoration: BoxDecoration(
                        color: _mode == i ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _mode == i ? AppColors.primary : AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Icon(_modeIcon(i), color: _mode == i ? Colors.white : AppColors.primary),
                          const SizedBox(height: 6),
                          Text(
                            _modes[i][0],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _mode == i ? Colors.white : AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_mode == 2) ...[
                PickerField(
                  label: 'Choose bank',
                  value: _bank,
                  placeholder: 'Select bank',
                  onTap: () async {
                    final r = await pickFromList(context, 'Choose bank', banks, current: _bank);
                    if (r != null) setState(() => _bank = r);
                  },
                ),
                PickerField(
                  label: 'Choose branch',
                  value: _branch,
                  placeholder: 'Select branch',
                  onTap: () async {
                    final r = await pickFromList(context, 'Choose branch', bankBranches, current: _branch);
                    if (r != null) setState(() => _branch = r);
                  },
                ),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _pickBeneficiary,
                  icon: const Icon(Icons.people_outline, size: 18),
                  label: const Text('Choose beneficiary'),
                ),
              ),
              AppTextField(
                label: 'Card number',
                controller: _card,
                keyboard: TextInputType.number,
                hint: '0123456789',
                validator: (v) => (v == null || v.trim().length < 8) ? 'Enter a valid card number' : null,
              ),
              AppTextField(label: 'Name', controller: _name, hint: 'Beneficiary name', validator: notEmpty),
              AppTextField(
                label: 'Amount',
                controller: _amount,
                keyboard: const TextInputType.numberWithOptions(decimal: true),
                hint: '\$1000',
                validator: positiveNumber,
              ),
              AppTextField(label: 'Content', controller: _note, hint: 'Note (optional)', maxLines: 2),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Transaction fee', style: TextStyle(color: AppColors.muted)),
              Text(usd(_fee), style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Save to directory of beneficiary'),
          value: _save,
          onChanged: (v) => setState(() => _save = v),
        ),
        const SizedBox(height: 8),
        PrimaryButton(label: 'Confirm', onPressed: _next),
      ],
    );
  }
}
