import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lds_otp/models/code_model.dart';
import 'package:lds_otp/storage/db_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
          itemBuilder: (context, index) {
            final codeItem = _codeList[index];
            final codeModel = codeItem.codeModel;
            return Dismissible(
              key: Key(codeModel.toString()),
              child: codeItem,
              secondaryBackground: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  color: Colors.redAccent,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.delete, color: Colors.white),
                      Text("Eliminado", style: TextStyle(color: Colors.white))
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                  )),
              background: Container(),
              confirmDismiss: (DismissDirection direction) async {
                if (direction == DismissDirection.endToStart) {
                  return await _showConfirmDialog(codeModel);
                }
                return false;
              },
              onDismissed: (DismissDirection direction) {
                if (direction == DismissDirection.endToStart) {
                  _deleteCode(codeModel);
                }
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          onPressed: _scan,
          child: Icon(FontAwesomeIcons.qrcode)),
    );
  }

  Future<bool> _showConfirmDialog(CodeModel codeModel) async {
    var isConfirm = await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("Borrar código"),
          content:Text("¿Está seguro de eliminar el código para $codeModel?"),
          actions: <Widget>[
            FlatButton(child: Text("Si"), onPressed: () => Navigator.pop(context, true)),
            FlatButton(child: Text("No"), onPressed: () => Navigator.pop(context, false)),
          ],
        )
    );
    return isConfirm ?? false;
  }

  _deleteCode(CodeModel codeModel) {
    DBProvider.db.deleteCode(codeModel.user, codeModel.domain);
    _chargeCodesFromStorage();
  }

  Future _chargeCodesFromStorage() async {
    var codes = await DBProvider.db.getAllCodes();
    setState(() {
      _codeList = codes.map((model) => CodeWidget.fromModel(model)).toList();
    });
  }

  Future _scan() async {
    try {
      var barcode = await BarcodeScanner.scan();
      DBProvider.db.addCode(CodeModel.fromBarcode(barcode: barcode));
      await _chargeCodesFromStorage();
    } on DatabaseException catch (e) {
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

  _showErrorMessage(String message) {
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
  CodeModel _codeModel;
  Timer _timer;

  _CodeState(CodeModel totpData) {
    _codeModel = totpData;
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (_codeModel.remainTime == _tokenPeriod) {
          _codeModel.refreshCode();
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
  Widget build(BuildContext context) => ListTile(
      leading: Icon(Icons.vpn_key),
      title: Text(
        _displayCode(_codeModel.currentCode),
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25.0),
      ),
      subtitle: Text(_codeModel.toString()),
      trailing: Theme(
        data: Theme.of(context).copyWith(accentColor: Colors.deepOrange),
        child: CircularProgressIndicator(
          value: _codeModel.remainTimeAsPercent,
          strokeWidth: 4.5,
        ),
      )
  );
  String _displayCode(String code) => "${code?.substring(0,3)} ${code?.substring(3)}";
}
