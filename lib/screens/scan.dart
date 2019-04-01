import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sqflite/sqflite.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:lds_otp/widgets/code_widget.dart';
import 'package:lds_otp/utils/messages.dart';
import 'package:lds_otp/models/code_model.dart';
import 'package:lds_otp/storage/db_provider.dart';

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
                      Text("Eliminando", style: TextStyle(color: Colors.white))
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                  )),
              background: Container(),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  return await _showConfirmDialog(codeModel);
                }
                return false;
              },
              onDismissed: (direction) {
                if (direction == DismissDirection.endToStart) {
                  _deleteCode(codeModel);
                }
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
          onPressed: _scan,
          child: Icon(FontAwesomeIcons.qrcode)
      ),
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
      showErrorMessage(context, 'Hubo un problema al acceder a la base de datos ($e).');
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        showErrorMessage(context, 'La aplicación no tiene permisos para usar la cámara');
      } else {
        showErrorMessage(context, 'Error desconocido: $e');
      }
    } on FormatException {
      showErrorMessage(context, 'No se escaneó ningún código');
    } catch (e) {
      showErrorMessage(context, 'Unknown error: $e');
    }
  }

  _deleteCode(CodeModel codeModel) {
    DBProvider.db.deleteCode(codeModel.user, codeModel.domain);
    _chargeCodesFromStorage();
  }
}