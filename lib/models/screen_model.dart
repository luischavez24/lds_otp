import 'package:flutter/material.dart';

class ScreenModel {
  String title;
  Icon icon;
  Widget child;

  ScreenModel({
    this.title,
    @required
    this.icon,
    this.child
  }) : assert(icon != null);

  AppBar get appBarForScreen => AppBar(
    leading: this.icon,
    title: Text(this.title),
  );

  BottomNavigationBarItem get bottomNavigationButton => BottomNavigationBarItem(
    title: Text(this.title),
    icon: this.icon
  );
}