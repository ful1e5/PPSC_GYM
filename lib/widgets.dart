import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ppscgym/styles.dart';

class TextFormFieldWidget extends StatelessWidget {
  final bool? enabled;
  final bool? autoFocus;
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
      this.enabled,
      this.autoFocus = false,
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
        enabled: enabled,
        autofocus: autoFocus!,
        inputFormatters: formatters,
        keyboardType: keyboardType,
        maxLength: maxLength,
        controller: controller,
        initialValue: initialValue,
        enableInteractiveSelection: enableInteractiveSelection,
        style: TextStyle(
          color: (enabled != null && enabled == false) ? Colors.white54 : null,
        ),
        decoration: InputDecoration(
          prefixIcon:
              (enabled != null && enabled == false) ? Icon(Icons.lock) : null,
          labelText: labelText,
          hintText: hintText,
          contentPadding: EdgeInsets.all(10.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(color: Colors.white24, width: 1),
          ),
          disabledBorder: OutlineInputBorder(
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

IconData getGenderIconData(String gender) {
  if (gender == "Male") {
    return Icons.male;
  } else {
    return Icons.female;
  }
}

Widget loaderWidget() {
  return Center(child: CircularProgressIndicator(color: Colors.white));
}

Widget centerMessageWidget(String message) {
  return Center(child: Text(message, style: slightBoldText));
}

class ConfirmDialog extends StatefulWidget {
  final Widget info;
  final String confirmText;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    Key? key,
    required this.info,
    required this.confirmText,
    required this.onConfirm,
  }) : super(key: key);

  @override
  _ConfirmDialogState createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  late bool iscConfirm;

  @override
  void initState() {
    super.initState();
    iscConfirm = false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
        side: BorderSide(
          width: 1.5,
          color: Colors.white10,
        ),
      ),
      backgroundColor: Colors.black87,
      child: Container(
        height: 280,
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Align(alignment: Alignment.centerLeft, child: widget.info),
              SizedBox(height: 20),
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
                        setState(() {
                          iscConfirm = false;
                        });
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: iscConfirm ? widget.onConfirm : null,
                    style: ButtonStyle(
                      backgroundColor: iscConfirm
                          ? MaterialStateProperty.all<Color>(Colors.red)
                          : null,
                      foregroundColor: iscConfirm
                          ? MaterialStateProperty.all<Color>(Colors.white)
                          : MaterialStateProperty.all<Color>(Colors.white24),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                    child: Text(widget.confirmText),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CountDown extends StatefulWidget {
  final DateTime time;
  final Function onTimeout;
  CountDown({Key? key, required this.time, required this.onTimeout})
      : super(key: key);

  @override
  _CountDownState createState() => _CountDownState();
}

class _CountDownState extends State<CountDown> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), _onTimeChange);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onTimeChange(Timer timer) {
    setState(() {
      if (widget.time.compareTo(DateTime.now()) == 0) {
        widget.onTimeout();
      } else {
        _currentTime = DateTime.now();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.time.difference(_currentTime);

    final days = remaining.inDays;
    final hours = remaining.inHours - remaining.inDays * 24;
    final minutes = remaining.inMinutes - remaining.inHours * 60;
    final seconds = remaining.inSeconds - remaining.inMinutes * 60;

    return Card(
      color: Colors.blue,
      semanticContainer: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Container(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Cooldown",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700)),
            Text(
              "$days Days",
              style: TextStyle(fontSize: 14.5),
            ),
            Text(
              "$hours:$minutes:$seconds",
              style: TextStyle(fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }
}
