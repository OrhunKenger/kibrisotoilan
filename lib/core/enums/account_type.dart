enum AccountType {
  individual,
  corporate;

  String toDisplayString() {
    switch (this) {
      case AccountType.individual:
        return 'Bireysel';
      case AccountType.corporate:
        return 'Kurumsal';
    }
  }

  String toBackendString() {
    return name;
  }

  static AccountType fromBackendString(String name) {
    return AccountType.values.firstWhere((e) => e.name == name, orElse: () => AccountType.individual);
  }
}
