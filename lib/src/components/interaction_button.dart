import 'package:angular/core.dart';
import 'package:angular/angular.dart';
import '../graphic/render.dart' show Color;
import 'dart:math';
import 'dart:html';

//polymer elements
/*import 'package:polymer/polymer.dart';
import 'package:polymer_elements/iron_flex_layout/classes/iron_flex_layout.dart';
import 'package:polymer_elements/paper_icon_button.dart';
import 'package:polymer_elements/iron_icons.dart';
import 'package:polymer_elements/paper_fab.dart';
import 'package:polymer_elements/image_icons.dart';
import 'package:polymer_elements/av_icons.dart';*/

//requirements
import 'interaction_handler.dart';
export 'interaction_handler.dart';

@Component(
    selector: 'interaction-button',
    templateUrl: 'template/interaction-button.html',
    directives: const <dynamic> [coreDirectives,],
)
class InteractionButton implements OnInit, AfterViewInit{
  List<Interaction> listOfInteractions;
  InteractionHandler _interactionHandler;
  bool _isMenuShowed = false;

  bool get isMenuShowed => _isMenuShowed;

  @override
  void ngOnInit() {
    listOfInteractions = this._interactionHandler.getListOfInteractions();
  }


  @override
  void ngAfterViewInit() {
    querySelectorAll(".miniButton").forEach((Element element){
      element.style.opacity = "0.0";
    });
  }

  InteractionButton(this._interactionHandler){

  }

  @Deprecated("Already not used")
  void doAction(Event event){
    //print("I was clicked");
  }

  void toggleMenuButtons(MouseEvent event){

    querySelectorAll(".miniButton").forEach((Element element){
      element.style.opacity = double.parse(element.style.opacity) < 1.0 ? "1.0" : "0.0";
    });
    //print("I was clicked");
  }


  void showMenuButtons(){
    querySelectorAll(".miniButton").forEach((Element element){
      element.style.visibility = "visible";
      element.style.opacity = "1.0";
    });
    //print("mouse leave");
  }

  @HostListener('mouseleave')
  void hideMenuButtons(){
    querySelectorAll(".miniButton").forEach((Element element){
      element.style.visibility = "hidden";
      element.style.opacity = "0.0";
      _isMenuShowed = false;
    });
    //print("mouse leave");
  }

  Map<String, String> setStyle(int index){
    return <String, String>{
      "transition" : "visibility ${index * 150}ms, opacity ${index * 150}ms"
    };
  }

}