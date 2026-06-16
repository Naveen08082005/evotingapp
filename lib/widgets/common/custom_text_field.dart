import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool isPassword;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool readOnly;
  final void Function(String)? onChanged;
  final int maxLines;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.prefixIcon,
    this.suffix,
    this.readOnly = false,
    this.onChanged,
    this.maxLines = 1,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword && _obscureText,
      readOnly: widget.readOnly,
      onChanged: widget.onChanged,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 15),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : widget.suffix,
      ),
    );
  }
}
