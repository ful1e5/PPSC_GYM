import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFormFieldWidget extends StatelessWidget {
  final List<TextInputFormatter>? formatters;
  final TextInputType? keyboardType;
  final String? labelText;
  final String? hintText;
  final int? maxLength;
  final TextEditingController? controller;
  final String? initialValue;
  final bool enableInteractiveSelection;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final GestureTapCallback? onTap;
  final ValueChanged<String>? onChanged;

  const TextFormFieldWidget(
      {Key? key,
      this.formatters,
      @required this.keyboardType,
      this.maxLength,
      this.labelText,
      this.hintText,
      this.controller,
      this.initialValue,
      this.enableInteractiveSelection = true,
      this.validator,
      this.onSaved,
      this.onTap,
      this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (TextFormField(
        inputFormatters: formatters,
        keyboardType: keyboardType,
        maxLength: maxLength,
        controller: controller,
        initialValue: initialValue,
        enableInteractiveSelection: enableInteractiveSelection,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
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
        onSaved: onSaved,
        onTap: onTap,
        onChanged: onChanged));
  }
}

class ConfirmDialog extends StatefulWidget {
  final Widget info;
  final String confirmText;
  const ConfirmDialog({
    Key? key,
    required this.info,
    required this.confirmText,
  }) : super(key: key);

  @override
  _ConfirmDialogState createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  late bool iscConfirm = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
          side: BorderSide(
            width: 2.5,
            color: Colors.white54,
          ),
        ),
        backgroundColor: Colors.black,
        child: Container(
            height: 200,
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft, child: widget.info),
                  ),
                  Expanded(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextFormFieldWidget(
                              hintText: "confirm",
                              keyboardType: TextInputType.text,
                              onChanged: (text) {
                                if (text == "confirm") {
                                  setState(() {
                                    iscConfirm = true;
                                  });
                                } else {
                                  iscConfirm = false;
                                }
                              }))),
                  SizedBox(height: 20),
                  Expanded(
                      child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                        child: Text(widget.confirmText), onPressed: () {}),
                  )),
                ],
              ),
            )));
  }
}
