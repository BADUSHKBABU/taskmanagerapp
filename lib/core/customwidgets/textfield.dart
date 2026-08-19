import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class Textfield extends StatelessWidget {
  final TextEditingController controller;
  final bool ispassword;
  final String validationmsg;
  final Icon prefiixIcon;
  final Icon suffixicon;


  Textfield({
    super.key,
    required this.controller,
    this.ispassword = false,
    this.validationmsg = "",
    this.prefiixIcon = const Icon(Icons.add),
    this.suffixicon = const Icon(Icons.add),
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      // enabled: !isLoading,
      textCapitalization: TextCapitalization.words,
      obscureText: ispassword,
      decoration: InputDecoration(
        labelText: 'Full Name',
        prefixIcon: prefiixIcon,
suffixIcon: IconButton(onPressed: (){
  ispassword ? Icons.visibility_off_outlined : Icons.visibility_outlined;
}, icon: suffixicon),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return validationmsg;
        }
        return null;
      },
    );
  }
}
