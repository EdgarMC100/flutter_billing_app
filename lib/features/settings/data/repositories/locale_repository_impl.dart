import '../../../../core/data/hive_database.dart';
import '../../domain/repositories/locale_repository.dart';

class LocaleRepositoryImpl implements LocaleRepository {
  static const String _localeKey = 'locale';
  static const String _defaultLanguageCode = 'en';

  @override
  String getSavedLanguageCode() {
    return HiveDatabase.settingsBox
        .get(_localeKey, defaultValue: _defaultLanguageCode) as String;
  }

  @override
  Future<void> saveLanguageCode(String code) async {
    await HiveDatabase.settingsBox.put(_localeKey, code);
  }
}
