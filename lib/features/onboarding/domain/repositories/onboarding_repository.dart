/// First-run onboarding state.
///
/// Kept intentionally simple (plain return types, no `UseCase` / `Either`
/// wrappers) to match the `settings` feature's key-value repositories
/// (`LocaleRepository`, `PrinterRepository`) rather than the product/shop
/// repositories.
abstract class OnboardingRepository {
  /// Whether the user has finished first-run setup.
  bool isComplete();

  /// Marks first-run setup as finished.
  Future<void> markComplete();
}
