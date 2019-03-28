import 'package:dotp/dotp.dart';
import 'package:lds_otp/utils/constants.dart';

class CodeModel {
  String currentCode;
  String issuer;
  String user;
  String domain;
  String secret;
  TOTP _oneTimePassword;

  // Computated
  int get remainTime => TOKEN_PERIOD - DateTime.now().second % TOKEN_PERIOD;

  double get remainTimeAsPercent => remainTime / TOKEN_PERIOD;

  String toString() => "$user($domain)";

  CodeModel({
    this.issuer,
    this.user,
    this.domain,
    this.secret
  }){
    _initTOTP();
  }

  CodeModel.fromBarcode({ String barcode }) {
    _initDataWithBarcode(barcode);
    _initTOTP();
  }

  _initDataWithBarcode(String barcode) {
    var uri = Uri.parse(barcode);
    var path = uri.path.split(":");

    this.domain = path[0] ?? "";
    this.user = path[1] ?? "";
    this.issuer = uri.queryParameters["issuer"];
    this.secret = uri.queryParameters["secret"];
  }

  _initTOTP() {
    _oneTimePassword = TOTP(secret);
    refreshCode();
  }

  refreshCode() {
    currentCode = _oneTimePassword?.now();
  }

  factory CodeModel.fromMap(Map<String, dynamic> json) => CodeModel(
    issuer: json["issuer"],
    domain:  json["domain"],
    user:  json["user"],
    secret: json["secret"]
  );

  Map<String, dynamic> toMap() => {
    "issuer": issuer,
    "domain": domain,
    "user": user,
    "secret": secret
  };
}