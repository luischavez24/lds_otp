import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lds_otp/models/totp_model.dart';
import 'package:lds_otp/storage/db_provider.dart';

const int _tokenPeriod = 30;

class ScanScreen extends StatefulWidget {
  @override
  _ScanState createState() => new _ScanState();
}

class _ScanState extends State<ScanScreen> {
  List<TOTPWidget> _codeList = [];

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: _codeList.length,
          itemBuilder: (context, index) => _codeList[index]),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          onPressed: _scan,
          child: Icon(Icons.photo_camera)),
    );
  }

  Future _scan() async {
    try {
      var barcode = await BarcodeScanner.scan();

      DBProvider.db.addCode(
          CodeModel(codeId: barcode.hashCode.toString(), barcode: barcode));

      var codes = await DBProvider.db.getAllCodes();

      setState(() {
        // _codeList.add(TOTPWidget.fromBarcode(barcode));
        _codeList = codes
            .map((model) => TOTPWidget.fromBarcode(model.barcode))
            .toList();
      });
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

class TOTPWidget extends StatefulWidget {
  final TOTPData totpData;

  TOTPWidget(this.totpData);

  TOTPWidget.fromBarcode(String barcode)
      : totpData = TOTPData.fromBarcode(barcode: barcode);

  @override
  State createState() => _TOTPState(totpData);
}

class _TOTPState extends State<TOTPWidget> {
  TOTPData _totpData;
  Timer _timer;

  _TOTPState(TOTPData totpData) {
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
          data: Theme.of(context).copyWith(accentColor: Colors.deepPurple),
          child: CircularProgressIndicator(
            value: _totpData.remainTimeAsPercent,
            strokeWidth: 4.5,
          ),
        ));
  }
}
