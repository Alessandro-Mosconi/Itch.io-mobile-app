import 'package:flutter/material.dart';
import '/widgets/bottom_navigation_bar.dart';

class BottomNavigationWrapper extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTap;

  BottomNavigationWrapper({
    required this.child,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
      ),
    );
  }
}
