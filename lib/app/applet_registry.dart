import 'package:wills_generic_app/app/applet.dart';
import 'package:wills_generic_app/applets/competition_tracker/competition_tracker_applet.dart';

class AppletRegistry {
  AppletRegistry._();

  static List<Applet> all = [
    CompetitionTrackerApplet(),
  ];
}
