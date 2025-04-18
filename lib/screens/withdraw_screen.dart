import 'package:flutter/material.dart';
import 'package:jumandi_rider/utils/api_service.dart';
import 'package:jumandi_rider/utils/app_colors.dart';
import 'package:jumandi_rider/widgets/custom_button.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _bankController = TextEditingController();
  final _accountNumberController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _errorMessage = '';
  double _balance = 0.0;
  String _currency = 'NGN';
  
  @override
  void initState() {
    super.initState();
    _loadBalance();
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    _bankController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }
  
  Future<void> _loadBalance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final response = await ApiService.getBalance();
      
      if (response['status'] == 'success') {
        setState(() {
          _balance = double.parse(response['balance'].toString());
          _currency = response['currency'] ?? 'NGN';
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load balance';
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
  
  Future<void> _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });
    
    try {
      final amount = double.parse(_amountController.text);
      final bank = _bankController.text;
      final accountNumber = _accountNumberController.text;
      
      final response = await ApiService.withdrawFunds(amount, bank, accountNumber);
      
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Withdrawal request submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh balance
        await _loadBalance();
        
        // Clear form
        _amountController.clear();
        _bankController.clear();
        _accountNumberController.clear();
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to submit withdrawal request';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please try again.';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw Funds'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty && _balance == 0
              ? Center(child: Text(_errorMessage))
              : SingleChildScrollView(
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
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Withdrawal Form
                      const Text(
                        'Withdraw Funds',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter your bank details to withdraw funds',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      if (_errorMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _amountController,
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                prefixText: '$_currency ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an amount';
                                }
                                
                                final amount = double.tryParse(value);
                                if (amount == null) {
                                  return 'Please enter a valid amount';
                                }
                                
                                if (amount <= 0) {
                                  return 'Amount must be greater than 0';
                                }
                                
                                if (amount > _balance) {
                                  return 'Amount cannot exceed your balance';
                                }
                                
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _bankController,
                              decoration: InputDecoration(
                                labelText: 'Bank Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your bank name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _accountNumberController,
                              decoration: InputDecoration(
                                labelText: 'Account Number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your account number';
                                }
                                
                                if (value.length < 10) {
                                  return 'Please enter a valid account number';
                                }
                                
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            CustomButton(
                              text: 'WITHDRAW FUNDS',
                              onPressed: _submitWithdrawal,
                              isLoading: _isSubmitting,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Withdrawal Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'Withdrawal Information',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• Minimum withdrawal amount: $_currency 500',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• Processing time: 1-3 business days',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• Withdrawal fee: $_currency 50',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}