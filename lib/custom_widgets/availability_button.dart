import 'package:flutter/material.dart';

class AvailabilityButton extends StatefulWidget {
  AvailabilityButton({Key? key,required this.borderRadius, required this.onTap, required this.backGroundColor, required this.width, required this.height, required this.color}) : super(key: key);

  double? width;
  double? height;
  Color? color;
  MaterialStateProperty<Color>? backGroundColor;
  Function()? onTap;
  double? borderRadius;

  @override
  State<AvailabilityButton> createState() => _AvailabilityButtonState();
}

class _AvailabilityButtonState extends State<AvailabilityButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: widget.backGroundColor,
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius!),
              side: BorderSide(width: 5, color: widget.color!)
            )
          ),
        ),
        onPressed: widget.onTap,
        child: null,
      ),
    );
  }
}
