import '../graphic/render.dart' show Color;
export '../graphic/render.dart' show Color;

import 'dart:math';
import '../math/math.dart';


class Interaction{
  static List<String> interactionsIDs = new List<String>();

  String icon = "info";
  String tooltip = "Default tooltip";
  Color color = new Color(new Random().nextInt(0xffffff));
  Function action;
  String id;

  Interaction([this.action = null,this.icon = "info", this.tooltip = "Default tooltip", this.color = null]){
    if(this.action == null){
      this.action = (dynamic _){print("No action");};
    }
    if(this.color == null){
      this.color = new Color(new Random().nextInt(0xffffff));
    }
    this.id = MathFunc.generateUniqueID(Interaction.interactionsIDs);
  }
}
