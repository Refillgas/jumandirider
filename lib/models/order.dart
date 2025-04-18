class Order {
  final String id;
  final String trackingId;
  final String status;
  final String deliveryAddress;
  final double amount;
  final String currency;
  final DateTime createdAt;
  final String customerName;
  final String customerPhone;
  final List<Map<String, dynamic>> items;

  Order({
    required this.id,
    required this.trackingId,
    required this.status,
    required this.deliveryAddress,
    required this.amount,
    required this.currency,
    required this.createdAt,
    required this.customerName,
    required this.customerPhone,
    required this.items,
  });

  // Add this getter for totalPrice
  double get totalPrice => amount;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      trackingId: json['tracking_id'].toString(),
      status: json['status'].toString(),
      deliveryAddress: json['delivery_address'].toString(),
      amount: double.parse(json['amount'].toString()),
      currency: json['currency'].toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      customerName: json['customer_name'].toString(),
      customerPhone: json['customer_phone'].toString(),
      items: json['items'] != null
          ? List<Map<String, dynamic>>.from(json['items'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tracking_id': trackingId,
      'status': status,
      'delivery_address': deliveryAddress,
      'amount': amount,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'items': items,
    };
  }
}