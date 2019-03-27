import 'package:flutter/material.dart';
import './scan.dart';
import 'package:lds_otp/utils/screen_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  State createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<ScreenModel> _appScreens;

  _HomeState() {
    _appScreens = _createScreens();
  }

  BottomNavigationBar get _bottomNavigationBar => BottomNavigationBar(
    currentIndex: _currentIndex,
    items: (_appScreens ?? [])
        .map((screen) => screen.bottomNavigationButton)
        .toList(),
    onTap: (screenIndex) {
      setState(() {
        _currentIndex = screenIndex;
      });
    },
  );

  List<ScreenModel> _createScreens() {
    return [
      ScreenModel(
          icon: Icon(Icons.lock),
          title: "Códigos",
          child: ScanScreen()),
      ScreenModel(
        icon: Icon(Icons.settings),
        title: "Configuración",
        child: Container()
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    var currentScreen = _appScreens[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        leading: currentScreen.icon,
        title: Text(currentScreen.title),
      ),
      body: currentScreen.child,
      bottomNavigationBar: _bottomNavigationBar,
    );
  }
}