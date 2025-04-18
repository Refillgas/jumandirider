import 'package:flutter/material.dart';
import 'package:jumandi_rider/models/order.dart';
import 'package:jumandi_rider/utils/api_service.dart';
import 'package:jumandi_rider/utils/app_colors.dart';
import 'package:intl/intl.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String trackingId;

  const OrderDetailsScreen({Key? key, required this.trackingId}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  Order? _order;
  bool _processingAction = false;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiService.getOrderDetails(widget.trackingId);
      
      if (response['status'] == 'success' && response['order'] != null) {
        setState(() {
          _order = Order.fromJson(response['order']);
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load order details';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptOrder() async {
    await _processOrderAction(
      action: () => ApiService.acceptOrder(widget.trackingId),
      successMessage: 'Order accepted successfully',
    );
  }

  Future<void> _rejectOrder() async {
    await _processOrderAction(
      action: () => ApiService.rejectOrder(widget.trackingId),
      successMessage: 'Order rejected successfully',
    );
  }

  Future<void> _completeOrder() async {
    await _processOrderAction(
      action: () => ApiService.completeOrder(widget.trackingId),
      successMessage: 'Order completed successfully',
    );
  }

  Future<void> _processOrderAction({
    required Future<Map<String, dynamic>> Function() action,
    required String successMessage,
  }) async {
    setState(() {
      _processingAction = true;
    });

    try {
      final response = await action();
      
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );
        await _loadOrderDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Action failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _processingAction = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.trackingId}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _order == null
                  ? const Center(child: Text('Order not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order Status Card
                          _buildStatusCard(),
                          
                          const SizedBox(height: 24),
                          
                          // Customer Details
                          _buildSectionTitle('Customer Details'),
                          _buildInfoCard([
                            _buildInfoRow('Name', _order!.customerName),
                            _buildInfoRow('Phone', _order!.customerPhone),
                            _buildInfoRow('Address', _order!.deliveryAddress),
                          ]),
                          
                          const SizedBox(height: 24),
                          
                          // Order Items
                          _buildSectionTitle('Order Items'),
                          _buildOrderItems(),
                          
                          const SizedBox(height: 24),
                          
                          // Order Summary
                          _buildSectionTitle('Order Summary'),
                          _buildInfoCard([
                            _buildInfoRow('Order ID', _order!.trackingId),
                            _buildInfoRow('Date', DateFormat('MMM dd, yyyy - hh:mm a').format(_order!.createdAt)),
                            _buildInfoRow('Status', _order!.status.toUpperCase(), 
                              valueColor: _getStatusColor(_order!.status)),
                            _buildInfoRow('Total Amount', '${_order!.currency} ${_order!.amount.toStringAsFixed(2)}',
                              valueStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              )),
                          ]),
                          
                          const SizedBox(height: 24),
                          
                          // Action Buttons
                          _buildActionButtons(),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(_order!.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(_order!.status).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(_order!.status),
                color: _getStatusColor(_order!.status),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Order Status: ${_order!.status.toUpperCase()}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(_order!.status),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getStatusMessage(_order!.status),
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
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
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {
    TextStyle? valueStyle,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Container(
      width: double.infinity,
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
      child: _order!.items.isEmpty
          ? const Text('No items in this order')
          : Column(
              children: _order!.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${item['quantity']}x',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] ?? 'Product',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              item['description'] ?? '',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${_order!.currency} ${(double.parse(item['price'].toString()) * int.parse(item['quantity'].toString())).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildActionButtons() {
    if (_processingAction) {
      return const Center(child: CircularProgressIndicator());
    }

    // Different buttons based on order status
    switch (_order!.status.toLowerCase()) {
      case 'pending':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _acceptOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('ACCEPT ORDER'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _rejectOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('REJECT ORDER'),
              ),
            ),
          ],
        );
      case 'accepted':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _completeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('COMPLETE DELIVERY'),
          ),
        );
      case 'completed':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'This order has been completed',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      case 'cancelled':
      case 'rejected':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cancel, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'This order has been ${_order!.status}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.hourglass_empty;
      case 'accepted':
        return Icons.delivery_dining;
      default:
        return Icons.help;
    }
  }

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'This order is waiting for a rider to accept it.';
      case 'accepted':
        return 'You have accepted this order. Please deliver it to the customer.';
      case 'completed':
        return 'This order has been successfully delivered to the customer.';
      case 'cancelled':
        return 'This order was cancelled by the customer.';
      case 'rejected':
        return 'This order was rejected by you.';
      default:
        return 'Order status unknown.';
    }
  }
}