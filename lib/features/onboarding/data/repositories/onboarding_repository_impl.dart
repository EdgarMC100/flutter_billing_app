import '../../../../core/data/hive_database.dart';
import '../../domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  static const String _completedKey = 'onboarding_completed';

  /// Must stay in sync with [ShopRepositoryImpl.shopKey] — used only for the
  /// migration fallback below.
  static const String _shopKey = 'shop_details';

  @override
  bool isComplete() {
    final flag = HiveDatabase.settingsBox
        .get(_completedKey, defaultValue: false) as bool;
    if (flag) return true;

    // Migration safety: installs that predate onboarding already have a shop
    // saved but no flag — don't force them back through the wizard.
    return HiveDatabase.shopBox.get(_shopKey) != null;
  }

  @override
  Future<void> markComplete() async {
    await HiveDatabase.settingsBox.put(_completedKey, true);
  }
}
