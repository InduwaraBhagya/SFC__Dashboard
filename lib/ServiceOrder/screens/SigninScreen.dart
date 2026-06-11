import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../service/AuthService.dart' as auth;
import 'SelectWorkgroupScreen.dart';
import '../../OnboardingScreen.dart';

class ServiceOrderSigninScreen extends StatefulWidget {
  final OnboardingDestination destination;

  const ServiceOrderSigninScreen(
      {super.key, this.destination = OnboardingDestination.serviceOrder});

  @override
  State<ServiceOrderSigninScreen> createState() =>
      _ServiceOrderSigninScreenState();
}

class _ServiceOrderSigninScreenState extends State<ServiceOrderSigninScreen> {
  late auth.AuthService _authService;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _authService = auth.AuthService();
  }

  Future<void> _handleMicrosoftLogin() async {
    setState(() => _loading = true);

    try {
      print('Starting Microsoft login process for Service Order...');
      final user = await _authService.login();
      print('Login result: $user');

      if (user != null && user.isNotEmpty) {
        print('Login successful! Navigating to onboarding...');
        print('User data: $user');

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SelectWorkgroupScreen(
                destination: widget.destination,
              ),
            ),
          );
        }
      } else {
        print('Login failed: user data is null or empty');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login failed. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Login error in UI: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login failed: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(''),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(226, 16, 37, 89),
                Color.fromARGB(255, 8, 11, 66),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Align(
            alignment: Alignment.center,
            child: ListView(
              shrinkWrap: true,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/microsoft_logo.png',
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Microsoft',
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const Text(
                  'Service Order Sign in',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Use your Microsoft account',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _handleMicrosoftLogin,
                    icon: const Icon(Icons.login, color: Colors.white),
                    label: _loading
                        ? CircularProgressIndicator(
                            color: Theme.of(context).cardColor,
                          )
                        : Text(
                            'Login with Microsoft',
                            style: TextStyle(
                                color: Theme.of(context).cardColor,
                                fontSize: 16),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 59, 96, 155),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
