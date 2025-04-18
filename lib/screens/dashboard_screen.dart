import 'package:flutter/material.dart';
import 'package:jumandi_rider/models/order.dart';
import 'package:jumandi_rider/screens/order_details_screen.dart';
import 'package:jumandi_rider/screens/withdraw_screen.dart';
import 'package:jumandi_rider/utils/api_service.dart';
import 'package:jumandi_rider/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  double _balance = 0.0;
  String _currency = 'NGN';
  List<Order> _recentOrders = [];
  List<Map<String, dynamic>> _rideHistory = [];
  
  // WhatsApp support number - replace with your actual support number
  static const String _whatsappNumber = '+2347018933739';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get balance
      final balanceResponse = await ApiService.getBalance();
      if (balanceResponse['status'] == 'success') {
        setState(() {
          final balanceValue = balanceResponse['balance'];
          if (balanceValue != null && balanceValue.toString().isNotEmpty) {
            _balance = double.tryParse(balanceValue.toString()) ?? 0.0;
          } else {
            _balance = 0.0; // Default value if balance is null or empty
          }
          _currency = balanceResponse['currency'] ?? 'NGN';
        });
      } else {
        setState(() {
          _errorMessage = balanceResponse['message'] ?? 'Failed to fetch balance';
        });
      }

      // Get orders
      final ordersResponse = await ApiService.getOrders();
      if (ordersResponse['status'] == 'success' && ordersResponse['orders'] != null) {
        final ordersList = ordersResponse['orders'] as List;
        setState(() {
          _recentOrders = ordersList
              .map((order) => Order.fromJson(order))
              .where((order) => order.status == 'pending' || order.status == 'accepted')
              .toList();
        });
      }

      // Get ride history
      if (ordersResponse['status'] == 'success' && ordersResponse['history'] != null) {
        final historyList = ordersResponse['history'] as List;
        setState(() {
          _rideHistory = List<Map<String, dynamic>>.from(historyList);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load dashboard data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Function to open WhatsApp chat
  Future<void> _openWhatsAppChat() async {
    const message = "Hello, I'm a Jumandi Gas rider and I need assistance.";
    final whatsappUri = Uri.parse("https://wa.me/$_whatsappNumber?text=${Uri.encodeComponent(message)}");
    
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      // Check if widget is still mounted before showing SnackBar
      if (!mounted) return;
      
      // Show error if WhatsApp can't be launched
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch WhatsApp. Please make sure it is installed.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Balance Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Available Balance',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$_currency ${_balance.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildActionButton(
                                      'Withdraw',
                                      Icons.account_balance_wallet,
                                      () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const WithdrawScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildActionButton(
                                      'History',
                                      Icons.history,
                                      () {
                                        _showRideHistoryModal(context);
                                      },
                                    ),
                                    _buildActionButton(
                                      'Refresh',
                                      Icons.refresh,
                                      _loadDashboardData,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Recent Orders
                          const Text(
                            'Recent Orders',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          _recentOrders.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _recentOrders.length,
                                  itemBuilder: (context, index) {
                                    final order = _recentOrders[index];
                                    return _buildOrderCard(context, order);
                                  },
                                ),
                          
                          const SizedBox(height: 24),
                          
                          // Stats Section
                          const Text(
                            'Your Stats',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              _buildStatCard(
                                'Total Rides',
                                _rideHistory.length.toString(),
                                Icons.directions_bike,
                              ),
                              const SizedBox(width: 16),
                              _buildStatCard(
                                'This Month',
                                _getThisMonthRides().toString(),
                                Icons.calendar_today,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildStatCard(
                                'Completed',
                                _getCompletedRides().toString(),
                                Icons.check_circle,
                              ),
                              const SizedBox(width: 16),
                              _buildStatCard(
                                'Cancelled',
                                _getCancelledRides().toString(),
                                Icons.cancel,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
      // Add WhatsApp floating action button
      floatingActionButton: FloatingActionButton(
        onPressed: _openWhatsAppChat,
        backgroundColor: Colors.green,
        tooltip: 'Contact Support',
        child: const FaIcon(FontAwesomeIcons.whatsapp, size: 28),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No recent orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'New orders will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(trackingId: order.trackingId),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.trackingId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: order.status == 'pending'
                        ? Colors.orange[100]
                        : Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      color: order.status == 'pending'
                          ? Colors.orange[800]
                          : Colors.green[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.deliveryAddress,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.currency} ${order.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsScreen(trackingId: order.trackingId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRideHistoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ride History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _rideHistory.isEmpty
                    ? Center(
                        child: Text(
                          'No ride history available',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _rideHistory.length,
                        itemBuilder: (context, index) {
                          final ride = _rideHistory[index];
                          return ListTile(
                            title: Text(
                              'Order #${ride['tracking_id']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ride['delivery_address'] ?? 'N/A'),
                                Text(
                                  DateFormat('MMM dd, yyyy - hh:mm a').format(
                                    DateTime.parse(ride['created_at']),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatAmount(ride['total_price'], ride['currency'] ?? _currency),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(ride['status'])
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    ride['status'].toString().toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(ride['status']),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to safely format amount values
  String _formatAmount(dynamic amount, String currency) {
    if (amount == null || amount.toString().isEmpty) return '$currency 0.00';

    try {
      final value = double.tryParse(amount.toString()) ?? 0.0;
      return '$currency ${value.toStringAsFixed(2)}';
    } catch (e) {
      return '$currency 0.00'; // Default value if parsing fails
    }
  }

  Color _getStatusColor(dynamic status) {
    switch (status.toString().toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  int _getThisMonthRides() {
    final now = DateTime.now();
    return _rideHistory.where((ride) {
      try {
        final rideDate = DateTime.parse(ride['created_at']);
        return rideDate.month == now.month && rideDate.year == now.year;
      } catch (e) {
        return false;
      }
    }).length;
  }

  int _getCompletedRides() {
    return _rideHistory.where((ride) => 
      ride['status']?.toString().toLowerCase() == 'completed'
    ).length;
  }

  int _getCancelledRides() {
    return _rideHistory.where((ride) => 
      ride['status']?.toString().toLowerCase() == 'cancelled'
    ).length;
  }
}
