import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../common/flow.dart';

class AccountCardScreen extends StatelessWidget {
  const AccountCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Account and card'),
          bottom: const TabBar(tabs: [Tab(text: 'Account'), Tab(text: 'Card')]),
        ),
        body: const SafeArea(
          child: TabBarView(children: [_AccountList(), _CardList()]),
        ),
      ),
    );
  }
}

class _AccountList extends StatelessWidget {
  const _AccountList();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        for (var i = 0; i < app.accounts.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(app.accounts[i].number, style: const TextStyle(color: AppColors.muted, letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Available balance', style: TextStyle(color: AppColors.muted)),
                      Text(usd(app.accounts[i].balance), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Branch', style: TextStyle(color: AppColors.muted)),
                      Text(app.accounts[i].branch),
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

class _CardList extends StatelessWidget {
  const _CardList();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        if (app.cards.isEmpty) const EmptyNote('You have no cards yet'),
        for (final c in app.cards)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CardDetailScreen(card: c))),
              child: BankCardView(
                title: c.bank,
                number: '${c.number.substring(0, 4)} **** **** ${c.last4}',
                holder: c.holder,
                balance: c.balance,
              ),
            ),
          ),
        const SizedBox(height: 6),
        PrimaryButton(
          label: 'Add card',
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddCardScreen())),
        ),
      ],
    );
  }
}

class CardDetailScreen extends StatelessWidget {
  final CardInfo card;

  const CardDetailScreen({super.key, required this.card});

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete card'),
        content: Text('Do you want to delete the card ending in ${card.last4}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      context.read<AppState>().removeCard(card);
      Navigator.of(context).pop();
      messenger.showSnackBar(const SnackBar(content: Text('Deleted Successfuly')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Card',
      children: [
        BankCardView(
          title: card.bank,
          number: '${card.number.substring(0, 4)} **** **** ${card.last4}',
          holder: card.holder,
          balance: card.balance,
        ),
        const SizedBox(height: 18),
        InfoCard(
          rows: [
            MapEntry('Name', card.holder),
            MapEntry('Card number', card.masked),
            MapEntry('Valid from', card.validFrom),
            MapEntry('Good thru', card.goodThru),
            MapEntry('Available balance', usd(card.balance, decimals: 2)),
          ],
        ),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Delete card', color: AppColors.danger, outlined: true, onPressed: () => _delete(context)),
      ],
    );
  }
}

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _form = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _cvv = TextEditingController();
  String _bank = '';

  @override
  void dispose() {
    _number.dispose();
    _name.dispose();
    _phone.dispose();
    _cvv.dispose();
    super.dispose();
  }

  void _next() {
    if (!_form.currentState!.validate()) return;
    if (_bank.isEmpty) {
      showSnack(context, 'Please choose the bank');
      return;
    }
    final app = context.read<AppState>();
    final number = _number.text.replaceAll(' ', '');
    final name = _name.text.trim();
    final bank = _bank;
    final now = DateTime.now();
    startTransaction(
      context,
      title: 'Confirm transaction information',
      rows: [
        MapEntry('Your Name', name),
        MapEntry('Card Number', '**** **** ${number.substring(number.length - 4)}'),
        MapEntry('Bank Name', bank),
      ],
      successTitle: 'Your Card Added Successfuly',
      successMessage: 'You can now see the card in the card management section.',
      onComplete: () => app.addCard(
        CardInfo(
          holder: name,
          number: number,
          bank: bank,
          validFrom: '${two(now.month)}/${(now.year % 100)}',
          goodThru: '${two(now.month)}/${(now.year % 100) + 5}',
          balance: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Add card',
      children: [
        Form(
          key: _form,
          child: Column(
            children: [
              AppTextField(
                label: 'Card Number',
                controller: _number,
                keyboard: TextInputType.number,
                hint: '1235 6478 990',
                validator: (v) => (v == null || v.replaceAll(' ', '').length < 8) ? 'Enter a valid card number' : null,
              ),
              AppTextField(label: 'Your Name', controller: _name, hint: 'John Weliams', validator: notEmpty),
              AppTextField(
                label: 'Phone Number',
                controller: _phone,
                keyboard: TextInputType.phone,
                hint: '(+96)230 156 885',
                validator: notEmpty,
              ),
              PickerField(
                label: 'Bank Name',
                value: _bank,
                placeholder: 'Choose bank',
                onTap: () async {
                  final r = await pickFromList(context, 'Choose bank', banks, current: _bank);
                  if (r != null) setState(() => _bank = r);
                },
              ),
              AppTextField(
                label: 'CVV / CVC',
                controller: _cvv,
                keyboard: TextInputType.number,
                hint: '845',
                validator: (v) => (v == null || v.trim().length < 3) ? 'Enter the 3 digits code' : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        PrimaryButton(label: 'Confirm', onPressed: _next),
      ],
    );
  }
}
