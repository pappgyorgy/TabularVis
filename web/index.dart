import 'dart:async';
import 'dart:html';
import 'dart:mirrors';
import 'dart:convert' show JSON;

import 'package:polymer/polymer.dart';
import 'package:polymer_elements/iron_flex_layout_classes.dart';
import 'package:three/extras/font_utils.dart' as FontUtils;


import 'package:angular2/angular2.dart';
import 'package:angular2/platform/browser.dart';

import 'package:bezier_simple_connect_viewer/tabular_vis.dart';

Future loadFonts() async{

}

Future main() async{



  var string = await HttpRequest.getString("fonts/helvetiker_regular.json");
  FontUtils.loadFace(JSON.decode(string) as Map<String, String>);

  loadFonts();
  await initPolymer();
  bootstrap(AppComponent);

  //Initialize drawing area
  /*AppComponent app = new AppComponent();

  /*var testMatrix = [
    [[0], ['A'], ['B'], ['C']],

    [['D'], [1], [2], [5]],
    [['E'], [3], [4], [3]],
    [['F'], [3], [4], [1]],
  ];*/

  var testMatrix = [
    [[0], ['A'], ['B']],
    [['C'], [1], [2]],
    [['D'], [3], [4]],
  ];

  /*var testMatrix = [
    [[0], ['A'], ['B'], ['B'], ['C'], ['D'], ['E'], ['F'], ['G']],
    [['H'], [1], [2], [1], [2], [1], [2], [1], [2]],
    [['I'], [1], [2], [1], [2], [1], [2], [1], [2]],
    [['J'], [1], [2], [1], [2], [1], [2], [1], [2]],
    [['K'], [1], [2], [1], [2], [1], [2], [1], [2]],
    [['L'], [1], [2], [1], [2], [1], [2], [1], [2]],
    [['M'], [1], [2], [1], [2], [1], [2], [1], [2]],
    [['N'], [1], [2], [1], [2], [1], [2], [1], [2]],
    [['O'], [1], [2], [1], [2], [1], [2], [1], [2]]
  ];*/

  /*for(var i = 1; i < 3; i++){
    for(var j = 1; j < 3; j++){
      testMatrix[i][j][0] = new Random().nextInt(12);
    }
  }*/

  //var diagramID = app.setInputData(testMatrix);

  //app.createDiagram(diagramID);

  app.drawSomething();*/
}