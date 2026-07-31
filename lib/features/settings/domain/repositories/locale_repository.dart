abstract class LocaleRepository {
  String getSavedLanguageCode();
  Future<void> saveLanguageCode(String code);
}
