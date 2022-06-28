import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datum_prikker/navigation.dart';
import 'package:datum_prikker/pages/log_in_page.dart';
import 'package:datum_prikker/pages/watch_planner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

import 'custom_widgets/planner.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //get link that opened app
  PendingDynamicLinkData? link = await FirebaseDynamicLinks.instance.getInitialLink();
  var collection = FirebaseFirestore.instance.collection('planners');
  var querySnapshot = await collection.get();

  Planner? planner;

  runApp(MyApp(planner:planner, querySnapshot: querySnapshot, link: link));
}



class MyApp extends StatefulWidget {
  MyApp({Key? key,this.querySnapshot, this.planner, this.link}) : super(key: key);

  Planner? planner;
  var querySnapshot;
  PendingDynamicLinkData? link;
  MaterialColor theme = Colors.teal;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    FirebaseDynamicLinks.instance.onLink.listen((link){
      getPlanner(link, widget.querySnapshot);
    });

    if(widget.link != null){
      getPlanner(widget.link!, widget.querySnapshot);
    }

    return MaterialApp(
        onGenerateRoute: RouteGenerator.onGenerateRoute,
        title: "Planster",
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.grey[100],
          primarySwatch: widget.theme,
        ),
        home: FutureBuilder(
          future: _fbApp,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('You have an error! ${snapshot.error.toString()}' );
              return const Text("something went wrong");
            } else if (snapshot.hasData) {
              if(FirebaseAuth.instance.currentUser != null && widget.planner !=null){
                Future.delayed(Duration.zero, () {
                  Navigator.pushNamed(context, "/WatchPlanner", arguments: widget.planner);
                });
                return WatchPlanner(planner: widget.planner!);
              } else  if (widget.planner !=null){
                Future.delayed(Duration.zero, () {
                  Navigator.pushNamed(context, "/LoginPage", arguments: widget.planner);
                });
                return LoginPage(planner: widget.planner,);
              } else {
                return LoginPage(planner: widget.planner,);
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        )
    );
  }

  getPlanner(PendingDynamicLinkData link, var querySnapshot){
    String pid = link.link.toString().split("/").last;

    for(var snapshot in querySnapshot.docs){
      if(snapshot.get("pid") == pid){
        widget.planner = Planner(pid: snapshot.get("pid"), eventName: snapshot.get('eventName'), name: snapshot.get('name'), dates: snapshot.get('date'), organiser: snapshot.get('organiser'));
        setState(() {});
      }
    }
  }
}
