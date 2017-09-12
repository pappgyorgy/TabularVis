import 'package:angular2/core.dart';
import 'package:logging/logging.dart';

@Injectable()
class AppLogger{

  final Logger sender = new Logger("AppLogger");

  AppLogger(){
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });
  }

}