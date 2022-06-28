import 'package:flutter/material.dart';

class CustomRaisedButton extends StatelessWidget {
  CustomRaisedButton({required this.child, required this.color, this.borderRadius: 2, required this.onPressed, this.height:50, this.width:double.infinity});

  final Widget child;
  final Color color;
  final double borderRadius;
  final VoidCallback onPressed;
  final double height;
  final double width;
  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: height,
      width: width,
      child: RaisedButton(
        child: child,
        color: color,
        disabledColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
