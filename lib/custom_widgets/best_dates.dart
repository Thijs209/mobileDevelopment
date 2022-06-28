import 'package:flutter/material.dart';

import 'availability_button.dart';

class BestDates extends StatelessWidget {
  BestDates(this.name, this.availabilities);

  Map<String,int> availabilities;
  String name;

  List<MaterialStateProperty<Color>> colors = [MaterialStateProperty.all(Colors.white), MaterialStateProperty.all(Colors.green), MaterialStateProperty.all(Colors.yellow), MaterialStateProperty.all(Colors.red)];
  List<Color> colorColors = [Colors.white, Colors.green, Colors.yellow, Colors.red];

  @override
  Widget build(BuildContext context) {
    return getAvailabilities();
  }

  Widget getAvailabilities(){
    List<Widget> widgets = [];
    widgets.add(Text(name, style: const TextStyle(fontSize: 25)));
    availabilities.forEach((key, value) {
      widgets.add(const SizedBox(height:10));
      widgets.add(AvailabilityButton(borderRadius:5.0, width: 30, height: 30, backGroundColor: colors[value], color: colorColors[value], onTap: (){}));
    });
    Widget column = Container(color: Colors.white70,  child: Column(children: widgets));
    return column;
  }
}
