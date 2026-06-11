import 'package:flutter/material.dart';
import 'package:wills_generic_app/app/applet.dart';
import 'package:wills_generic_app/applets/example/example_screen.dart';

class ExampleApplet extends Applet {
  ExampleApplet()
      : super(
          name: 'Example',
          icon: Icons.star,
          builder: (_) => const ExampleScreen(),
        );
}
