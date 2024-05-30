import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  CustomAppBar({this.actions});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    final isDarkMode = themeNotifier.isDarkMode;
    final appBarColor = isDarkMode ? Colors.black : Colors.white;
    final iconColor = isDarkMode ? Colors.white : Colors.black;
    final logoAsset = isDarkMode ? 'assets/logo-white-new.svg' : 'assets/logo-black-new.svg';

    return AppBar(
      backgroundColor: appBarColor,
      elevation: 0,
      centerTitle: true,
      title: SvgPicture.asset(
        logoAsset,
        height: 30, // Adjust the height as needed
        color: iconColor,
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
