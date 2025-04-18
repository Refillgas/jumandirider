import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL - change this to your server address
  static const String baseUrl = 'https://jumandigas.com/api/rider';
  
  // Endpoints
  static const String loginEndpoint = '/rider_login.php';
  static const String registerEndpoint = '/rider_register.php';
  static const String forgotPasswordEndpoint = '/rider_forgot_password.php';
  static const String getOrdersEndpoint = '/get_rider_orders.php';
  static const String getOrderDetailsEndpoint = '/get_order_details.php';
  static const String acceptOrderEndpoint = '/accept_order.php';
  static const String rejectOrderEndpoint = '/reject_order.php';
  static const String completeOrderEndpoint = '/complete_order.php';
  static const String getBalanceEndpoint = '/get_rider_balance.php';
  static const String withdrawFundsEndpoint = '/withdraw_funds.php';
  
  // Headers
  static Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  // Register
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String address,
    required String country,
    required String state,
    required String city,
    required String currency,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$registerEndpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'address': address,
        'country': country,
        'state': state,
        'city': city,
        'currency': currency,
        'role': 'rider', // Specify role as rider
      }),
    );
    
    return jsonDecode(response.body);
  }
  
  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl$loginEndpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    return jsonDecode(response.body);
  }
  
  // Forgot Password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl$forgotPasswordEndpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
      }),
    );
    
    return jsonDecode(response.body);
  }
  
  // Get Orders
  static Future<Map<String, dynamic>> getOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl$getOrdersEndpoint'),
      headers: await _getHeaders(),
    );
    
    return jsonDecode(response.body);
  }
  
  // Get Order Details
  static Future<Map<String, dynamic>> getOrderDetails(String trackingId) async {
    final response = await http.get(
      Uri.parse('$baseUrl$getOrderDetailsEndpoint?tracking_id=$trackingId'),
      headers: await _getHeaders(),
    );
    
    return jsonDecode(response.body);
  }
  
  // Accept Order
  static Future<Map<String, dynamic>> acceptOrder(String trackingId) async {
    final response = await http.post(
      Uri.parse('$baseUrl$acceptOrderEndpoint'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'tracking_id': trackingId,
      }),
    );
    
    return jsonDecode(response.body);
  }
  
  // Reject Order
  static Future<Map<String, dynamic>> rejectOrder(String trackingId) async {
    final response = await http.post(
      Uri.parse('$baseUrl$rejectOrderEndpoint'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'tracking_id': trackingId,
      }),
    );
    
    return jsonDecode(response.body);
  }
  
  // Complete Order
  static Future<Map<String, dynamic>> completeOrder(String trackingId) async {
    final response = await http.post(
      Uri.parse('$baseUrl$completeOrderEndpoint'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'tracking_id': trackingId,
      }),
    );
    
    return jsonDecode(response.body);
  }
  
  // Get Balance
  static Future<Map<String, dynamic>> getBalance() async {
    final response = await http.get(
      Uri.parse('$baseUrl$getBalanceEndpoint'),
      headers: await _getHeaders(),
    );
    
    final responseData = jsonDecode(response.body);
    final balance = double.tryParse(responseData['balance'].toString()) ?? 0.0;
    return {
      'balance': balance,
      ...responseData,
    };
  }
  
  // Withdraw Funds
  static Future<Map<String, dynamic>> withdrawFunds(
    double amount, 
    String bank, 
    String accountNumber
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$withdrawFundsEndpoint'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'amount': amount,
        'bank': bank,
        'account_number': accountNumber,
      }),
    );
    
    return jsonDecode(response.body);
  }
}
