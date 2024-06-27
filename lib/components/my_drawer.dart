import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // created instance of the provider
    var theme = Theme.of(context).colorScheme;
    var themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Drawer(
      backgroundColor: theme.surface,
      child: Center(
        child: CupertinoSwitch(
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme()),
      ),
    );
  }
}
