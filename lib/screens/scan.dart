import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sqflite/sqflite.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lds_otp/models/code_model.dart';
import 'package:lds_otp/bloc/codes_bloc.dart';
import 'package:lds_otp/widgets/code_widget.dart';
import 'package:lds_otp/utils/messages.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanState createState() => new _ScanState();
}

class _ScanState extends State<ScanScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _codeBloc = BlocProvider.of<CodesBloc>(context);
    return Scaffold(
      body: BlocBuilder(
          bloc: _codeBloc,
          builder: (context, state) {
            if (state is CodesLoading) {
              return Center(
                child: CircularProgressIndicator(value: null, strokeWidth: 4.5)
              );
            } else if(state is CodesLoaded) {
              return _buildCodeList(_codeBloc, state);
            } else if(state is CodesNotLoaded) {
              return Center(
                child: Text("No se pudieron cargar los codigos"),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _scan(_codeBloc),
          child: Icon(FontAwesomeIcons.qrcode)
      )
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

  Widget _buildCodeList(CodesBloc codesProvider, CodesLoaded state) {
    final codeWidgets = _mapModelToWidget(state.codes);
    return ListView.builder(
        itemCount: codeWidgets.length,
        itemBuilder: (context, index) {
          final codeWidget = codeWidgets[index];
          final codeModel = codeWidget.codeModel;
          return Dismissible(
            key: Key(codeModel.toString()),
            direction: DismissDirection.endToStart,
            child: codeWidget,
            secondaryBackground: _buildDeleteActionBackground(),
            background: Container(),
            confirmDismiss: (direction) async => await _onConfirmDismiss(codeModel),
            onDismissed: (direction) => _onDismiss(codesProvider, codeModel)
          );
        }
    );
  }

  Widget _buildDeleteActionBackground() => Container(
    padding: EdgeInsets.symmetric(horizontal: 20.0),
    color: Colors.redAccent,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Icon(Icons.delete, color: Colors.white),
        Text("Eliminando", style: TextStyle(color: Colors.white))
      ],
    )
  );

  List<CodeWidget> _mapModelToWidget(List<CodeModel> models) =>
      models.map((model) => CodeWidget.fromModel(model)).toList();

  Future _scan(CodesBloc codeProvider) async {
    try {

      final codeModel = CodeModel.fromBarcode(
          barcode: await BarcodeScanner.scan()
      );
      setState(() {
        codeProvider.dispatch(AddCode(codeModel));
      });
    } on DatabaseException catch (e) {
      showMessage(context, 'Hubo un problema al acceder a la base de datos ($e).');
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        showMessage(context, 'La aplicación no tiene permisos para usar la cámara');
      } else {
        showMessage(context, 'Error desconocido: $e');
      }
    } on FormatException {
      showMessage(context, 'No se escaneó ningún código');
    } catch (e) {
      showMessage(context, 'Unknown error: $e');
    }
  }

  Future _onConfirmDismiss(CodeModel codeModel) async {
    return await _showConfirmDialog(codeModel);
  }

  Future _onDismiss(CodesBloc codesProvider, CodeModel codeModel) async {
    codesProvider.dispatch(DeleteCode(codeModel));
    showMessage(context, "Codigo eliminado", type: MessageType.SUCCESS);
  }
}