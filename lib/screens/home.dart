import 'package:flutter/material.dart';
import 'package:lds_otp/screens/scan.dart';
import 'package:lds_otp/screens/config.dart';
import 'package:lds_otp/models/screen_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  List<ScreenModel> _createScreens() {
    return [
      ScreenModel(
          icon: Icon(Icons.security),
          title: "Códigos",
          child: ScanScreen()
      ),
      ScreenModel(
          icon: Icon(Icons.settings),
          title: "Configuración",
          child: ConfigScreen()
      )
    ];
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

  AppBar get _appBar => AppBar(
        leading: _appScreens[_currentIndex].icon,
        title: Text(
          _appScreens[_currentIndex].title,
            style: TextStyle(
            fontWeight: FontWeight.w600
          ),
        ),
        actions: <Widget>[
          IconButton(
              onPressed: _logoff ,
              icon: Icon(FontAwesomeIcons.signOutAlt)
          )
        ],
      );

  Future _logoff () async {
    await Navigator.of(context).pushNamedAndRemoveUntil('/auth', (Route<dynamic> route) => false);
  }

  Widget get _body => _appScreens[_currentIndex].child;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _appBar,
        body: _body,
        bottomNavigationBar: _bottomNavigationBar,
      );
}