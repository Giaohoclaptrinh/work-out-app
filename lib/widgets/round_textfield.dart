import 'package:flutter/material.dart';
import 'package:workout_app/common/color_extension.dart';

class RoundTextField extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String hintText;
  final String? icon;
  final Widget? rightIcon;
  final bool obscureText;
  final EdgeInsets? margin;

  final void Function(String)? onChanged;

  const RoundTextField({
    super.key,
    required this.hintText,
    this.icon,
    this.controller,
    this.margin,
    this.keyboardType,
    this.obscureText = false,
    this.rightIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 15,
          ),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hintText,
          suffixIcon: rightIcon,
          prefixIcon: icon != null
              ? Container(
                  alignment: Alignment.center,
                  width: 20,
                  height: 20,
                  child: Image.asset(
                    icon!,
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                    color: TColor.gray,
                  ),
                )
              : null,
          hintStyle: TextStyle(color: TColor.gray, fontSize: 12),
        ),
      ),
    );
  }
}
