import '../models/models.dart';

const branches = [
  Branch('Bank 1656 Union Street', '30 m'),
  Branch('Bank Rutherford', '70 m'),
  Branch('Bank 1656 Union Street', '50 m'),
  Branch('Bank Secaucus', '1.2 km'),
  Branch('Bank 1657 Riverside Drive', '5.3 km'),
];

const interestRates = [
  InterestItem('Individual customers', '1m', '4.50%'),
  InterestItem('Corporate customers', '2m', '5.50%'),
  InterestItem('Individual customers', '6m', '4.80%'),
  InterestItem('Corporate customers', '6m', '2.50%'),
  InterestItem('Individual customers', '12m', '5.90%'),
  InterestItem('Corporate customers', '8m', '6.50%'),
  InterestItem('Corporate customers', '7m', '6.80%'),
];

const exchangeRates = [
  RateItem('Vietnam', '1.403', '1.746'),
  RateItem('Nicaragua', '9.123', '12.09'),
  RateItem('Korea', '3.704', '5.151'),
  RateItem('Russia', '116.0', '144.4'),
  RateItem('China', '1.725', '2.234'),
  RateItem('Portugal', '1.403', '1.746'),
  RateItem('France', '23.45', '34.56'),
];

const banks = [
  'US bank',
  'Citibank',
  'Bank of America',
  'Wells Fargo',
  'JP Morgan Chase',
  'HSBC bank',
  'Fifth Third',
  'Bank of the West',
];

const bankBranches = ['New York', 'Santa Ana', 'Secaucus', 'Rutherford'];

const languages = [
  'English',
  'Vietnamese',
  'French',
  'Japanese',
  'Portuguese',
  'Chinese',
];

const currencyRates = <String, double>{
  'KRW': 1122,
  'VND': 23000,
  'HKD': 7.8,
  'TWD': 31.5,
  'JMD': 150,
};

const currencyNames = <String, String>{
  'KRW': 'KRW ( Korean Won )',
  'VND': 'VND ( Viet Nam Dong )',
  'HKD': 'HK\$ ( Hong Kong Dollar )',
  'TWD': 'NT\$ ( Taiwan Dollar )',
  'JMD': 'J\$ ( Jamaika Dollar )',
};

const depositPlans = <int, double>{
  3: 4,
  6: 4.5,
  12: 5,
  16: 5.5,
  24: 6,
};
