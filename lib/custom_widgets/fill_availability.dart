import 'package:datum_prikker/custom_widgets/planner.dart';
import 'package:flutter/material.dart';

import 'availability_button.dart';

class FillAvailability extends StatefulWidget {
  FillAvailability({Key? key, required this.date, this.pressed}) : super(key: key);
  final String date;
  int? pressed = 0;

  @override
  State<FillAvailability> createState() => _FillAvailabilityState();
}

class _FillAvailabilityState extends State<FillAvailability> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [
        Text(widget.date),
        SizedBox(width: 15),
        AvailabilityButton(
            borderRadius: 18.0,
            height: 80,
            width: 80,
            color: Colors.green,
            backGroundColor: widget.pressed != 1? MaterialStateProperty.all(Colors.white60) : MaterialStateProperty.all(Colors.green),
            onTap: widget.pressed == 1? () {widget.pressed = 0; setState((){});} : () {widget.pressed = 1; setState(() {});}
        ),
        SizedBox(width: 15),
        AvailabilityButton(
            borderRadius: 18.0,
            height: 80,
            width: 80,
            color: Colors.yellow,
            backGroundColor: widget.pressed != 2? MaterialStateProperty.all(Colors.white60) : MaterialStateProperty.all(Colors.yellow),
            onTap:widget.pressed == 2? () {widget.pressed = 0; setState((){});} : () {widget.pressed = 2; setState(() {});
            }
        ),
        SizedBox(width: 15),
        AvailabilityButton(
            borderRadius: 18.0,
            height: 80,
            width: 80,
            color: Colors.red,
            backGroundColor: widget.pressed != 3? MaterialStateProperty.all(Colors.white60) : MaterialStateProperty.all(Colors.red),
            onTap: widget.pressed == 3? () {widget.pressed = 0; setState((){});} : () {widget.pressed = 3; setState(() {});}
        )
      ]),
    );
  }
}
