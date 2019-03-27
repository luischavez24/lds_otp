import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lds_otp/models/totp_model.dart';
import 'package:lds_otp/storage/db_provider.dart';
import 'package:sqflite/sqflite.dart';

const int _tokenPeriod = 30;

class ScanScreen extends StatefulWidget {
  @override
  _ScanState createState() => new _ScanState();
}

class _ScanState extends State<ScanScreen> {
  List<CodeWidget> _codeList = [];

  @override
  initState() {
    super.initState();
    _chargeCodesFromStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: _codeList.length,
          itemBuilder: (context, index) => _codeList[index]),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          onPressed: _scan,
          child: Icon(Icons.photo_camera)),
    );
  }
  Future _chargeCodesFromStorage () async {
    var codes = await DBProvider.db.getAllCodes();
    setState(() {
      _codeList = codes
          .map((model) => CodeWidget.fromModel(model))
          .toList();
    });
  }


  Future _scan() async {
    try {
      var barcode = await BarcodeScanner.scan();

      DBProvider.db.addCode(CodeModel.fromBarcode(barcode: barcode));

      await _chargeCodesFromStorage();

    } on DatabaseException catch(e) {
      _showErrorMessage('Hubo un problema al acceder a la base de datos');
      debugPrint(e.toString());
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        _showErrorMessage('The user did not grant the camera permission!');
      } else {
        _showErrorMessage('Unknown error: $e');
      }
    } on FormatException {
      _showErrorMessage(
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      _showErrorMessage('Unknown error: $e');
    }
  }

  void _showErrorMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }
}

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
  CodeModel _totpData;
  Timer _timer;

  _CodeState(CodeModel totpData) {
    _totpData = totpData;
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (_totpData.remainTime == _tokenPeriod) {
          _totpData.refreshCode();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Icon(Icons.vpn_key),
        title: Text(
          _totpData.currentCode ?? "",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25.0),
        ),
        subtitle: Text(_totpData.toString()),
        trailing: Theme(
          data: Theme.of(context).copyWith(accentColor: Colors.deepOrange),
          child: CircularProgressIndicator(
            value: _totpData.remainTimeAsPercent,
            strokeWidth: 4.5,
          ),
        ));
  }
}