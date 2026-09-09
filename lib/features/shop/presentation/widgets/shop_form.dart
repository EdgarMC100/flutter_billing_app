import 'package:flutter/material.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/input_label.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/shop.dart';

/// The shop-profile form fields (name, address, phone, UPI id, footer), shared
/// by [ShopDetailsPage] and the first-run onboarding wizard.
///
/// The parent owns the submit button and drives submission through a
/// `GlobalKey<ShopFormState>`:
///
/// ```dart
/// final _formKey = GlobalKey<ShopFormState>();
/// // ...
/// ShopForm(key: _formKey, initial: shop, onSubmit: ...),
/// // ...
/// onPressed: () => _formKey.currentState?.validateAndSubmit(),
/// ```
class ShopForm extends StatefulWidget {
  final Shop initial;
  final void Function(Shop shop) onSubmit;

  const ShopForm({
    super.key,
    required this.initial,
    required this.onSubmit,
  });

  @override
  State<ShopForm> createState() => ShopFormState();
}

class ShopFormState extends State<ShopForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _address1Controller;
  late final TextEditingController _address2Controller;
  late final TextEditingController _phoneController;
  late final TextEditingController _upiController;
  late final TextEditingController _footerController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial.name);
    _address1Controller =
        TextEditingController(text: widget.initial.addressLine1);
    _address2Controller =
        TextEditingController(text: widget.initial.addressLine2);
    _phoneController = TextEditingController(text: widget.initial.phoneNumber);
    _upiController = TextEditingController(text: widget.initial.upiId);
    _footerController = TextEditingController(text: widget.initial.footerText);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _phoneController.dispose();
    _upiController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  /// Seeds any still-empty controller from [shop]. Used when the shop loads
  /// asynchronously after the form is first built.
  void updateFromShop(Shop shop) {
    if (_nameController.text.isEmpty && shop.name.isNotEmpty) {
      _nameController.text = shop.name;
      _address1Controller.text = shop.addressLine1;
      _address2Controller.text = shop.addressLine2;
      _phoneController.text = shop.phoneNumber;
      _upiController.text = shop.upiId;
      _footerController.text = shop.footerText;
    }
  }

  /// Validates the form and, if valid, calls [ShopForm.onSubmit] with the
  /// entered values. Returns whether submission happened.
  bool validateAndSubmit() {
    if (!_formKey.currentState!.validate()) return false;
    widget.onSubmit(Shop(
      name: _nameController.text,
      addressLine1: _address1Controller.text,
      addressLine2: _address2Controller.text,
      phoneNumber: _phoneController.text,
      upiId: _upiController.text,
      footerText: _footerController.text,
    ));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputLabel(text: l10n.shopDetailsNameLabel),
          _buildTextField(
            controller: _nameController,
            hint: 'e.g. QuickMart Superstore',
            validator: AppValidators.required(l10n.commonRequiredError),
          ),
          const SizedBox(height: 15),
          InputLabel(text: l10n.shopDetailsAddress1Label),
          _buildTextField(
            controller: _address1Controller,
            hint: 'Samrajpet, Mecheri',
            validator: AppValidators.required(l10n.commonRequiredError),
          ),
          const SizedBox(height: 15),
          InputLabel(text: l10n.shopDetailsAddress2Label),
          _buildTextField(
            controller: _address2Controller,
            hint: 'Salem - 636453',
          ),
          const SizedBox(height: 15),
          InputLabel(text: l10n.shopDetailsPhoneLabel),
          _buildTextField(
            controller: _phoneController,
            hint: '+91 7010674588',
            keyboardType: TextInputType.phone,
            validator: AppValidators.required(l10n.commonRequiredError),
          ),
          const SizedBox(height: 15),
          InputLabel(text: l10n.shopDetailsUpiIdLabel),
          _buildTextField(
            controller: _upiController,
            hint: 'dineshsowndar@oksbi',
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InputLabel(text: l10n.shopDetailsFooterTextLabel),
              Text(l10n.shopDetailsFooterMaxChars,
                  style: TextStyle(fontSize: 11, color: Colors.grey[400])),
            ],
          ),
          _buildTextField(
            controller: _footerController,
            hint: 'Thank you, Visit again!!!',
            maxLines: 2,
            maxLength: 60,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: TextCapitalization.words,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
      ),
    );
  }
}
