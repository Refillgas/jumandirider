import 'package:flutter/material.dart';
import 'package:jumandi_rider/screens/dashboard_screen.dart';
import 'package:jumandi_rider/screens/login_screen.dart';
import 'package:jumandi_rider/screens/order_list_screen.dart';
import 'package:jumandi_rider/utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const DashboardScreen(),
    const OrderListScreen(),
    const Center(child: Text('Account')),
  ];
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user_data');
    if (userData != null) {
      // Parse user data and get name
      // This is a simplified approach - in a real app, you'd use proper JSON parsing
      if (userData.contains('name')) {
        final nameStart = userData.indexOf('name') + 5;
        final nameEnd = userData.indexOf(',', nameStart);
        setState(() {
          _userName = userData.substring(nameStart, nameEnd).replaceAll("'", "");
        });
      }
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome'),
            Text(
              _userName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _logout,
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => setState(() => _currentIndex = 0),
              color: _currentIndex == 0 ? AppColors.primary : Colors.grey,
            ),
            FloatingActionButton(
              onPressed: () => setState(() => _currentIndex = 1),
              backgroundColor: AppColors.primary,
              child: const Text(
                'Ride\nOrders',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => setState(() => _currentIndex = 2),
              color: _currentIndex == 2 ? AppColors.primary : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}