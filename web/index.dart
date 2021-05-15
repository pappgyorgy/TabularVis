import 'dart:async';
import 'dart:html';
import 'dart:convert';
import 'dart:collection';

import 'package:angular/angular.dart';
import 'package:angular/core.dart';
import 'package:bezier_simple_connect_viewer/bezier_simple_connect_viewer.dart';
// ignore: uri_has_not_been_generated
import 'index.template.dart' as ng;
// ignore: uri_has_not_been_generated
import 'package:bezier_simple_connect_viewer/src/components/app_component.template.dart' as ngRoot;

import 'package:logging/logging.dart';

@Injectable()
class ErrorHandler implements ExceptionHandler {
  ApplicationRef _appRef;
  Logger sender = new Logger("AppLogger");

  ErrorHandler(Injector injector) {
    // prevent DI circular dependency
    new Future<Null>.delayed(Duration.ZERO, () {
      _appRef = injector.get(ApplicationRef) as ApplicationRef;
    });
  }

  @override
  void call(dynamic exception, [dynamic stackTrace, String reason]) {
    final stackTraceParam = stackTrace is StackTrace
        ? stackTrace
        : (stackTrace is String
        ? new StackTrace.fromString(stackTrace)
        : (stackTrace is List
        ? new StackTrace.fromString(stackTrace.join('\n'))
        : null));
    sender.shout(reason ?? exception, exception, stackTraceParam);

    // We can try to get an error shown, but don't assume the app is
    // in a healthy state after this error handler was reached.
    // You can for example still instruct the user to reload the
    // page with danger to cause hare because of inconsistent
    // application state..
    // To get changes shown, we need to explicitly invoke change detection.
    _appRef?.tick();
  }
}

Future main() async{

  //https://freetypography.com/2014/07/17/free-font-s-arial/
  var string = await HttpRequest.getString("fonts/open_sans_regular.json");
  MapBase<String, dynamic> jsonMap = json.decode(string);
  loadFace(jsonMap);

  string = await HttpRequest.getString("fonts/open_sans_extrabold_regular.json");
  MapBase<String, dynamic> jsonMap2 = json.decode(string);
  loadFace(jsonMap2);

  string = await HttpRequest.getString("fonts/open_sans_bold.json");
  MapBase<String, dynamic> jsonMap3 = json.decode(string);
  loadFace(jsonMap3);

  //bootstrapStatic(AppComponent, [provide(ExceptionHandler, useClass: ErrorHandler)], ng.initReflector);
  runApp(ngRoot.AppComponentNgFactory);
}