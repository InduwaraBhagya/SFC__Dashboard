import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'SigninScreen.dart';
import 'ServiceOrder/screens/SigninScreen.dart';

enum OnboardingDestination { plannedEvent, serviceOrder }

class OnboardingScreen extends StatefulWidget {
  final int? userId;

  const OnboardingScreen({super.key, this.userId});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 5,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'SFC Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 9, 25, 130),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 60),
                  elevation: 5,
                ),
                child: const Text(
                  'Planned Event',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SigninScreen(
                        destination: OnboardingDestination.plannedEvent,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 9, 25, 130),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 60),
                  elevation: 5,
                ),
                child: const Text(
                  'Service Order',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ServiceOrderSigninScreen(
                        destination: OnboardingDestination.serviceOrder,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Logged in user id: ${widget.userId ?? 'not created'}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
