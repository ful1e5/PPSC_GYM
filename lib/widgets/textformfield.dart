import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFormFieldWidget extends StatelessWidget {
  final String? labelText;
  final List<TextInputFormatter>? formatters;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  const TextFormFieldWidget(
      {Key? key,
      @required this.labelText,
      this.formatters,
      @required this.keyboardType,
      this.validator})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (TextFormField(
        inputFormatters: formatters,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
        // The validator receives the text that the user has entered.
        validator: validator));
  }
}
