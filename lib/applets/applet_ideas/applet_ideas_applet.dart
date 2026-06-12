import 'package:flutter/material.dart';
import 'package:wills_generic_app/app/applet.dart';
import 'package:wills_generic_app/applets/applet_ideas/applet_ideas_screen.dart';

class AppletIdeasApplet extends Applet {
  AppletIdeasApplet()
      : super(
          name: 'Applet Ideas',
          icon: Icons.lightbulb,
          builder: (_) => const AppletIdeasScreen(),
        );
}
