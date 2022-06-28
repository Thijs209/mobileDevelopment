import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datum_prikker/custom_widgets/best_dates.dart';
import 'package:datum_prikker/custom_widgets/custom_button.dart';
import 'package:datum_prikker/custom_widgets/empty_content.dart';
import 'package:datum_prikker/custom_widgets/person_list_tile.dart';
import 'package:datum_prikker/custom_widgets/person_info.dart';
import 'package:datum_prikker/main.dart';
import 'package:datum_prikker/pages/log_in_page.dart';
import 'package:datum_prikker/pages/submit_date.dart';
import 'package:datum_prikker/custom_widgets/person.dart';
import 'package:datum_prikker/custom_widgets/planner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class WatchPlanner extends StatefulWidget {
  static const String routeName = "/WatchPlanner";

  static Route route({required Planner planner}){
    return MaterialPageRoute(
        settings: RouteSettings(name:routeName),
        builder: (context) => WatchPlanner(planner: planner)
    );
  }

  const WatchPlanner({Key? key, required this.planner}): super(key: key);

  final Planner planner;

  @override
  State<WatchPlanner> createState() => _WatchPlannerState();
}

class _WatchPlannerState extends State<WatchPlanner> {
  final String title = "Planner";
  Uri? uri;
  var collection;
  var querySnapshot;

  List<Person> persons = [];
  // List<Widget> personListTiles= [];
  List<Widget> personInfo = [];

  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => getPersons());
  }

  @override
  Widget build(BuildContext context) {
    if(user == null){
      // wrong call in wrong place!
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => LoginPage(planner: null)
      ));
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {Navigator.pushNamed(context, "/HomePage");},),
        centerTitle: true,
        title: Text(
          widget.planner.eventName,
          style: const TextStyle(fontSize: 26),
        ),
        actions: [
          TextButton(onPressed: () async {await _share();Share.share(uri.toString());}, child: const Text("Delen", style: TextStyle(color: Colors.white, fontSize: 18)))
        ],
      ),
      body: Builder(
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Column(
                children: [
                  SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Column(children: [
                          SizedBox(
                            width: double.infinity,
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: [0.001, 1],
                                    colors: [
                                      Colors.grey,
                                      Colors.white30,
                                    ],
                                  )),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    "Organisator: " + widget.planner.name,
                                    style: const TextStyle(fontSize: 24),
                                    textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                          persons.isNotEmpty
                              ? notEmpty() : const EmptyContent(
                            title: "Nog niemand heeft gereageerd",
                            message: "Wees de eerste om te reageren!",
                          ),
                          ])
                      )
                  ),
                  SizedBox(
                    width: 200,
                    height: kToolbarHeight,
                    child: FloatingActionButton.extended(
                      onPressed: () async {
                        await Navigator.pushNamed(context,'/SubmitDate', arguments: widget.planner);
                        setState(() {getPersons();});},
                      label: Text("Geef een datum op"),
                    ),
                  )
                ]),
              );
        }),
    );
  }

  Column notEmpty(){
    return Column(children: [
    const SizedBox(
      width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Deelnemers:",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ),
      Column(
        children: getPersonTiles(),
      ),
      const SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Beschikbare Datums:",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: getDates(),
              ),
              const SizedBox(width: 10,),
              Flexible(
                child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [getPersonInfo()],
                  ),
                ),
              )
            ],
          ),
        ),
      )
    ]);
  }

  getPersons() async {
    persons = [];
    var collection = FirebaseFirestore.instance
        .collection('planners')
        .doc(widget.planner.pid)
        .collection("availability");
    var querySnapshot = await collection.get();
    //loopt door de documenten in de collectie heen
    for (var snapshot in querySnapshot.docs) {
      //maakt een persoon van elk document
      persons.add(Person(snapshot.get("name"), snapshot.get("availability")));
    }
    setState(() {});
  }

  Widget getPersonInfo() {
    personInfo = [];
    getBestDate();
    //creates personinfo widget for every person
    for (var person in persons) {
      personInfo.add(Container(padding: EdgeInsets.all(8.0), color: Colors.white ,child: PersonInfo(person)));
      personInfo.add(const SizedBox(width: 20));
    }
    Row row = Row(children: personInfo);
    return row;
  }

  //returns text widgets with available dates
  List<Widget> getDates() {
    List<Widget> dates = [];
    var availabilities = Map.from(persons[0].availabilities);
    dates.add(const SizedBox(height: 41.5,));
    availabilities.forEach((key, value) {
      dates.add(Text(key, style: const TextStyle(fontSize: 20),));
      dates.add(const SizedBox(height: 17));
    });
    return dates;
  }

  List<Widget> getPersonTiles() {
    List<Widget> personListTiles = [];
    for (Person person in persons) {
      //maakt een plannerlisttile en voegt deze toe aan planners
      personListTiles.add(PersonListTile(person: person));
      //zorgt voor padding
      personListTiles.add(const SizedBox(height: 2));
    }
    return personListTiles;
  }

  getBestDate(){
    Map<String, int>? dates = Map();
    for (Person person in persons){
      Map<String, int>? availabilities = Map.from(person.availabilities);
      availabilities.forEach((key, value) {
        if(dates[key] == null){
          dates[key] = 1;
        }

        if(value == 1 && (dates[key] == 1 || dates[key] == null)){
          dates[key] = 1;
        } else if(value == 2 && dates[key] != 3){
          dates[key] = 2;
        } else if(value == 3){
          dates[key] = 3;
        }
      });
    }
    Widget bestDates = Container(padding: const EdgeInsets.all(8.0), color: Colors.white, child: BestDates("Beschikbaar", dates));
    personInfo.add(bestDates);
    personInfo.add(SizedBox(width: 20,));
  }

  _share() async{
    FirebaseDynamicLinks links = FirebaseDynamicLinks.instance;

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      // The Dynamic Link URI domain. You can view created URIs on your Firebase console
      uriPrefix: 'https://datumprikker.page.link',
      // The deep Link passed to your application which you can use to affect change
      link: Uri.parse('https://datumprikker.page.link/${widget.planner.eventName}/${widget.planner.pid}'),
      // Android application details needed for opening correct app on device/Play Store
      androidParameters: const AndroidParameters(
        packageName: "com.example.datum_prikker",
        minimumVersion: 1,
      ),
      // iOS application details needed for opening correct app on device/App Store
      iosParameters: const IOSParameters(
        bundleId: "iosBundleId",
        minimumVersion: '2',
      ),
    );

    uri = await links.buildLink(parameters);
  }
}
