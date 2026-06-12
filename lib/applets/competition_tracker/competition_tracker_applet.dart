import 'package:flutter/material.dart';
import 'package:wills_generic_app/app/applet.dart';
import 'package:wills_generic_app/applets/competition_tracker/screens/tournament_list.dart';

class CompetitionTrackerApplet extends Applet {
  CompetitionTrackerApplet()
      : super(
          name: 'Competition Tracker',
          icon: Icons.gavel,
          builder: (_) => const TournamentListScreen(),
        );
}
