import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lds_otp/bloc/change_pin_bloc.dart';
import 'package:lds_otp/utils/theme.dart';
import 'package:lds_otp/utils/validation.dart';
import 'package:lds_otp/utils/messages.dart';

class ChangePinScreen extends StatefulWidget {
  final ChangePinBloc changePinBloc;

  ChangePinScreen({this.changePinBloc});

  @override
  State<StatefulWidget> createState() => _ChangePinState(changePinBloc);
}

class _ChangePinState extends State<ChangePinScreen> {
  final ChangePinBloc changePinBloc;
  final _formKey = GlobalKey<FormState>();
  String _currentPin = "";
  String _newPin = "";

  _ChangePinState(this.changePinBloc);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cambiar PIN"),
      ),
      body: BlocBuilder(
          bloc: changePinBloc,
          builder: _screenBuilder
      )
    );
  }

  Widget _screenBuilder(BuildContext context, ChangePinState state) {
    Widget childWidget;
    if(state is ChangePinFinished) {
      childWidget = _buildChangePinFinished(context);
    } else {
      childWidget = _buildChangePinForm(context, state);
    }
    return SafeArea(child: childWidget ?? Container());
  }

  Widget _buildChangePinForm(BuildContext context, ChangePinState state) {
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
                labelText: "PIN Actual",
                filled: true
            ),
            obscureText: true,
            validator: validatePINField,
            onSaved: (value) => _currentPin = value
          ),
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
            onSaved: (value) => _newPin = value,
          ),
          SizedBox(height: 60.0),
          ButtonBar(
            children: <Widget>[
              RaisedButton.icon(
                color: AppColors.accentColor,
                textColor: AppColors.textColor,
                icon: Icon(Icons.lock),
                label: Text("CAMBIAR"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                ),
                onPressed: () {
                  _formKey.currentState.save();
                  if(_formKey.currentState.validate()) {
                    changePinBloc.dispatch(ChangePin(_currentPin, _newPin));
                    if (state is PinEqual) {
                      showMessage(context, "Los PINs son iguales");
                    } else if (state is PinWrong) {
                      showMessage(context, "El PIN ingresado no es correcto");
                    }
                  }
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