import 'package:flutter/material.dart';
import 'custom_app_bar.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: Text('Search Page'),
      ),
    );
  }
}
