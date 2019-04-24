import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lds_otp/bloc/bloc.dart';
import 'package:lds_otp/utils/theme.dart';
import 'package:lds_otp/utils/validation.dart';
import 'package:lds_otp/utils/messages.dart';

class InitialPreferencesScreen extends StatefulWidget {
  final InitialPreferencesBloc initialPreferencesBloc;

  InitialPreferencesScreen({ this.initialPreferencesBloc });

  @override
  State<StatefulWidget> createState() => _InitialPreferencesState(initialPreferencesBloc);
}

class _InitialPreferencesState extends State<InitialPreferencesScreen> {
  final InitialPreferencesBloc initialPreferencesBloc;
  final _formKey = GlobalKey<FormState>();

  String _newPin = "";
  String _confirmPin = "";

  _InitialPreferencesState(this.initialPreferencesBloc);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Configuración de preferencias"),
        ),
        body: BlocBuilder(
            bloc: initialPreferencesBloc,
            builder: _screenBuilder
        )
    );
  }

  Widget _screenBuilder(BuildContext context, InitialPreferencesState state) {
    Widget childWidget;
    if(state is ChangePinFinished) {
      childWidget = _buildChangePinFinished(context);
    } else {
      childWidget = _buildChangePinForm(context, state);
    }
    return SafeArea(child: childWidget ?? Container());
  }

  Widget _buildChangePinForm(BuildContext context, InitialPreferencesState state) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        children: <Widget>[
          SizedBox(height: 60.0),
          TextFormField(
              keyboardType: TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false
              ),
              decoration: InputDecoration(
                  labelText: "Nuevo PIN",
                  filled: true
              ),
              obscureText: true,
              validator: validatePINField,
              onSaved: (value) => _newPin = value
          ),
          SizedBox(height: 60.0),
          TextFormField(
            keyboardType: TextInputType.numberWithOptions(
                signed: false,
                decimal: false
            ),
            decoration: InputDecoration(
                labelText: "Confirmar PIN",
                filled: true
            ),
            obscureText: true,
            validator: validatePINField,
            onSaved: (value) => _confirmPin = value,
          ),
          SizedBox(height: 40.0),
          SwitchListTile(
            value: false,
            title: Text("¿Usar huella dactilar?"),
            activeColor: AppColors.accentColor,
          ),
          SizedBox(height: 80.0),
          ButtonBar(
            children: <Widget>[
              RaisedButton.icon(
                color: AppColors.accentColor,
                textColor: AppColors.textColor,
                icon: Icon(Icons.save),
                label: Text("Guardar"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                ),
                onPressed: () {

                },
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChangePinFinished(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.check_circle,
            size: 100.0,
            color: Colors.teal,
          ),
          SizedBox(height: 30.0),
          Text(
            "El PIN fue cambiado correctamente.",
            style: TextStyle(fontSize: 20.0),
          )
        ],
      ),
    );
  }
}