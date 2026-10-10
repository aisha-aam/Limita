import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../common/flow.dart';

class _SearchItem {
  final String title;
  final IconData icon;
  final Widget Function() page;

  _SearchItem(this.title, this.icon, this.page);
}

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final items = <_SearchItem>[
      _SearchItem('Branch', Icons.location_on_outlined, () => const BranchScreen()),
      _SearchItem('Interest rate', Icons.percent, () => const InterestScreen()),
      _SearchItem('Exchange rate', Icons.currency_exchange, () => const ExchangeRateScreen()),
      _SearchItem('Language', Icons.language, () => const LanguageScreen()),
      _SearchItem('Exchange', Icons.swap_vert_circle_outlined, () => const ExchangeScreen()),
    ].where((e) => e.title.toLowerCase().contains(_query.toLowerCase())).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Search', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Search Here',
            hint: 'Search Here',
            icon: Icons.search,
            onChanged: (v) => setState(() => _query = v),
          ),
          if (items.isEmpty) const EmptyNote('Nothing found'),
          for (final it in items)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: Icon(it.icon, color: AppColors.primary),
                title: Text(it.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => it.page())),
              ),
            ),
        ],
      ),
    );
  }
}

class BranchScreen extends StatefulWidget {
  const BranchScreen({super.key});

  @override
  State<BranchScreen> createState() => _BranchScreenState();
}

class _BranchScreenState extends State<BranchScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final list = branches.where((b) => b.name.toLowerCase().contains(_q.toLowerCase())).toList();
    return PageScaffold(
      title: 'Branch',
      children: [
        AppTextField(
          label: 'Search for branch',
          hint: 'Search for branch',
          icon: Icons.search,
          onChanged: (v) => setState(() => _q = v),
        ),
        if (list.isEmpty) const EmptyNote('No branch found'),
        for (final b in list)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.account_balance, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                Text(b.distance, style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
        const SizedBox(height: 10),
        PrimaryButton(
          label: 'Open Maps',
          onPressed: () => showSnack(context, 'Maps is not available in this demo'),
        ),
      ],
    );
  }
}

class InterestScreen extends StatefulWidget {
  const InterestScreen({super.key});

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final list = interestRates
        .where((i) => '${i.customer} ${i.term} ${i.rate}'.toLowerCase().contains(_q.toLowerCase()))
        .toList();
    return PageScaffold(
      title: 'Interest rate',
      children: [
        AppTextField(
          label: 'Search for interest rate',
          hint: 'Search for interest rate',
          icon: Icons.search,
          onChanged: (v) => setState(() => _q = v),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            children: [
              Expanded(flex: 4, child: Text('Interest kind', style: TextStyle(color: AppColors.muted))),
              Expanded(flex: 2, child: Text('Deposit', style: TextStyle(color: AppColors.muted))),
              Expanded(flex: 2, child: Text('Rate', textAlign: TextAlign.right, style: TextStyle(color: AppColors.muted))),
            ],
          ),
        ),
        for (final i in list)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(flex: 4, child: Text(i.customer)),
                Expanded(flex: 2, child: Text(i.term)),
                Expanded(
                  flex: 2,
                  child: Text(i.rate, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
              ],
            ),
          ),
        if (list.isEmpty) const EmptyNote('Nothing found'),
      ],
    );
  }
}

class ExchangeRateScreen extends StatefulWidget {
  const ExchangeRateScreen({super.key});

  @override
  State<ExchangeRateScreen> createState() => _ExchangeRateScreenState();
}

class _ExchangeRateScreenState extends State<ExchangeRateScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final list = exchangeRates.where((r) => r.country.toLowerCase().contains(_q.toLowerCase())).toList();
    return PageScaffold(
      title: 'Exchange rate',
      children: [
        AppTextField(
          label: 'Search for exchange rate',
          hint: 'Search for exchange rate',
          icon: Icons.search,
          onChanged: (v) => setState(() => _q = v),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text('Country', style: TextStyle(color: AppColors.muted))),
              Expanded(flex: 2, child: Text('Buy', textAlign: TextAlign.right, style: TextStyle(color: AppColors.muted))),
              Expanded(flex: 2, child: Text('Sell', textAlign: TextAlign.right, style: TextStyle(color: AppColors.muted))),
            ],
          ),
        ),
        for (final r in list)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(r.country, style: const TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text(r.buy, textAlign: TextAlign.right)),
                Expanded(flex: 2, child: Text(r.sell, textAlign: TextAlign.right)),
              ],
            ),
          ),
        if (list.isEmpty) const EmptyNote('Nothing found'),
      ],
    );
  }
}

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return PageScaffold(
      title: 'Language',
      children: [
        for (final l in languages)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              title: Text(l),
              trailing: app.language == l ? const Icon(Icons.check_circle, color: AppColors.primary) : const Icon(Icons.circle_outlined, color: AppColors.border),
              onTap: () {
                app.setLanguage(l);
                showSnack(context, 'Language changed to $l');
              },
            ),
          ),
      ],
    );
  }
}

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController(text: '1000');
  late Account _from;
  String _code = 'KRW';

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

  double get _rate => currencyRates[_code]!;

  void _next() {
    if (!_form.currentState!.validate()) return;
    final amount = double.parse(_amount.text.trim());
    if (amount > _from.balance) {
      showSnack(context, 'Your balance is not enough');
      return;
    }
    final app = context.read<AppState>();
    final from = _from;
    final code = _code;
    final received = amount * _rate;
    startTransaction(
      context,
      title: 'Confirm transaction information',
      rows: [
        MapEntry('From', from.label),
        MapEntry('Amount', '${usd(amount)} USD'),
        MapEntry('Currency rate', '1 USD = ${money(_rate, decimals: _rate < 100 ? 1 : 0)} $code'),
        MapEntry('You get', '${money(received)} $code'),
      ],
      successTitle: 'Change Money successfully!',
      successMessage: 'You have successfully change Your Money.',
      onComplete: () => app.spend(from, amount, 'Exchange USD to $code'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    return PageScaffold(
      title: 'Exchange',
      children: [
        AccountPicker(
          accounts: app.accounts,
          selected: _from,
          onChanged: (a) => setState(() => _from = a),
        ),
        Form(
          key: _form,
          child: AppTextField(
            label: 'From (USD)',
            controller: _amount,
            keyboard: const TextInputType.numberWithOptions(decimal: true),
            hint: '1000',
            onChanged: (_) => setState(() {}),
            validator: positiveNumber,
          ),
        ),
        PickerField(
          label: 'To',
          value: currencyNames[_code]!,
          placeholder: 'Select currency',
          onTap: () async {
            final r = await pickFromList(
              context,
              'Select the currency',
              currencyNames.values.toList(),
              current: currencyNames[_code],
            );
            if (r != null) {
              setState(() => _code = currencyNames.entries.firstWhere((e) => e.value == r).key);
            }
          },
        ),
        InfoCard(
          rows: [
            MapEntry('Currency rate', '1 USD = ${money(_rate, decimals: _rate < 100 ? 1 : 0)} $_code'),
            MapEntry('You get', '${money(amount * _rate)} $_code'),
          ],
        ),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Exchange', onPressed: _next),
      ],
    );
  }
}
