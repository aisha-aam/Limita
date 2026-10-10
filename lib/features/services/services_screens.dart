import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../models/models.dart';
import '../common/flow.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _amount = TextEditingController();
  late Account _from;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _from = app.accounts.first;
    _phone.text = '+8564757899';
  }

  @override
  void dispose() {
    _phone.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _next() {
    if (!_form.currentState!.validate()) return;
    final amount = double.parse(_amount.text.trim());
    if (amount > _from.balance) {
      showSnack(context, 'Your balance is not enough');
      return;
    }
    final app = context.read<AppState>();
    final from = _from;
    startTransaction(
      context,
      title: 'Confirm transaction information',
      rows: [
        MapEntry('From', from.label),
        MapEntry('Phone number', _phone.text.trim()),
        MapEntry('Amount', usd(amount)),
      ],
      successTitle: 'Successful withdrawal!',
      successMessage: 'You have successfully withdrawn money!\nPlease check the balance in the card management section.',
      onComplete: () => app.spend(from, amount, 'Withdraw'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return PageScaffold(
      title: 'Withdraw',
      children: [
        AccountPicker(
          accounts: app.accounts,
          selected: _from,
          onChanged: (a) => setState(() => _from = a),
        ),
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Phone number',
                controller: _phone,
                keyboard: TextInputType.phone,
                icon: Icons.phone_outlined,
                validator: notEmpty,
              ),
              AmountInput(controller: _amount),
            ],
          ),
        ),
        const SizedBox(height: 10),
        PrimaryButton(label: 'Confirm', onPressed: _next),
      ],
    );
  }
}

class PrepaidScreen extends StatefulWidget {
  const PrepaidScreen({super.key});

  @override
  State<PrepaidScreen> createState() => _PrepaidScreenState();
}

class _PrepaidScreenState extends State<PrepaidScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _amount = TextEditingController();
  late Account _from;

  @override
  void initState() {
    super.initState();
    _from = context.read<AppState>().accounts.first;
  }

  @override
  void dispose() {
    _phone.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _fromDirectory() async {
    final app = context.read<AppState>();
    final withPhone = app.beneficiaries.where((b) => b.phone.isNotEmpty).toList();
    if (withPhone.isEmpty) {
      showSnack(context, 'Your directory has no phone numbers');
      return;
    }
    final r = await pickFromList(context, 'Directory', withPhone.map((b) => '${b.name}  ${b.phone}').toList());
    if (r != null) {
      setState(() => _phone.text = r.split('  ').last);
    }
  }

  void _next() {
    if (!_form.currentState!.validate()) return;
    final amount = double.parse(_amount.text.trim());
    if (amount > _from.balance) {
      showSnack(context, 'Your balance is not enough');
      return;
    }
    final app = context.read<AppState>();
    final from = _from;
    final phone = _phone.text.trim();
    startTransaction(
      context,
      title: 'Confirm transaction information',
      rows: [
        MapEntry('From', from.label),
        MapEntry('To', phone),
        MapEntry('Amount', usd(amount)),
      ],
      successTitle: 'Payment success!',
      successMessage: 'You have successfully paid mobile prepaid!',
      onComplete: () => app.spend(from, amount, 'Mobile prepaid $phone'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return PageScaffold(
      title: 'Mobile prepaid',
      children: [
        AccountPicker(
          accounts: app.accounts,
          selected: _from,
          onChanged: (a) => setState(() => _from = a),
        ),
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Phone number',
                controller: _phone,
                keyboard: TextInputType.phone,
                hint: '+8564757899',
                icon: Icons.phone_outlined,
                validator: notEmpty,
                suffix: IconButton(icon: const Icon(Icons.contacts_outlined), onPressed: _fromDirectory),
              ),
              AmountInput(controller: _amount, amounts: const [10, 20, 30]),
            ],
          ),
        ),
        const SizedBox(height: 10),
        PrimaryButton(label: 'Confirm', onPressed: _next),
      ],
    );
  }
}

class CreditCardScreen extends StatelessWidget {
  const CreditCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final card = app.cards.isNotEmpty ? app.cards.first : null;
    final total = app.creditPurchases.fold<double>(0, (s, t) => s + t.amount);
    return PageScaffold(
      title: 'Credit card',
      children: [
        if (card != null)
          BankCardView(
            title: card.bank,
            number: '${card.number.substring(0, 4)} **** **** ${card.last4}',
            holder: card.holder,
            balance: card.balance,
          )
        else
          const EmptyNote('Add a card first to see your credit card activity'),
        const SectionLabel('Transactions'),
        for (final t in app.creditPurchases)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(fmtDate(t.date), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                    ],
                  ),
                ),
                Text(usd(t.amount), style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w700)),
            Text(usd(total), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.danger)),
          ],
        ),
      ],
    );
  }
}

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late DateTime _month;

  static const _names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final now = DateTime.now();
    final months = [for (var i = 5; i >= 0; i--) DateTime(now.year, now.month - i)];
    final list = app.history.where((t) => t.date.year == _month.year && t.date.month == _month.month).toList();
    final spent = list.where((t) => t.amount < 0 && t.success).fold<double>(0, (s, t) => s + t.amount.abs());
    final income = list.where((t) => t.amount > 0 && t.success).fold<double>(0, (s, t) => s + t.amount);

    return PageScaffold(
      title: 'Transaction report',
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final m in months)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_names[m.month - 1]),
                    selected: m.year == _month.year && m.month == _month.month,
                    onSelected: (_) => setState(() => _month = m),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _summary('Income', income, AppColors.success)),
            const SizedBox(width: 12),
            Expanded(child: _summary('Spent', spent, AppColors.danger)),
          ],
        ),
        const SizedBox(height: 8),
        if (list.isEmpty) const EmptyNote('No transactions in this month'),
        for (final t in list) TxTile(tx: t),
        if (spent > app.shoppingLimit)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'You are over your limit of ${usd(app.shoppingLimit)} this month',
              style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  Widget _summary(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 4),
          Text(usd(value), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class BeneficiaryScreen extends StatefulWidget {
  const BeneficiaryScreen({super.key});

  @override
  State<BeneficiaryScreen> createState() => _BeneficiaryScreenState();
}

class _BeneficiaryScreenState extends State<BeneficiaryScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = app.beneficiaries.where((b) => b.name.toLowerCase().contains(_q.toLowerCase())).toList();
    return PageScaffold(
      title: 'Beneficiary',
      actions: [
        IconButton(
          icon: const Icon(Icons.person_add_alt_1_outlined),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddBeneficiaryScreen())),
        ),
      ],
      children: [
        AppTextField(
          label: 'Find beneficiary',
          hint: 'Find beneficiary',
          icon: Icons.search,
          onChanged: (v) => setState(() => _q = v),
        ),
        if (list.isEmpty) const EmptyNote('No beneficiary found'),
        for (final b in list)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(b.name[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
              title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${b.bank} · ${b.cardNumber}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                onPressed: () {
                  app.removeBeneficiary(b);
                  showSnack(context, '${b.name} removed');
                },
              ),
            ),
          ),
      ],
    );
  }
}

class AddBeneficiaryScreen extends StatefulWidget {
  const AddBeneficiaryScreen({super.key});

  @override
  State<AddBeneficiaryScreen> createState() => _AddBeneficiaryScreenState();
}

class _AddBeneficiaryScreenState extends State<AddBeneficiaryScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _card = TextEditingController();
  final _bank = TextEditingController(text: 'US bank');
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _card.dispose();
    _bank.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    context.read<AppState>().addBeneficiary(
          Beneficiary(
            name: _name.text.trim(),
            cardNumber: _card.text.trim(),
            bank: _bank.text.trim(),
            phone: _phone.text.trim(),
          ),
        );
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(const SnackBar(content: Text('Beneficiary added')));
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Add new',
      children: [
        Form(
          key: _form,
          child: Column(
            children: [
              AppTextField(label: 'Name', controller: _name, hint: 'Olivia', validator: notEmpty),
              AppTextField(
                label: 'Card number',
                controller: _card,
                keyboard: TextInputType.number,
                hint: '0345976231',
                validator: (v) => (v == null || v.trim().length < 8) ? 'Enter a valid card number' : null,
              ),
              AppTextField(label: 'Bank', controller: _bank, validator: notEmpty),
              AppTextField(label: 'Phone number (optional)', controller: _phone, keyboard: TextInputType.phone),
            ],
          ),
        ),
        PrimaryButton(label: 'Save to directory', onPressed: _save),
      ],
    );
  }
}
