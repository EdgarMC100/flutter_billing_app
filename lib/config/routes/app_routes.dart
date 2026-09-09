import 'package:go_router/go_router.dart';
import '../../core/service_locator.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/billing/presentation/pages/home_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../../features/product/presentation/pages/add_product_page.dart';
import '../../features/product/presentation/pages/edit_product_page.dart';
import '../../features/shop/presentation/pages/shop_details_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/billing/presentation/pages/scanner_page.dart';
import '../../features/billing/presentation/pages/checkout_page.dart';
import '../../features/product/domain/entities/product.dart';
import '../../features/sales/presentation/pages/sales_history_page.dart';
import '../../features/sales/presentation/pages/sale_detail_page.dart';
import '../../features/sales/domain/entities/sale.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final onboardingDone = sl<OnboardingRepository>().isComplete();
    final atOnboarding = state.matchedLocation == '/onboarding';
    if (!onboardingDone && !atOnboarding) return '/onboarding';
    if (onboardingDone && atOnboarding) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'scanner',
          builder: (context, state) => const ScannerPage(),
        ),
        GoRoute(
          path: 'checkout',
          builder: (context, state) => const CheckoutPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductListPage(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) =>
              AddProductPage(initialBarcode: state.extra as String?),
        ),
        GoRoute(
          path: 'edit/:id',
          builder: (context, state) {
            final product = state.extra as Product?;
            if (product == null) {
              // If we land here without extra (e.g. deep link), go back to products for now.
              return const ProductListPage();
            }
            return EditProductPage(product: product);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/shop',
      builder: (context, state) => const ShopDetailsPage(),
    ),
    GoRoute(
      path: '/sales',
      builder: (context, state) => const SalesHistoryPage(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final sale = state.extra as Sale?;
            if (sale == null) {
              // If we land here without extra (e.g. deep link), go back to the list.
              return const SalesHistoryPage();
            }
            return SaleDetailPage(sale: sale);
          },
        ),
      ],
    ),
  ],
);
