import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dotp/dotp.dart';

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
            itemBuilder: (context, index) => _codeList[index]
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            onPressed: scan,
            child: Icon(Icons.photo_camera)
        ),
    );
  }

  Future scan() async {
    try {
      var barcode = await BarcodeScanner.scan();
      setState(() {
        _codeList.add(TOTPWidget.fromBarcode(barcode));
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        debugPrint('The user did not grant the camera permission!');
      } else {
        debugPrint('Unknown error: $e');
      }
    } on FormatException {
      debugPrint('null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      debugPrint('Unknown error: $e');
    }
  }
}

class TOTPWidget extends StatefulWidget {
  final TOTPData totpData;
  TOTPWidget(this.totpData);

  TOTPWidget.fromBarcode(String barcode) : totpData = TOTPData.fromBarcode(
      barcode: barcode
  );

  @override
  State createState() => TOTPState(totpData);
}

class TOTPState extends State<TOTPWidget> {
  TOTPData _totpData;
  Timer _timer;

  TOTPState(TOTPData totpData) {
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
  Widget build(BuildContext context)  {
    return ListTile(
      leading: Icon(Icons.vpn_key),
      title: Text(_totpData.currentCode ?? "", style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 25.0
      ),
      ),
      subtitle: Text(_totpData.toString()),
      trailing: Theme(
        data: Theme.of(context).copyWith(accentColor: Colors.deepPurple),
        child: CircularProgressIndicator(
          value: _totpData.remainTime / 30,
          strokeWidth: 2.0,
        ),
      )
    );
  }
}

class TOTPData {
  String currentCode;
  String issuer;
  String user;
  String domain;

  TOTP _oneTimePassword;
  TOTPData( {
    this.issuer,
    this.user,
    this.domain
  });

  TOTPData.fromBarcode({
    String barcode
  }) {
    var uri =Uri.parse(barcode);
    var path = uri.path.split(":");

    this.domain = path[0] ?? "";
    this.user = path[1] ?? "";
    this.issuer = uri.queryParameters["issuer"];
    _oneTimePassword = TOTP(uri.queryParameters["secret"]);
    refreshCode();
  }

  void refreshCode() {
    currentCode = _oneTimePassword?.now();
  }

  int get remainTime =>_tokenPeriod -  DateTime.now().second % _tokenPeriod;
  String get timer => '$remainTime s';
  String toString() => "$user($domain)";
}