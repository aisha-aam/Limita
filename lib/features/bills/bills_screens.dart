import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../common/flow.dart';

IconData _billIcon(String type) {
  switch (type) {
    case 'Electric':
      return Icons.bolt;
    case 'Water':
      return Icons.water_drop_outlined;
    case 'Internet':
      return Icons.wifi;
    default:
      return Icons.phone_android;
  }
}

class PayBillScreen extends StatefulWidget {
  const PayBillScreen({super.key});

  @override
  State<PayBillScreen> createState() => _PayBillScreenState();
}

class _PayBillScreenState extends State<PayBillScreen> {
  late Account _from;

  @override
  void initState() {
    super.initState();
    _from = context.read<AppState>().accounts.first;
  }

  void _smartPay(AppState app) {
    final open = app.bills.where((b) => !b.paid).toList();
    if (open.isEmpty) {
      showSnack(context, 'All your bills are paid');
      return;
    }
    final total = open.fold<double>(0, (s, b) => s + b.amount);
    if (total > _from.balance) {
      showSnack(context, 'Your balance is not enough');
      return;
    }
    final from = _from;
    startTransaction(
      context,
      title: 'Smart Pay',
      rows: [
        MapEntry('From', from.label),
        for (final b in open) MapEntry('${b.type} bill', usd(b.amount)),
        MapEntry('TOTAL', usd(total)),
      ],
      successTitle: 'Payment success!',
      successMessage: 'You have successfully paid your upcoming bills.',
      onComplete: () => app.paySmart(from),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final total = app.bills.where((b) => !b.paid).fold<double>(0, (s, b) => s + b.amount);
    return PageScaffold(
      title: 'Pay the bill',
      actions: [
        IconButton(
          tooltip: 'Payment history',
          icon: const Icon(Icons.history),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentHistoryScreen())),
        ),
      ],
      children: [
        AccountPicker(
          accounts: app.accounts,
          selected: _from,
          onChanged: (a) => setState(() => _from = a),
        ),
        for (final b in app.bills)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(_billIcon(b.type), color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${b.type} bill', style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('Pay ${b.type.toLowerCase()} bill this month', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                      Text('Due ${b.due}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(usd(b.amount), style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    b.paid
                        ? const Text('Paid', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600))
                        : SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => BillDetailScreen(bill: b, from: _from)),
                              ),
                              child: const Text('Pay'),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Smart Pay', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Text('TOTAL ${usd(-total)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              PrimaryButton(label: 'Pay all in one tap', onPressed: () => _smartPay(app)),
            ],
          ),
        ),
      ],
    );
  }
}

class BillDetailScreen extends StatefulWidget {
  final Bill bill;
  final Account from;

  const BillDetailScreen({super.key, required this.bill, required this.from});

  @override
  State<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  final _code = TextEditingController();
  bool _checked = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _check() {
    if (_code.text.trim().length < 4) {
      showSnack(context, 'Please enter the correct bill code to check information.');
      return;
    }
    setState(() => _checked = true);
  }

  void _pay() {
    final bill = widget.bill;
    final from = widget.from;
    if (bill.amount > from.balance) {
      showSnack(context, 'Your balance is not enough');
      return;
    }
    final app = context.read<AppState>();
    final tax = bill.amount > 10 ? 10.0 : 0.0;
    startTransaction(
      context,
      title: 'Confirm transaction information',
      rows: [
        MapEntry('From', from.label),
        MapEntry('Bill code', _code.text.trim()),
        MapEntry('${bill.type} fee', usd(bill.amount - tax)),
        MapEntry('Tax', usd(tax)),
        MapEntry('TOTAL', usd(bill.amount)),
      ],
      successTitle: 'Transaction successfully!',
      successMessage: "You've pay your ${bill.type.toLowerCase()} bill!",
      onComplete: () => app.payBill(bill, from),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bill = widget.bill;
    final tax = bill.amount > 10 ? 10.0 : 0.0;
    return PageScaffold(
      title: '${bill.type} bill',
      children: [
        const Text('Type bill code', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        AppTextField(label: 'Bill code', controller: _code, hint: bill.code),
        if (!_checked) ...[
          const Text(
            'Please enter the correct bill code to check information.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Check', onPressed: _check),
        ] else ...[
          InfoCard(
            rows: [
              const MapEntry('Name', 'Jackson Maine'),
              const MapEntry('Address', '403 East 4th Street, Santa Ana'),
              const MapEntry('Phone number', '+8424599721'),
              MapEntry('Code', bill.code),
              MapEntry('Period', '01/10/2024 - 01/11/2024'),
              MapEntry('${bill.type} fee', usd(bill.amount - tax)),
              MapEntry('Tax', usd(tax)),
              MapEntry('TOTAL', usd(bill.amount)),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Pay', onPressed: _pay),
        ],
      ],
    );
  }
}

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  String _filter = 'All';

  void _details(PaymentRecord p) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${p.type} payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: Jackson Maine'),
            Text('Address: 403 East 4th Street, Santa Ana'),
            Text('Code: ${p.code}'),
            Text('Company: Capi Telecom'),
            Text('Date: ${p.date}'),
            Text('Amount: ${usd(p.amount)}'),
            Text('Status: ${p.success ? 'Successfully' : 'Unsuccessfully'}'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Ok'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final filters = ['All', 'Electric', 'Water', 'Internet', 'Mobile'];
    final list = app.payments.where((p) => _filter == 'All' || p.type == _filter).toList();
    return PageScaffold(
      title: 'Payment history',
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final f in filters)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (list.isEmpty) const EmptyNote('No payments yet'),
        for (final p in list)
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _details(p),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(_billIcon(p.type), color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${p.month} · ${p.type}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(p.date, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(usd(p.amount), style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                        p.success ? 'Successfully' : 'Unsuccessfully',
                        style: TextStyle(fontSize: 12, color: p.success ? AppColors.success : AppColors.danger),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class SaveOnlineScreen extends StatelessWidget {
  const SaveOnlineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Save online'),
          bottom: const TabBar(tabs: [Tab(text: 'Add'), Tab(text: 'Management')]),
        ),
        body: const SafeArea(
          child: TabBarView(children: [_AddDeposit(), _ManageDeposits()]),
        ),
      ),
    );
  }
}

class _AddDeposit extends StatefulWidget {
  const _AddDeposit();

  @override
  State<_AddDeposit> createState() => _AddDepositState();
}

class _AddDepositState extends State<_AddDeposit> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  late Account _from;
  int _months = 12;

  @override
  void initState() {
    super.initState();
    _from = context.read<AppState>().accounts.first;
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  String _planLabel(int m) => '$m months (Interest rate ${depositPlans[m]}%)';

  void _next() {
    if (!_form.currentState!.validate()) return;
    final amount = double.parse(_amount.text.trim());
    if (amount < 1000) {
      showSnack(context, 'The amount must be at least \$1000');
      return;
    }
    if (amount > _from.balance) {
      showSnack(context, 'Your balance is not enough');
      return;
    }
    final app = context.read<AppState>();
    final rate = depositPlans[_months]!;
    final from = _from;
    final months = _months;
    startTransaction(
      context,
      title: 'Confirm transaction information',
      rows: [
        MapEntry('Account', from.number),
        MapEntry('Time deposit', '$months months'),
        MapEntry('Interest rate', '$rate%'),
        MapEntry('Amount', usd(amount)),
      ],
      successTitle: 'Save online successfully!',
      successMessage: 'Congratulations!\nYou have save money online successfully!',
      onComplete: () => app.addDeposit(from, months, rate, amount),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    final rate = depositPlans[_months]!;
    final interest = amount * rate * _months / 12 / 100;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        AccountPicker(
          accounts: app.accounts,
          selected: _from,
          onChanged: (a) => setState(() => _from = a),
        ),
        PickerField(
          label: 'Choose time deposit',
          value: _planLabel(_months),
          placeholder: 'Select',
          onTap: () async {
            final r = await pickFromList(
              context,
              'Choose time deposit',
              depositPlans.keys.map(_planLabel).toList(),
              current: _planLabel(_months),
            );
            if (r != null) {
              setState(() => _months = depositPlans.keys.firstWhere((m) => _planLabel(m) == r));
            }
          },
        ),
        Form(
          key: _form,
          child: AppTextField(
            label: 'Amount (At least \$1000)',
            controller: _amount,
            keyboard: const TextInputType.numberWithOptions(decimal: true),
            hint: '\$ 3000',
            onChanged: (_) => setState(() {}),
            validator: positiveNumber,
          ),
        ),
        InfoCard(
          rows: [
            MapEntry('Interest rate', '$rate%/ $_months months'),
            MapEntry('Expected interest', usd(interest, decimals: 2)),
          ],
        ),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Verify', onPressed: _next),
      ],
    );
  }
}

class _ManageDeposits extends StatelessWidget {
  const _ManageDeposits();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (app.deposits.isEmpty) {
      return const EmptyNote('You have no save online account yet');
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        const Text('Manage your save online account', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 12),
        for (final d in app.deposits)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InfoCard(
              rows: [
                MapEntry('Account', d.account),
                MapEntry('From', d.from),
                MapEntry('To', d.to),
                MapEntry('Time deposit', '${d.months} months'),
                MapEntry('Interest rate', '${d.rate}%'),
                MapEntry('Amount', usd(d.amount)),
                MapEntry('Code', d.code),
              ],
            ),
          ),
      ],
    );
  }
}
