import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFormFieldWidget extends StatelessWidget {
  final List<TextInputFormatter>? formatters;
  final TextInputType? keyboardType;
  final String? labelText;
  final int? maxLength;
  final TextEditingController? controller;
  final String? initialValue;
  final FormFieldValidator<String>? validator;
  final GestureTapCallback? onTap;

  const TextFormFieldWidget(
      {Key? key,
      this.formatters,
      @required this.keyboardType,
      this.maxLength,
      @required this.labelText,
      this.controller,
      this.initialValue,
      this.validator,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (TextFormField(
        inputFormatters: formatters,
        keyboardType: keyboardType,
        maxLength: maxLength,
        controller: controller,
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: labelText,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(color: Colors.white24, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14.0)),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14.0)),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14.0)),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
        ),
        // The validator receives the text that the user has entered.
        validator: validator,
        onTap: onTap));
  }
}
