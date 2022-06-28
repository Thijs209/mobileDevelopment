import 'package:datum_prikker/custom_widgets/person.dart';
import 'package:datum_prikker/custom_widgets/planner.dart';
import 'package:flutter/material.dart';

class PersonListTile extends StatelessWidget {
  const PersonListTile({Key? key, required this.person}) : super(key: key);
  final Person person;

  @override
  Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: DecoratedBox(decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.all(Radius.circular(12))
              ),
                child: Text(person.name[0].toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 54),),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(person.name, style: TextStyle(fontSize: 30),),
          ],
        ),
      );
  }
}
