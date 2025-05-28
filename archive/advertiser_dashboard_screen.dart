import 'package:flutter/material.dart';

class AdvertiserDashboardScreen extends StatelessWidget {
  const AdvertiserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Advertiser Dashboard'),
      ),
      body: Center(
        child: Text('Welcome to the Advertiser Dashboard!'),
      ),
    );
  }
}
