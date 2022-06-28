import 'package:flutter/material.dart';

class Planner{
  Planner({required this.organiser, required this.pid, required this.eventName, required this.name, required this.dates});

  final String pid;
  final String name;
  final String eventName;
  final List dates;
  final String organiser;
}