import 'package:angular2/angular2.dart';
import 'interaction.dart';
export 'interaction.dart';

@Injectable()
class InteractionHandler{

  Map<String, Interaction> _mapOfInteractions;

  List<Interaction> getListOfInteractions(){
    return _mapOfInteractions.values.toList(growable: false);
  }

  InteractionHandler(){
    _mapOfInteractions = new Map<String, Interaction>();
  }

  void addInteraction(Interaction newInteraction){
    _mapOfInteractions[newInteraction.id] = newInteraction;
  }

  Interaction addNewInteraction([Function action = null, String icon = "info", String tooltip = "Default tooltip", Color color = null]){
    Interaction retVal = new Interaction(action, icon, tooltip, color);
    this._mapOfInteractions[retVal.id] = retVal;
    return retVal;
  }

  void removeInteraction(String id){
    this._mapOfInteractions.remove(id);
  }
}

/*
* List<Interaction> retVal = <Interaction>[];
    retVal.add(new Interaction((dynamic _){print("my fisrt button");}, "add", "Open the menu"));
    retVal.add(new Interaction((dynamic _){print("my second button");}, "create", "kill the menu"));
    retVal.add(new Interaction((dynamic _){print("my second button");}, "settings", "kill the menu"));
    retVal.add(new Interaction((dynamic _){print("my second button");}, "cached", "kill the menu"));
    retVal.add(new Interaction((dynamic _){print("my second button");}, "build", "kill the menu"));
    retVal.add(new Interaction((dynamic _){print("my second button");}, "clear", "kill the menu"));
    return retVal;
*
* */