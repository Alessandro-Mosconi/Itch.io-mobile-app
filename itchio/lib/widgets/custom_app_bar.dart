import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Widget? leading; // Add leading property

  CustomAppBar({this.actions, this.leading});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;
    final appBarColor = isDarkMode ? Colors.black : Colors.white;
    final logoAsset = isDarkMode ? 'assets/logo-white-new.svg' : 'assets/logo-black-new.svg';

    return AppBar(
      backgroundColor: appBarColor,
      elevation: 0,
      centerTitle: true,
      title: SvgPicture.asset(
        logoAsset,
        height: 30, // Adjust the height as needed
        // Do not set the color property as it doesn't affect SVG colors
      ),
      actions: actions,
      leading: leading, // Include leading property in the AppBar
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
