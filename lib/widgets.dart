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
    return TextFormField(
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
      onChanged: onChanged,
    );
  }
}

IconData getGenderIcon(String gender) {
  if (gender == 'Male') {
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

Widget gapWidget(double height) {
  return Divider(color: Colors.transparent, height: height);
}

class ConfirmDialog extends StatefulWidget {
  final Widget child;
  final String confirmText;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    Key? key,
    required this.child,
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
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        side: BorderSide(width: 1.5, color: Colors.white10),
      ),
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              gapWidget(10.0),

              //
              // Info
              //
              Align(
                alignment: Alignment.centerLeft,
                child: widget.child,
              ),
              gapWidget(30.0),

              //
              // Confirm Textfield
              //

              TextFormFieldWidget(
                hintText: 'confirm',
                keyboardType: TextInputType.text,
                onChanged: (text) {
                  if (text == 'confirm') {
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
              gapWidget(30.0),

              //
              // Confirm Button
              //

              OutlinedButton(
                child: Text(
                  widget.confirmText,
                ),
                style: materialButtonStyle(
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                  backgroundColor: iscConfirm ? Colors.red : Colors.transparent,
                  foregroundColor: iscConfirm ? Colors.white : Colors.white24,
                ),
                onPressed: iscConfirm ? widget.onConfirm : null,
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
  final String text;
  CountDown(
      {Key? key,
      required this.time,
      required this.onTimeout,
      required this.text})
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
      color: Colors.blueGrey.withOpacity(0.35),
      margin: EdgeInsets.symmetric(horizontal: 70.0),
      semanticContainer: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.text,
              style: TextStyle(fontSize: 15.8, fontWeight: FontWeight.w600),
            ),
            gapWidget(2.0),
            Text(
              '$days Days ${hours}h :${minutes}m :${seconds}s',
              style: TextStyle(fontSize: 13.0, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

// TODO: Animated icon popups
// TODO: Change times for each categories

popUp(BuildContext context,
    {Color? color, Color? fontColor, IconData? icon, String? text}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color ?? Colors.white,
      content: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.info,
              size: 30.0,
              color: fontColor ?? Colors.black,
            ),
            SizedBox(width: 10.0),
            Text(
              text ?? "",
              style: TextStyle(
                color: fontColor ?? Colors.black,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

errorPopup(BuildContext context, String msg) {
  popUp(
    context,
    color: Colors.red,
    icon: Icons.clear_rounded,
    text: msg,
  );
}

infoPopup(BuildContext context, String msg) {
  popUp(
    context,
    color: Colors.amber,
    icon: Icons.info_outline,
    fontColor: Colors.black,
    text: msg,
  );
}

successPopup(BuildContext context, String msg) {
  popUp(
    context,
    color: Colors.green,
    icon: Icons.check_rounded,
    text: msg,
  );
}

Widget avatarWidget({Widget? child, Color? color}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10.0),
    child: Container(
      height: 80.0,
      width: 57.0,
      color: color,
      child: child,
    ),
  );
}

TabBar tabBarWidget({TabController? controller, List<Widget>? tabs}) {
  return TabBar(
    controller: controller,
    isScrollable: true,
    physics: BouncingScrollPhysics(),
    overlayColor: MaterialStateProperty.all(Colors.transparent),
    automaticIndicatorColorAdjustment: true,
    unselectedLabelColor: Colors.blueGrey,
    indicator: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      color: Colors.blue,
    ),
    tabs: tabs ?? [Tab(text: 'Home')],
  );
}
