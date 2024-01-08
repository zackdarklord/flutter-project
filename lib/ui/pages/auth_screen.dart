import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../services/biometrics_service.dart';
import 'home_page.dart';
import '../widgets/costum_button.dart';

import "dart:developer" as developer;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final authService = BiometricsService();

  Future<void> _handleAuthClick() async {
    try {
      final isSupported = await authService.checkForBiometricsSupport();

      if (!isSupported) {
        await Fluttertoast.showToast(
          msg: "Your device doesn't support biometric authentication.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: const Color(0xFF972525),
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }

      final isAuthenticated = await authService.authenticateUser(

          'We need your approval to access the application !');

      if (context.mounted) {
        if (!isAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              showCloseIcon: true,
              content: Text(
                'Unable to verify your identity!',
                style: TextStyle(color: Colors.black, fontSize: 17),
              ),
            ),
          );
          return;
        }
        await Get.to(() => const HomePage());
      }
    } catch (e) {
      developer.log('Error during authentication: $e', name: "AUTH");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            showCloseIcon: true,
            content: Text(
              'An error occurred during authentication: $e',
              style: const TextStyle(color: Colors.black, fontSize: 17),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: CustomButton(
          width: size.width * 0.55,
          color: Theme.of(context).colorScheme.primary,
          content: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.fingerprint,
                size: 50,
                  color: Colors.white

              ),
              SizedBox(height: 20),
              Text(
                'Authenticate',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white
                ),
              ),
            ],
          ),
          onPress: () async => await _handleAuthClick(),
        ),
      ),
    );
  }
}
