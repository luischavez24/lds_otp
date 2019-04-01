import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lds_otp/models/code_model.dart';
import 'package:lds_otp/utils/constants.dart';

class CodeWidget extends StatefulWidget {
  final CodeModel codeModel;

  CodeWidget(this.codeModel);

  CodeWidget.fromBarcode(String barcode)
      : codeModel = CodeModel.fromBarcode(barcode: barcode);

  CodeWidget.fromModel(this.codeModel);

  @override
  State createState() => _CodeState(codeModel);
}

class _CodeState extends State<CodeWidget> {
  CodeModel _codeModel;
  Timer _timer;

  _CodeState(this._codeModel);

  _initTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (_codeModel.remainTime == TOKEN_PERIOD) {
          _codeModel.refreshCode();
        }
      });
    });
  }

  _cancelTimer() => _timer?.cancel();

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListTile(
      leading: Icon(Icons.vpn_key),
      title: Text(
        _displayCode(_codeModel.currentCode),
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25.0),
      ),
      subtitle: Text(_codeModel.toString()),
      trailing:  CircularProgressIndicator(
        value: _codeModel.remainTimeAsPercent,
        strokeWidth: 4.5,
      )
  );
  String _displayCode(String code) => "${code?.substring(0,3)} ${code?.substring(3)}";
}