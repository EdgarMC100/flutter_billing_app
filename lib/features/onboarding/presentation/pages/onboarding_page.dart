import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../shop/presentation/widgets/shop_form.dart';
import '../../domain/repositories/onboarding_repository.dart';

/// First-run setup wizard. Gated by the router `redirect` in `app_routes.dart`:
/// shown until [OnboardingRepository.markComplete] has been called.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  final _shopFormKey = GlobalKey<ShopFormState>();
  int _step = 0;

  static const _stepCount = 3;

  @override
  void initState() {
    super.initState();
    // Make sure the profile step has a shop to seed from (usually an empty
    // Shop() on a fresh install).
    context.read<ShopBloc>().add(LoadShopEvent());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    await sl<OnboardingRepository>().markComplete();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _ProgressDots(count: _stepCount, current: _step),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _step = i),
                children: [
                  _WelcomeStep(onStart: () => _goToStep(1)),
                  _ProfileStep(
                    shopFormKey: _shopFormKey,
                    onContinue: () =>
                        _shopFormKey.currentState?.validateAndSubmit(),
                    onSaved: () => _goToStep(2),
                  ),
                  _DoneStep(onFinish: _finish),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  final int count;
  final int current;

  const _ProgressDots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final active = i == current;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active
                  ? AppTheme.primaryColor
                  : AppTheme.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  final VoidCallback onStart;

  const _WelcomeStep({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storefront,
                      size: 44, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.onboardingWelcomeTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.onboardingWelcomeBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        PrimaryButton(
          onPressed: onStart,
          icon: Icons.arrow_forward,
          label: l10n.onboardingWelcomeCta,
        ),
      ],
    );
  }
}

class _ProfileStep extends StatelessWidget {
  final GlobalKey<ShopFormState> shopFormKey;
  final VoidCallback onContinue;
  final VoidCallback onSaved;

  const _ProfileStep({
    required this.shopFormKey,
    required this.onContinue,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<ShopBloc, ShopState>(
      listenWhen: (previous, current) =>
          current is ShopOperationSuccess || current is ShopError,
      listener: (context, state) {
        if (state is ShopOperationSuccess) {
          onSaved();
        } else if (state is ShopError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: Colors.red));
        }
      },
      buildWhen: (previous, current) =>
          current is ShopLoading || current is ShopLoaded,
      builder: (context, state) {
        if (state is! ShopLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.onboardingProfileTitle,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.onboardingProfileSubtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ShopForm(
                      key: shopFormKey,
                      initial: state.shop,
                      onSubmit: (updated) => context
                          .read<ShopBloc>()
                          .add(UpdateShopEvent(updated)),
                    ),
                  ],
                ),
              ),
            ),
            PrimaryButton(
              onPressed: onContinue,
              icon: Icons.arrow_forward,
              label: l10n.onboardingProfileCta,
            ),
          ],
        );
      },
    );
  }
}

class _DoneStep extends StatelessWidget {
  final Future<void> Function() onFinish;

  const _DoneStep({required this.onFinish});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 48, color: Colors.white),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.onboardingDoneTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.onboardingDoneBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        PrimaryButton(
          onPressed: onFinish,
          icon: Icons.home_outlined,
          label: l10n.onboardingDoneCta,
        ),
      ],
    );
  }
}
