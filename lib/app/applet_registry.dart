import 'package:wills_generic_app/app/applet.dart';
import 'package:wills_generic_app/applets/example/example_applet.dart';

class AppletRegistry {
  AppletRegistry._();

  static List<Applet> all = [
    ExampleApplet(),
  ];
}
