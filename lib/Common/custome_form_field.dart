import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:hairfixingzone/CommonUtils.dart';

class CustomeFormField extends StatelessWidget {
  final String label;
  final TextInputType keyboardType;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final bool obscureText;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final String? errorText;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool readOnly; // Add the readOnly parameter
  final TextStyle? errorStyle;
  final TextStyle? textStyle;
  final FocusNode? focusNode;
  final int? maxLines;
  final bool isMandatory;
  final bool enabled;

  const CustomeFormField({
    Key? key,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.isMandatory = true,
    this.maxLengthEnforcement,
    this.obscureText = false,
    this.suffixIcon,
    this.onTap,
    this.enabled = true,
    this.errorText,
    this.maxLines = 1,
    this.onChanged,
    this.inputFormatters,
    this.validator,
    this.controller,
    this.readOnly = false,
    this.errorStyle,
    this.textStyle, // Initialize the readOnly parameter with a default value
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // label text
        Row(
          children: [
            Text(
              '$label ',
              style: CommonUtils.txSty_12b_fb,
            ),
            if (isMandatory)
              const Text(
                '*',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        const SizedBox(
          height: 5.0,
        ),
        // textfield
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            enabled: enabled,
            suffixIcon: suffixIcon,
            contentPadding:
                const EdgeInsets.only(top: 15, bottom: 10, left: 15, right: 15),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF0f75bc),
              ),
              borderRadius: BorderRadius.circular(6.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: CommonUtils.primaryTextColor,
              ),
              borderRadius: BorderRadius.circular(6.0),
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 175, 15, 4),
              ),
              borderRadius: BorderRadius.circular(6.0),
            ),
            hintText: 'Enter $label',
            hintStyle: CommonStyles.texthintstyle,
            errorText: errorText,
            errorStyle: CommonStyles.texthintstyle.copyWith(
              color: Color.fromARGB(255, 175, 15, 4),
              fontSize: 11,
            ),
            counterText: "",
          ),
          focusNode: focusNode,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLength: maxLength,
          maxLines: maxLines,
          maxLengthEnforcement: maxLengthEnforcement,
          readOnly:
              readOnly, // Pass the readOnly parameter to the TextFormField
          onTap: onTap,
          style: CommonStyles.txSty_14b_fb,
          //  textStyle :CommonStyles.txSty_14b_fb
          // Add onTap to handle any additional logic if needed
        ),
      ],
    );
  }
}


//const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
// .copyWith(top: 5),
