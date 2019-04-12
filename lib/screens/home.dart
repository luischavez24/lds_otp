import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lds_otp/bloc/preferences_bloc.dart';
import 'package:lds_otp/screens/scan.dart';
import 'package:lds_otp/screens/preferences.dart';
import 'package:lds_otp/models/screen_model.dart';
import 'package:lds_otp/bloc/codes_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  State createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<ScreenModel> _appScreens;
  CodesBloc _codesBloc;
  PreferencesBloc _preferencesBloc;

  @override
  void initState() {
    super.initState();
    _appScreens = _createScreens();
    _codesBloc = CodesBloc();
    _preferencesBloc = PreferencesBloc();
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
          title: "Preferencias",
          child: PreferencesScreen()
      )
    ];
  }

  BottomNavigationBar _buildNavigationBar() => BottomNavigationBar(
        currentIndex: _currentIndex,
        items: (_appScreens ?? [])
            .map((screen) => screen.bottomNavigationButton)
            .toList(),
        onTap: (screenIndex) {
          setState(() { _currentIndex = screenIndex; });
        }
      );

  AppBar _buildAppBar() => AppBar(
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

  Widget _buildBody() => _appScreens[_currentIndex].child;

  Future _logoff () async {
    await Navigator.of(context).pushNamedAndRemoveUntil('/auth', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _buildAppBar(),
        body: BlocProviderTree(
          blocProviders: [
            BlocProvider<CodesBloc>(bloc: _codesBloc),
            BlocProvider<PreferencesBloc>(bloc: _preferencesBloc)
          ],
          child: _buildBody()
        ),
        bottomNavigationBar: _buildNavigationBar()
      );

  @override
  void dispose() {
    _codesBloc.dispose();
    _preferencesBloc.dispose();
    super.dispose();
  }
}