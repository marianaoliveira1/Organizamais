import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/utils/color.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DefaultColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Iconsax.sms),
                hintText: 'Email',
                filled: true,
                fillColor: DefaultColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    24.0,
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
