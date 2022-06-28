import 'package:datum_prikker/custom_widgets/availability_button.dart';
import 'package:datum_prikker/custom_widgets/person.dart';
import 'package:flutter/material.dart';

class PersonInfo extends StatelessWidget {
  PersonInfo(this.person, {Key? key}) : super(key: key);

  Person person;

  List<MaterialStateProperty<Color>> colors = [MaterialStateProperty.all(Colors.white), MaterialStateProperty.all(Colors.green), MaterialStateProperty.all(Colors.yellow), MaterialStateProperty.all(Colors.red)];
  List<Color> colorColors = [Colors.white, Colors.green, Colors.yellow, Colors.red];

  @override
  Widget build(BuildContext context) {
        return getAvailabilities();
  }

  Widget getAvailabilities(){
    Map<String, int>? availabilities = Map.from(person.availabilities);

    List<Widget> widgets = [];
    widgets.add(Text(person.name, style: const TextStyle(fontSize: 25)));
    availabilities.forEach((key, value) {
        widgets.add(SizedBox(height:10));
        widgets.add(AvailabilityButton(borderRadius:5.0, width: 30, height: 30, backGroundColor: colors[value], color: colorColors[value], onTap: (){}));
    });
    Widget column = Column(children: widgets);
    return column;
  }
}
