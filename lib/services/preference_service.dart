import 'package:lds_otp/repository/secrets_repository.dart';
import 'package:lds_otp/repository/preferences_repository.dart';
class PreferencesService {

  Future<bool> isAppFirstUse() async {
    final secretsRepository = SecretsRepository();

    final preferencesRepository = PreferencesRepository();

    final notPin = (await secretsRepository.getSecret("pin")) == null;

    final notUsesFingerprint = (
        await preferencesRepository.getPreference("uses_fingerprint")) == null;

    return notPin || notUsesFingerprint;

  }
}