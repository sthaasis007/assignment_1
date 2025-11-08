abstract class InterestBearing {
  double calculateInterest();
}

// ----------------------
// Base Class: BankAccount
// ----------------------
abstract class BankAccount {
  int _accountNumber;
  String _holderName;
  double _balance;
  List<String> _transactions = [];

  BankAccount(this._accountNumber, this._holderName, this._balance);

  int get accountNumber => _accountNumber;
  String get holderName => _holderName;
  double get balance => _balance;

  set holderName(String name) => _holderName = name;

  void addTransaction(String message) {
    _transactions.add(message);
  }

  List<String> get transactionHistory => List.unmodifiable(_transactions);

  // Abstract methods
  void withdraw(double amount);
  void deposit(double amount);

  void displayInfo() {
    print('\nAccount Number: $_accountNumber');
    print('Account Holder: $_holderName');
    print('Balance: \$${_balance.toStringAsFixed(2)}');
  }

  void updateBalance(double newBalance) {
    _balance = newBalance;
  }
}

// ----------------------
// Savings Account
// ----------------------
class SavingsAccount extends BankAccount implements InterestBearing {
  static const double _minBalance = 500.0;
  static const double _interestRate = 0.02;
  static const int _withdrawLimit = 3;
  int _withdrawCount = 0;

  SavingsAccount(int accountNumber, String holderName, double balance)
      : super(accountNumber, holderName, balance);

  @override
  void withdraw(double amount) {
    if (_withdrawCount >= _withdrawLimit) {
      print('Withdrawal limit reached.');
      addTransaction('Failed withdrawal: limit reached.');
      return;
    }

    if (balance - amount < _minBalance) {
      print('Cannot withdraw below minimum balance of \$$_minBalance.');
      addTransaction('Failed withdrawal: below minimum balance.');
      return;
    }

    updateBalance(balance - amount);
    _withdrawCount++;
    addTransaction('Withdrew \$${amount.toStringAsFixed(2)}');
    print('Withdrew \$${amount.toStringAsFixed(2)} from Savings Account.');
  }

  @override
  void deposit(double amount) {
    if (amount > 0) {
      updateBalance(balance + amount);
      addTransaction('Deposited \$${amount.toStringAsFixed(2)}');
      print('Deposited \$${amount.toStringAsFixed(2)} to Savings Account.');
    }
  }

  @override
  double calculateInterest() {
    double interest = balance * _interestRate;
    print('Interest for $holderName: \$${interest.toStringAsFixed(2)}');
    return interest;
  }
}

// ----------------------
// Checking Account
// ----------------------
class CheckingAccount extends BankAccount {
  static const double _overdraftFee = 35.0;

  CheckingAccount(int accountNumber, String holderName, double balance)
      : super(accountNumber, holderName, balance);

  @override
  void withdraw(double amount) {
    updateBalance(balance - amount);
    if (balance < 0) {
      updateBalance(balance - _overdraftFee);
      print('Overdraft! Fee of \$$_overdraftFee applied.');
      addTransaction('Overdraft fee \$$_overdraftFee charged.');
    }
    addTransaction('Withdrew \$${amount.toStringAsFixed(2)}');
  }

  @override
  void deposit(double amount) {
    if (amount > 0) {
      updateBalance(balance + amount);
      addTransaction('Deposited \$${amount.toStringAsFixed(2)}');
      print('Deposited \$${amount.toStringAsFixed(2)} to Checking Account.');
    }
  }
}

// ----------------------
// Premium Account
// ----------------------
class PremiumAccount extends BankAccount implements InterestBearing {
  static const double _minBalance = 10000.0;
  static const double _interestRate = 0.05;

  PremiumAccount(int accountNumber, String holderName, double balance)
      : super(accountNumber, holderName, balance);

  @override
  void withdraw(double amount) {
    if (balance - amount < _minBalance) {
      print('Cannot withdraw below minimum balance of \$$_minBalance.');
      addTransaction('Failed withdrawal: below minimum balance.');
      return;
    }
    updateBalance(balance - amount);
    addTransaction('Withdrew \$${amount.toStringAsFixed(2)}');
  }

  @override
  void deposit(double amount) {
    if (amount > 0) {
      updateBalance(balance + amount);
      addTransaction('Deposited \$${amount.toStringAsFixed(2)}');
    }
  }

  @override
  double calculateInterest() {
    double interest = balance * _interestRate;
    print('Interest for $holderName: \$${interest.toStringAsFixed(2)}');
    return interest;
  }
}

// ----------------------
// Student Account (New)
// ----------------------
class StudentAccount extends BankAccount {
  static const double _maxBalance = 5000.0;

  StudentAccount(int accountNumber, String holderName, double balance)
      : super(accountNumber, holderName, balance);

  @override
  void withdraw(double amount) {
    if (balance - amount < 0) {
      print('Insufficient funds.');
      addTransaction('Failed withdrawal: insufficient funds.');
      return;
    }
    updateBalance(balance - amount);
    addTransaction('Withdrew \$${amount.toStringAsFixed(2)}');
  }

  @override
  void deposit(double amount) {
    if (balance + amount > _maxBalance) {
      print('Cannot exceed maximum balance of \$$_maxBalance.');
      addTransaction('Failed deposit: exceeds max balance.');
      return;
    }
    updateBalance(balance + amount);
    addTransaction('Deposited \$${amount.toStringAsFixed(2)}');
  }
}

// ----------------------
// Bank Class
// ----------------------
class Bank {
  List<BankAccount> _accounts = [];

  void createAccount(BankAccount account) {
    _accounts.add(account);
    print('Account created for ${account.holderName}.');
  }

  BankAccount? findAccount(int accountNumber) {
    return _accounts.firstWhere(
      (a) => a.accountNumber == accountNumber,
      orElse: () => null as BankAccount,
    );
  }

  void transfer(int fromAcc, int toAcc, double amount) {
    var from = findAccount(fromAcc);
    var to = findAccount(toAcc);
    if (from == null || to == null) {
      print('One of the accounts not found.');
      return;
    }

    from.withdraw(amount);
    to.deposit(amount);
    print('Transferred \$${amount.toStringAsFixed(2)} from ${from.holderName} to ${to.holderName}.');
  }

  // Apply monthly interest to all interest-bearing accounts
  void applyMonthlyInterest() {
    for (var account in _accounts) {
      if (account is InterestBearing) {
        double interest = (account as InterestBearing).calculateInterest();
        account.deposit(interest);
      }
    }
    print('Monthly interest applied to all eligible accounts.');
  }

  void generateReport() {
    print('\n===== BANK REPORT =====');
    for (var account in _accounts) {
      account.displayInfo();
      if (account is InterestBearing) {
        (account as InterestBearing).calculateInterest();
      }
      print('Transactions:');
      for (var t in account.transactionHistory) {
        print(' - $t');
      }
    }
  }
}

// ----------------------
// Main Function
// ----------------------
void main() {
  Bank bank = Bank();

  var acc1 = SavingsAccount(1001, 'Alice', 1500);
  var acc2 = CheckingAccount(1002, 'Bob', 300);
  var acc3 = PremiumAccount(1003, 'Charlie', 20000);
  var acc4 = StudentAccount(1004, 'Diana', 1000);

  bank.createAccount(acc1);
  bank.createAccount(acc2);
  bank.createAccount(acc3);
  bank.createAccount(acc4);

  acc1.withdraw(700);
  acc2.withdraw(500);
  acc3.withdraw(5000);
  acc4.deposit(4500);
  acc4.deposit(600); // should fail

  bank.transfer(1001, 1002, 200);
  bank.applyMonthlyInterest();
  bank.generateReport();
}
