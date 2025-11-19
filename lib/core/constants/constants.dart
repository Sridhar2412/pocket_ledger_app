class Constants {
  // Hive Box Names
  static const String authBox = 'authBox';
  static const String walletBox = 'walletBox';
  static const String transactionBox = 'transactionBox';

  // SharedPreferences Keys
  static const String authTokenKey = 'authToken';
  static const String mockTokenKey = 'mockToken';

  // API Configuration
  static const String baseUrl = 'https://api.pocketledger.com/v1/';

  // Transaction Categories
  static const List<String> categories = [
    'Income: Salary',
    'Income: Investment',
    'Expense: Food',
    'Expense: Transport',
    'Expense: Bills',
    'Expense: Entertainment',
    'Expense: Health',
    'Expense: Other'
  ];
}
