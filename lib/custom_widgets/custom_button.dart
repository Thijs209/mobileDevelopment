import 'package:flutter/cupertino.dart';

import 'custom_raised_button.dart';

class CustomButton extends CustomRaisedButton{
  CustomButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) : super(
      child: Text(text, style: TextStyle(color: textColor, fontSize: 15),
      ),
      color: color,
      onPressed: onPressed,
  );
}