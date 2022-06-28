import 'package:datum_prikker/custom_widgets/planner.dart';
import 'package:datum_prikker/pages/create_planner.dart';
import 'package:datum_prikker/pages/home_page.dart';
import 'package:datum_prikker/pages/log_in_page.dart';
import 'package:datum_prikker/pages/submit_date.dart';
import 'package:datum_prikker/pages/watch_planner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RouteGenerator{
  static Route onGenerateRoute(RouteSettings settings){
    switch (settings.name) {
      case HomePage.routeName:
        return HomePage.route(planner: settings.arguments as Planner?);
      case LoginPage.routeName:
        return LoginPage.route(planner: settings.arguments as Planner?);
      case WatchPlanner.routeName:
        return WatchPlanner.route(planner: settings.arguments as Planner);
      case CreatePlanner.routeName:
        return CreatePlanner.route();
      case SubmitDate.routeName:
        return SubmitDate.route(planner: settings.arguments as Planner);

      default:
        return _default();
    }
  }

  static _default(){
    return MaterialPageRoute(
        builder: (_) => Scaffold(appBar: AppBar(title: const Text("error"))),
        settings: const RouteSettings(name: "/error")
    );
  }
}