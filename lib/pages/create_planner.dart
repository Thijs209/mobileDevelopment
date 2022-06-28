import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datum_prikker/custom_widgets/custom_input_field.dart';
import 'package:datum_prikker/custom_widgets/show_alert_dialog.dart';
import 'package:datum_prikker/custom_widgets/planner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'home_page.dart';

class CreatePlanner extends StatefulWidget {
  const CreatePlanner({Key? key, }) : super(key: key);

  // final Color theme;
  // final String title;

  static const String routeName = "/CreatePlanner";

  static Route route(){
    return MaterialPageRoute(
        settings: RouteSettings(name:routeName),
        builder: (context) => CreatePlanner()
    );
  }

  @override
  _CreatePlannerState createState() => _CreatePlannerState();
}

class _CreatePlannerState extends State<CreatePlanner> {
  final _formKey = GlobalKey<FormState>();

  DateFormat dateFormat = DateFormat("dd-MM-yyyy");
  final DateTime? _nullDate = DateTime(15, 12, 2022);

  String? _name;
  String? _eventName;
  List<DateTime>? _dates;

  User user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(!user.isAnonymous){
      _name = user.displayName;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maak een Datumprikker"),
        actions: <Widget>[
          TextButton(
              child: const Text('Save',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              onPressed: _submit)
        ],
      ),
      body: Builder(builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FirebaseAuth.instance.currentUser!.isAnonymous?
                      CustomInputField(
                        labelText: "Jouw Naam",
                        onSaved: (value) => _name = value,
                      ): Container(),
                      const SizedBox(
                        height: 8,
                      ),
                      CustomInputField(
                          labelText: "Event Naam",
                          onSaved: (value) => _eventName = value),
                      const SizedBox(
                        height: 30,
                      ),
                      const Text("Kies beschikbare datums:", style: TextStyle(fontSize: 16),),
                      SfDateRangePicker(
                        selectionMode: DateRangePickerSelectionMode.multiple,
                        monthViewSettings: DateRangePickerMonthViewSettings(firstDayOfWeek: 1),
                        enablePastDates: false,
                        onSelectionChanged: _submitted,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  _submitted(DateRangePickerSelectionChangedArgs args){
    _dates = args.value;
    _dates?.sort((a,b) {
      return a.compareTo(b);
    });
  }

  String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

  _submit() async {
    //haalt planners collection van database
    var collection = FirebaseFirestore.instance.collection('planners');
    //checkt of alles goed is ingevuld
    if(_dates != null) {
      List<String> _stringDates = [];
      for (var date in _dates!) {
        _stringDates.add(dateFormat.format(date).toString());
      }
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        //maakt een id aan voor de planner
        var _pid = documentIdFromCurrentDate();
        //stopt de data in de database
        var catchError = collection.doc(_pid).set({
          'name': _name!,
          'eventName': _eventName!,
          'date': _stringDates,
          'pid': _pid,
          'organiser': user.email
        }).catchError((error) => print('Add failed: $error'));
        //returned naar home page
        Navigator.pop(context);
      }
    }
  }
}
