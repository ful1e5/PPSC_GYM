import 'package:flutter/services.dart';

class WhiteSpaceOn extends TextInputFormatter {

  int whiteSpace;
  WhiteSpaceOn(this.whiteSpace);
  @override
  TextEditingValue formatEditUpdate(
    
    TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % whiteSpace == 0 && nonZeroIndex != text.length) {
        buffer.write(' '); // Add spaces.
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}