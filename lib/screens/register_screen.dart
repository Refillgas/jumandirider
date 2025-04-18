import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jumandi_rider/screens/login_screen.dart';
import 'package:jumandi_rider/utils/app_colors.dart';
import 'package:jumandi_rider/widgets/jumandi_logo.dart';
import 'package:jumandi_rider/utils/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  String? selectedCountry;
  String? selectedState;
  String? selectedCity;
  String? selectedCurrency;
  bool _isLoading = false;

  final Map<String, Map<String, dynamic>> states = {
    "nigeria": {
      "states": {
        "Lagos": ["Ikeja", "Lekki", "Victoria Island"],
        "Abuja": ["Garki", "Maitama", "Wuse"],
        "Kano": ["Fagge", "Gwale", "Kumbotso"]
      },
      "currency": "NGN"
    },
    "ghana": {
      "states": {
        "Accra": ["Osu", "Madina", "East Legon"],
        "Kumasi": ["Asafo", "Bantama", "Suame"],
        "Takoradi": ["Sekondi", "Anaji", "Airport Ridge"]
      },
      "currency": "GHS"
    }
  };

  List<String> getStateList() {
    return selectedCountry != null
        ? states[selectedCountry]!['states'].keys.toList()
        : [];
  }

  List<String> getCityList() {
    return selectedState != null
        ? states[selectedCountry]!['states'][selectedState] ?? []
        : [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || !_agreeToTerms) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please agree to the terms and conditions'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use the ApiService register method
      final response = await ApiService.register(
        fullName: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        address: _addressController.text,
        country: selectedCountry ?? '',
        state: selectedState ?? '',
        city: selectedCity ?? '',
        currency: selectedCurrency ?? '',
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message']), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Registration failed'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Blue wave background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 220, // Increased height to accommodate logo
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(80),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Centered Logo
                    Center(
                      child: JumandiLogo(
                        size: 100,
                        isRider: true,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Create Rider Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Sign up now to start delivering with Jumandi Gas.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(
                      controller: _nameController,
                      icon: Icons.person,
                      label: 'Full Name',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your name'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _emailController,
                      icon: Icons.email,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _phoneController,
                      icon: Icons.phone,
                      label: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your phone number'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _addressController,
                      icon: Icons.location_on,
                      label: 'Address',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your address'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildDropdown(
                      value: selectedCountry,
                      items: ["nigeria", "ghana"],
                      label: "Select Country",
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCountry = newValue;
                          selectedState = null;
                          selectedCity = null;
                          selectedCurrency = states[newValue]?['currency'];
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildDropdown(
                      value: selectedState,
                      items: getStateList(),
                      label: "Select State",
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedState = newValue;
                          selectedCity = null;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildDropdown(
                      value: selectedCity,
                      items: getCityList(),
                      label: "Select City",
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCity = newValue;
                        });
                      },
                    ),
                    if (selectedCurrency != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          "Currency: $selectedCurrency",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _passwordController,
                      icon: Icons.lock,
                      label: 'Password',
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      icon: Icons.lock,
                      label: 'Confirm Password',
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: Text(
                            'I agree to the Terms and Conditions and Privacy Policy',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('CREATE ACCOUNT'),
                        ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary),
        labelText: label,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String label,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
