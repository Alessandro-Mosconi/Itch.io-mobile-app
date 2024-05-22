import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'oauth_service.dart';
import 'theme_notifier.dart';

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final OAuthService authService = Provider.of<OAuthService>(context, listen: false);

    final logoAsset = 'assets/logo-black-new.svg';

    return Scaffold(
      appBar: AppBar(
        title: Text('Itch.io Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: SvgPicture.asset(
                logoAsset,
                height: 150, // Increased the height for a larger logo
              ),
            ),
            SizedBox(height: 40),
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  authService.startOAuth();
                },
                icon: Icon(Icons.login, size: 32), // Made the icon bigger
                label: Text('Login with Itch.io', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
