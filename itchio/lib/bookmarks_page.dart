import 'package:flutter/material.dart';
import 'custom_app_bar.dart';

class BookmarksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: CustomAppBar(),
        body: Center(
          child: Text('Bookmarks Page'),
        ),
      );
  }
}
