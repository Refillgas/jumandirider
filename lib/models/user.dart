class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final double balance;
  final String currency;
  final String token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.balance,
    required this.currency,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      balance: double.parse(json['balance'].toString()),
      currency: json['currency'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'balance': balance,
      'currency': currency,
      'token': token,
    };
  }
}