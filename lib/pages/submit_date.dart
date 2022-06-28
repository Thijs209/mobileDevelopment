import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datum_prikker/custom_widgets/custom_input_field.dart';
import 'package:datum_prikker/custom_widgets/fill_availability.dart';
import 'package:datum_prikker/custom_widgets/show_alert_dialog.dart';
import 'package:datum_prikker/main.dart';
import 'package:datum_prikker/custom_widgets/planner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubmitDate extends StatefulWidget {
    static const String routeName = "/SubmitDate";

  static Route route({required Planner planner}){
    return MaterialPageRoute(
        settings: const RouteSettings(name:routeName),
        builder: (context) => SubmitDate(planner: planner)
    );
  }

  SubmitDate({required this.planner});
  final Planner planner;

  @override
  State<SubmitDate> createState() => _SubmitDateState();
}

class _SubmitDateState extends State<SubmitDate> {
  List<FillAvailability> availabilities = [];

  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user = FirebaseAuth.instance.currentUser!;
  String? _name;
  String? _date;
  int? _available;
  Map<String, int> availabilty = {"remove": 0};

  CollectionReference? collection;
  var snapshot;
  var availabilityCol;
  var availabilitieDocuments;

  bool exists = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => getAvailability());
  }

  @override
  Widget build(BuildContext context) {
    !user.isAnonymous? _name = user.displayName : _name = null;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Vul in wanneer jij kan"),
        actions: <Widget>[
          TextButton(
              child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 18)),
              onPressed: _submit
            ),
          ],
      ),
      body: Builder(builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: user.isAnonymous? CustomInputField(
                      labelText: "Jouw Naam",
                      onSaved: (value) => _name = value,
                    ):Container(),
                  ),
                  Row(
                    children: const [
                      SizedBox(width: 97,),
                      Text("Beschikbaar"),
                      SizedBox(width: 22,),
                      Text("Misschien"),
                      SizedBox(width: 15,),
                      Text("Onbeschikbaar")
                    ],
                  ),
                  Column(children: availabilities)
                ]),
            ),
          ),
        );
      }),
    );
  }

  getAvailability() async{
    List dates = widget.planner.dates;

    collection = FirebaseFirestore.instance.collection('planners');
    snapshot = collection?.doc(widget.planner.pid);
    availabilityCol = snapshot.collection("availability");
    availabilitieDocuments = await availabilityCol.get();

    Map<String, int>? pressedDates;

    for(var availabilitieDoc in availabilitieDocuments.docs){
      if(auth.currentUser!.uid == availabilitieDoc.get("uid")){
        pressedDates = Map.from(availabilitieDoc.get("availability"));
      }
    }

    for(String date in dates){
      FillAvailability availabilitie = pressedDates !=null ? FillAvailability(date: date, pressed: pressedDates[date],) : FillAvailability(date: date);
      availabilities.add(availabilitie);
    }
    setState(() {});
  }

  String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

  _submit() {
    //checks if everything is filled in
    if(_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      for (int i = 0; i < availabilities.length; i++) {
        _date = availabilities[i].date;
        _available = availabilities[i].pressed;
        //when not everything is filled in yet
        if (availabilities[i].pressed == 0) {
          ShowAlertDialog(context, title: "Niet alle datums zijn ingevuld",
              content: "Om verder te gaan moeten je voor elke datum aangeven of je wel of niet kan.",
              defaultActionText: "Oke");
          return null;
          //if everything is filled in
        } else {
          //adds date to map
          availabilty[_date!] = _available!;
          //removes placeholder entry
          if (availabilty.containsKey("remove")) {
            availabilty.remove("remove");
          }
        }
      }
      //creates id
      String _pid = documentIdFromCurrentDate();
      //make new collection
      for(var availabilitieDoc in availabilitieDocuments.docs){
        if(auth.currentUser!.uid == availabilitieDoc.get("uid")){
          availabilityCol.doc(availabilitieDoc.get("pid")).delete();
        }
      }

      snapshot.collection("availability").doc(_pid).set({
        "name": _name,
        "availability": availabilty,
        "uid": auth.currentUser!.uid,
        "pid": _pid
      });
      Navigator.pop(context);
    }
  }
}
