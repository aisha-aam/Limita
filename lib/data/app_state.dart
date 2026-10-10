import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/models.dart';

class AppState extends ChangeNotifier {
  String firstName = 'John';
  String lastName = 'Weliams';
  String phone = '0332249402';
  String password = '123456';
  String language = 'English';
  double shoppingLimit = 2000;
  String? resetCode;
  bool _limitWarned = false;

  final List<Account> accounts = [
    Account(id: 'a1', label: 'VISA **** **** **** 1234', number: '1900 8988 5456', branch: 'New York', balance: 10000),
    Account(id: 'a2', label: 'VISA **** **** **** 5678', number: '1900 8112 5222', branch: 'New York', balance: 12000),
    Account(id: 'a3', label: 'VISA **** **** **** 9012', number: '1900 1234 2222', branch: 'New York', balance: 230000),
  ];

  final List<CardInfo> cards = [
    CardInfo(
      holder: 'John Weliams',
      number: '4756234512349018',
      bank: 'Amazon Platinium',
      validFrom: '10/24',
      goodThru: '10/29',
      balance: 3469.52,
    ),
  ];

  final List<Beneficiary> beneficiaries = [
    Beneficiary(name: 'Emma', cardNumber: '1235647899012', bank: 'US bank', phone: '+8564757899'),
    Beneficiary(name: 'Justin', cardNumber: '0345976231', bank: 'Citibank', phone: '+8424599721'),
    Beneficiary(name: 'Amanda', cardNumber: '0123456789', bank: 'US bank', phone: '+8412345678'),
  ];

  late final List<TxRecord> history = _seedHistory();
  late final List<AppNotice> notices = _seedNotices();

  final List<TxRecord> creditPurchases = [
    TxRecord(title: 'Buy Camera', amount: -1200, date: DateTime(2024, 11, 2)),
    TxRecord(title: 'Buy Television', amount: -1200, date: DateTime(2024, 11, 2)),
    TxRecord(title: 'Buy Camera', amount: -700, date: DateTime(2024, 10, 20)),
  ];

  final List<Bill> bills = [
    Bill(type: 'Electric', amount: 480, due: '02/11/2024', code: '#2343543'),
    Bill(type: 'Water', amount: 280, due: '05/11/2024', code: '#8841200'),
    Bill(type: 'Internet', amount: 60, due: '08/11/2024', code: '#2343543'),
    Bill(type: 'Mobile', amount: 50, due: '10/11/2024', code: '#7720013'),
  ];

  final List<PaymentRecord> payments = [
    PaymentRecord(type: 'Electric', amount: 480, month: 'October', date: '30/10/2024', success: false, code: '#2343543'),
    PaymentRecord(type: 'Water', amount: 50, month: 'October', date: '30/10/2024', success: false, code: '#8841200'),
    PaymentRecord(type: 'Electric', amount: 480, month: 'September', date: '30/09/2024', success: true, code: '#2343543'),
    PaymentRecord(type: 'Internet', amount: 50, month: 'September', date: '30/09/2024', success: true, code: '#2343543'),
    PaymentRecord(type: 'Mobile', amount: 50, month: 'August', date: '30/08/2024', success: true, code: '#7720013'),
    PaymentRecord(type: 'Electric', amount: 480, month: 'August', date: '30/08/2024', success: true, code: '#2343543'),
  ];

  final List<Deposit> deposits = [];

  String get fullName => '$firstName $lastName';

  List<TxRecord> _seedHistory() {
    final now = DateTime.now();
    DateTime ago(int days) => now.subtract(Duration(days: days));
    return [
      TxRecord(title: 'Shopping', amount: -280, date: now),
      TxRecord(title: 'Water Bill', amount: -280, date: now, success: false),
      TxRecord(title: 'Income: Salary', amount: 1200, date: ago(1)),
      TxRecord(title: 'Electric Bill', amount: -480, date: ago(1)),
      TxRecord(title: 'Income: Jane transfers', amount: 500, date: ago(1)),
      TxRecord(title: 'Internet Bill', amount: -100, date: ago(4)),
      TxRecord(title: 'Monthly outings', amount: -150, date: ago(35)),
      TxRecord(title: 'Income: Salary', amount: 1200, date: ago(38)),
      TxRecord(title: 'Water Bill', amount: -280, date: ago(66)),
      TxRecord(title: 'Shopping', amount: -520, date: ago(70)),
      TxRecord(title: 'Income: Salary', amount: 1200, date: ago(98)),
      TxRecord(title: 'Electric Bill', amount: -460, date: ago(130)),
    ];
  }

  List<AppNotice> _seedNotices() {
    final now = DateTime.now();
    return [
      AppNotice(
        title: 'Payment Successful',
        body: 'Your upcoming bills were successfully paid with Smart Pay.',
        date: now,
        kind: 'payment',
      ),
      AppNotice(
        title: 'Shopping Limit',
        body: "You're halfway through your monthly shopping budget. Keep an eye on your spending.",
        date: now.subtract(const Duration(days: 2)),
        kind: 'limit',
      ),
      AppNotice(
        title: 'Card Added',
        body: 'Your bank card ending in 4825925120007 was added successfully.',
        date: now.subtract(const Duration(days: 5)),
        kind: 'card',
      ),
    ];
  }

  bool signIn(String p, String pw) => p.trim() == phone && pw == password;

  void register(String name, String p, String pw) {
    final parts = name.trim().split(RegExp(r'\s+'));
    firstName = parts.first;
    lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    phone = p.trim();
    password = pw;
    notifyListeners();
  }

  String sendResetCode() {
    resetCode = (1000 + Random().nextInt(9000)).toString();
    return resetCode!;
  }

  void setPassword(String pw) {
    password = pw;
    notifyListeners();
  }

  void updateProfile(String first, String last, String p) {
    firstName = first;
    lastName = last;
    phone = p;
    notifyListeners();
  }

  void setLanguage(String value) {
    language = value;
    notifyListeners();
  }

  void setLimit(double value) {
    shoppingLimit = value;
    _limitWarned = false;
    notifyListeners();
  }

  void _addNotice(String title, String body, String kind) {
    notices.insert(0, AppNotice(title: title, body: body, date: DateTime.now(), kind: kind));
  }

  void spend(Account from, double amount, String title, {double fee = 0}) {
    from.balance -= amount + fee;
    history.insert(0, TxRecord(title: title, amount: -amount, date: DateTime.now()));
    _addNotice('Payment Successful', '$title was completed successfully.', 'payment');
    _checkLimit();
    notifyListeners();
  }

  void _checkLimit() {
    final now = DateTime.now();
    final spent = history
        .where((t) => t.amount < 0 && t.success && t.date.year == now.year && t.date.month == now.month)
        .fold<double>(0, (sum, t) => sum + t.amount.abs());
    if (!_limitWarned && spent >= shoppingLimit / 2) {
      _limitWarned = true;
      _addNotice(
        'Shopping Limit',
        "You've reached 50% of your monthly shopping limit.",
        'limit',
      );
    }
  }

  void transfer({
    required Account from,
    required String toName,
    required String card,
    required String bank,
    required double amount,
    required double fee,
    required bool save,
  }) {
    spend(from, amount, 'Transfer to $toName', fee: fee);
    if (save && !beneficiaries.any((b) => b.cardNumber == card)) {
      beneficiaries.add(Beneficiary(name: toName, cardNumber: card, bank: bank, phone: ''));
      notifyListeners();
    }
  }

  void payBill(Bill bill, Account from) {
    spend(from, bill.amount, '${bill.type} bill');
    bill.paid = true;
    payments.insert(
      0,
      PaymentRecord(
        type: bill.type,
        amount: bill.amount,
        month: _monthName(DateTime.now().month),
        date: _today(),
        success: true,
        code: bill.code,
      ),
    );
    notifyListeners();
  }

  void paySmart(Account from) {
    final open = bills.where((b) => !b.paid).toList();
    if (open.isEmpty) return;
    final total = open.fold<double>(0, (s, b) => s + b.amount);
    spend(from, total, 'Smart Pay');
    for (final b in open) {
      b.paid = true;
      payments.insert(
        0,
        PaymentRecord(
          type: b.type,
          amount: b.amount,
          month: _monthName(DateTime.now().month),
          date: _today(),
          success: true,
          code: b.code,
        ),
      );
    }
    notifyListeners();
  }

  void addDeposit(Account from, int months, double rate, double amount) {
    spend(from, amount, 'Save online');
    final start = DateTime.now();
    final end = DateTime(start.year, start.month + months, start.day);
    deposits.insert(
      0,
      Deposit(
        account: from.number,
        months: months,
        rate: rate,
        amount: amount,
        from: _fmt(start),
        to: _fmt(end),
        code: '${12788980000 + Random().nextInt(9999)}',
      ),
    );
    notifyListeners();
  }

  void addCard(CardInfo card) {
    cards.add(card);
    _addNotice('Card Added', 'Your bank card ending in ${card.last4} was added successfully.', 'card');
    notifyListeners();
  }

  void removeCard(CardInfo card) {
    cards.remove(card);
    notifyListeners();
  }

  void addBeneficiary(Beneficiary b) {
    beneficiaries.add(b);
    notifyListeners();
  }

  void removeBeneficiary(Beneficiary b) {
    beneficiaries.remove(b);
    notifyListeners();
  }

  String _today() => _fmt(DateTime.now());

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _monthName(int m) => const [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][m - 1];
}
