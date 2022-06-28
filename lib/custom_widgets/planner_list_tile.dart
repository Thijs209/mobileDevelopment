import 'package:datum_prikker/pages/watch_planner.dart';
import 'package:datum_prikker/custom_widgets/planner.dart';
import 'package:flutter/material.dart';

class PlannerListTile extends StatelessWidget {
  const PlannerListTile({Key? key, required this.planner, required this.onTap}) : super(key: key);
  final Planner planner;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(planner.eventName, style: TextStyle(fontSize: 20)),
      subtitle: Text("Organisator: " + planner.name),
      trailing: Icon(Icons.chevron_right),
      tileColor: Colors.white,
      onTap: onTap,
    );
  }
}
