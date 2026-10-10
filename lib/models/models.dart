class Account {
  final String id;
  final String label;
  final String number;
  final String branch;
  double balance;

  Account({
    required this.id,
    required this.label,
    required this.number,
    required this.branch,
    required this.balance,
  });
}

class CardInfo {
  final String holder;
  final String number;
  final String bank;
  final String validFrom;
  final String goodThru;
  double balance;

  CardInfo({
    required this.holder,
    required this.number,
    required this.bank,
    required this.validFrom,
    required this.goodThru,
    required this.balance,
  });

  String get last4 => number.length >= 4 ? number.substring(number.length - 4) : number;
  String get masked => '**** **** $last4';
}

class Beneficiary {
  final String name;
  final String cardNumber;
  final String bank;
  final String phone;

  Beneficiary({
    required this.name,
    required this.cardNumber,
    required this.bank,
    required this.phone,
  });
}

class TxRecord {
  final String title;
  final double amount;
  final DateTime date;
  final bool success;

  TxRecord({
    required this.title,
    required this.amount,
    required this.date,
    this.success = true,
  });
}

class AppNotice {
  final String title;
  final String body;
  final DateTime date;
  final String kind;

  AppNotice({
    required this.title,
    required this.body,
    required this.date,
    required this.kind,
  });
}

class Bill {
  final String type;
  final double amount;
  final String due;
  final String code;
  bool paid;

  Bill({
    required this.type,
    required this.amount,
    required this.due,
    required this.code,
    this.paid = false,
  });
}

class PaymentRecord {
  final String type;
  final double amount;
  final String month;
  final String date;
  final bool success;
  final String code;

  PaymentRecord({
    required this.type,
    required this.amount,
    required this.month,
    required this.date,
    required this.success,
    required this.code,
  });
}

class Deposit {
  final String account;
  final int months;
  final double rate;
  final double amount;
  final String from;
  final String to;
  final String code;

  Deposit({
    required this.account,
    required this.months,
    required this.rate,
    required this.amount,
    required this.from,
    required this.to,
    required this.code,
  });
}

class Branch {
  final String name;
  final String distance;
  const Branch(this.name, this.distance);
}

class InterestItem {
  final String customer;
  final String term;
  final String rate;
  const InterestItem(this.customer, this.term, this.rate);
}

class RateItem {
  final String country;
  final String buy;
  final String sell;
  const RateItem(this.country, this.buy, this.sell);
}
