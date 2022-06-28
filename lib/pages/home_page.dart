import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datum_prikker/custom_widgets/custom_button.dart';
import 'package:datum_prikker/custom_widgets/empty_content.dart';
import 'package:datum_prikker/custom_widgets/planner_list_tile.dart';
import 'package:datum_prikker/custom_widgets/planner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class HomePage extends StatefulWidget {
  static const String routeName = "/HomePage";

  static Route route({Planner? planner}){
    return MaterialPageRoute(
        settings: RouteSettings(name:routeName),
        builder: (context) => HomePage(planner: planner,)
    );
  }
  HomePage({Key? key,this.planner}) : super(key: key);

  Planner? planner;


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> planners = [];
  User? user = FirebaseAuth.instance.currentUser;
  var collection;
  var querySnapshot;

  double? size;

  @override
  initState(){
    super.initState();
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => getPlanners());
  }

  @override
  Widget build(BuildContext context) {
    if(FirebaseAuth.instance.currentUser == null){
      Future.delayed(Duration.zero, () {
        Navigator.pushNamed(context, "/LoginPage");
      });
    }

    size = MediaQuery.of(context).size.height - (kToolbarHeight*2.5);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: MyApp().theme,
          centerTitle: true,
          title: Text("Planners"),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            TextButton(
                child: const Text('Log out',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                onPressed: _logout)
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: planners.isNotEmpty? Column(
                      children: planners,
                    ) : EmptyContent()
                  ),
                ),
                SizedBox(
                  width: 200,
                  height: kToolbarHeight,
                  child: FloatingActionButton.extended(
                    onPressed: () async {
                      await Navigator.pushNamed(context,'/CreatePlanner');
                      setState(() {getPlanners();});},
                    label: Text("Maak een planner"),
                  ),
                )
              ],
            ),
          ),
        ),
    );
  }

  void getPlanners() async {
    //clears planners so existing planners dont get duplicated
    planners = [];
    //haalt de planners collectie op
    collection = FirebaseFirestore.instance.collection('planners');
    //maakt een snapshot van de huidige data in de collectie
    querySnapshot = await collection.get();
    //loopt door de documenten in de collectie heen
    for(var snapshot in querySnapshot.docs){
      bool show = false;
      var availabilitiesCol = collection.doc(snapshot.get("pid")).collection("availability");
      var availabilities = await availabilitiesCol.get();
      for(var availability in availabilities.docs){
        if(availability.get("uid") == user!.uid){
          show = true;
        }
      }
      if(!user!.isAnonymous && (snapshot.get("organiser") == user!.email || show)){
        //maakt een planner van elk document
        Planner planner = Planner(organiser: snapshot.get("organiser"), pid: snapshot.get("pid"), eventName: snapshot.get('eventName'), name: snapshot.get('name'), dates: snapshot.get('date'));
        //maakt een plannerlisttile en voegt deze toe aan planners
        planners.add(Dismissible(key: Key(planner.pid), background: Container(color: Colors.red,),onDismissed: (direction) {removePlanner(planner, availabilities,availabilitiesCol);}, child: PlannerListTile(planner: planner, onTap: () async {await Navigator.pushNamed(context,'/WatchPlanner', arguments: planner);},)));
        //zorgt voor padding
        planners.add(const SizedBox(height: 2));
        setState((){});
      }
    }
  }

  removePlanner(Planner planner, availabilities, availabilitiesCol){
    if(planner.organiser == user!.email){
      collection.doc(planner.pid).delete();
    } else {
      for (var availability in availabilities.docs){
        if(availability.get("uid") == user!.uid){
          availabilitiesCol.doc(availability.get("pid")).delete();
        }
      }
    }
    getPlanners();
  }

  _logout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {});
  }
}
