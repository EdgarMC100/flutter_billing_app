import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/shop_bloc.dart';
import '../widgets/shop_form.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ShopDetailsPage extends StatefulWidget {
  const ShopDetailsPage({super.key});

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  final _formKey = GlobalKey<ShopFormState>();

  @override
  void initState() {
    super.initState();
    context.read<ShopBloc>().add(LoadShopEvent());
  }

  void _saveShop() {
    _formKey.currentState?.validateAndSubmit();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(l10n.shopDetailsAppBarTitle),
        ),
        body: BlocConsumer<ShopBloc, ShopState>(
          listener: (context, state) {
            if (state is ShopLoaded) {
              _formKey.currentState?.updateFromShop(state.shop);
            } else if (state is ShopOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(l10n.shopDetailsSavedSnackbar),
                  backgroundColor: Colors.green));
              context.pop();
            } else if (state is ShopError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          buildWhen: (previous, current) =>
              current is ShopLoading || current is ShopLoaded,
          builder: (context, state) {
            if (state is ShopLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final shop = state is ShopLoaded ? state.shop : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.shopDetailsGeneralInfoSectionTitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AppTheme.primaryColor.withValues(alpha: 0.8),
                      )),
                  const SizedBox(height: 5),
                  Text(
                    l10n.shopDetailsSectionSubtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  if (shop != null)
                    ShopForm(
                      key: _formKey,
                      initial: shop,
                      onSubmit: (updated) =>
                          context.read<ShopBloc>().add(UpdateShopEvent(updated)),
                    ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: PrimaryButton(
          onPressed: _saveShop,
          icon: Icons.save,
          label: l10n.shopDetailsSaveButton,
        ));
  }
}
