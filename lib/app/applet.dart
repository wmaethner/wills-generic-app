import 'package:flutter/material.dart';

abstract class Applet {
  const Applet({
    required this.name,
    required this.icon,
    required this.builder,
  });

  final String name;
  final IconData icon;
  final WidgetBuilder builder;
}
