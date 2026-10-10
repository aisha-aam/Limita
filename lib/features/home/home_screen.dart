import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../bills/bills_screens.dart';
import '../cards/cards_screens.dart';
import '../services/services_screens.dart';
import '../settings/settings_screens.dart';
import '../transfer/transfer_screen.dart';
import '../utilities/utilities_screens.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeTab(),
          NotificationsTab(),
          SearchTab(),
          SettingsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Notifications'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
    );
  }
}

class _Service {
  final String label;
  final IconData icon;
  final Widget Function() page;

  _Service(this.label, this.icon, this.page);
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final services = <_Service>[
      _Service('Account\nand Card', Icons.account_balance_wallet_outlined, () => const AccountCardScreen()),
      _Service('Transfer', Icons.swap_horiz, () => const TransferScreen()),
      _Service('Withdraw', Icons.atm_outlined, () => const WithdrawScreen()),
      _Service('Mobile\nprepaid', Icons.phone_android, () => const PrepaidScreen()),
      _Service('Pay the\nbill', Icons.receipt_long_outlined, () => const PayBillScreen()),
      _Service('Save\nonline', Icons.savings_outlined, () => const SaveOnlineScreen()),
      _Service('Credit\ncard', Icons.credit_card, () => const CreditCardScreen()),
      _Service('Transaction\nreport', Icons.bar_chart, () => const ReportScreen()),
      _Service('Beneficiary', Icons.people_outline, () => const BeneficiaryScreen()),
    ];

    final hasCard = app.cards.isNotEmpty;
    final card = hasCard ? app.cards.first : null;
    final cardNumber = card != null ? '${card.number.substring(0, 4)} **** **** ${card.last4}' : app.accounts.first.number;
    final balance = card?.balance ?? app.accounts.first.balance;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome back', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                    Text('Hi, ${app.fullName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccountCardScreen())),
            child: BankCardView(
              title: card?.bank ?? 'Limita Account',
              number: cardNumber,
              holder: card?.holder ?? app.fullName,
              balance: balance,
            ),
          ),
          const SizedBox(height: 22),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              for (final s in services)
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => s.page())),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(s.icon, color: AppColors.primary, size: 28),
                        const SizedBox(height: 8),
                        Text(s.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SectionLabel('Recent transactions'),
          for (final t in app.history.take(3)) TxTile(tx: t),
        ],
      ),
    );
  }
}

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  IconData _icon(String kind) {
    switch (kind) {
      case 'payment':
        return Icons.check_circle_outline;
      case 'limit':
        return Icons.warning_amber_rounded;
      case 'card':
        return Icons.credit_card;
      default:
        return Icons.notifications_none;
    }
  }

  Color _color(String kind) {
    switch (kind) {
      case 'payment':
        return AppColors.success;
      case 'limit':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Notifications', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          if (app.notices.isEmpty) const EmptyNote('No notifications yet'),
          for (final n in app.notices)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: _color(n.kind).withOpacity(0.12),
                    child: Icon(_icon(n.kind), color: _color(n.kind)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(dayLabel(n.date), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(n.body, style: const TextStyle(color: AppColors.muted, height: 1.35)),
                      ],
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
