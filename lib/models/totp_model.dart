import 'package:dotp/dotp.dart';

const int _tokenPeriod = 30;

class TOTPData {
  String currentCode;
  String issuer;
  String user;
  String domain;

  TOTP _oneTimePassword;

  TOTPData({this.issuer, this.user, this.domain});

  TOTPData.fromBarcode({String barcode}) {
    var uri = Uri.parse(barcode);
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

  int get remainTime => _tokenPeriod - DateTime.now().second % _tokenPeriod;

  double get remainTimeAsPercent => remainTime / 30;

  String toString() => "$user($domain)";
}

class CodeModel {
  String barcode;

  CodeModel({ this.barcode });

  factory CodeModel.fromMap(Map<String, dynamic> json) => new CodeModel(
    barcode: json["barcode"],
  );

  Map<String, dynamic> toMap() => {
    "barcode": barcode
  };
}