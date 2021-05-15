import 'dart:html';
import 'dart:async';
import 'package:angular/core.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:color_picker/color_picker.dart';
import '../graphic/render.dart' show Color;
import 'package:vector_math/vector_math.dart' show Colors;

import 'package:angular_components/laminate/popup/module.dart';
import 'package:angular_components/laminate/popup/popup.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_popup/material_popup.dart';

@Component(
  selector: 'color-input',
  templateUrl: 'template/color_input.html',
  directives: const <dynamic>[
    materialDirectives,
    coreDirectives,
    MaterialPopupComponent,
    MaterialButtonComponent,
    PopupSourceDirective,
    defaultPopupPositions
  ],
  providers: const <dynamic>[materialProviders],
  styleUrls: const ['template/scss/common.css', 'template/scss/color_input.css'],
)
class ColorInput implements OnDestroy, AfterViewInit{
  @Input()
  Color color = new Color(0xAAAAAA);

  StreamController<Color> _immediateColorChange = new StreamController<Color>();

  @Output()
  Stream<Color> get immediateColorChange => _immediateColorChange.stream;

  StreamController<Color> _colorChange = new StreamController<Color>();

  @Output()
  Stream<Color> get colorChange => _colorChange.stream;

  @ViewChild("colorPickerContainer") MaterialPopupComponent colorPickerContainer;
  @ViewChild("popupMainSection") HtmlElement popupMainSection;

  @Input()
  bool iconButton = false;
  @Input()
  bool centered = true;
  @Input()
  String labelLayout = "horizontal";
  @Input()
  bool flexLabel = false;
  @Input()
  String labelPosition = "end";
  @Input()
  String label = "";
  @Input()
  bool inputElementDisabled = false;
  @Input()
  bool raisedButton = false;
  @Input()
  bool disabled = false;

  bool afterInit = false;
  bool colorPickerVisibility = false;
  ColorPicker largeColorPicker;

  ColorInput(){
    largeColorPicker = new ColorPicker(256, initialColor: new ColorValue.fromRGB(color.rr, color.gg, color.bb));
  }

  void valueChange(Event event){
    this._colorChange.add(color);
  }

  void applySelectedColor(Event event){
    colorPickerVisibility = false;
    this._colorChange.add(color);
  }

  void immediateColorChangeCallback(ColorValue newColor, num hue, num saturation, num brightness) {
    if(afterInit) {
      this.color = convertColorValueToColor(newColor);
      this._immediateColorChange.add(this.color);
    }else{
      afterInit = false;
    }
  }

  Color convertColorValueToColor(ColorValue color){
    return new Color.fromArray([color.r / 255.0, color.g / 255.0, color.b / 255.0]);
  }

  String getColorString(){
    return this.color.getContextStyle();
  }

  @override
  void ngOnDestroy() {
    this._colorChange.close();
  }

  @override
  ngAfterViewInit() {
    (popupMainSection as DivElement).nodes.add(largeColorPicker.element);
    //largeColorPicker.currentColor = new ColorValue.fromRGB(color.rr, color.gg, color.bb);
    largeColorPicker.colorChangeListener = immediateColorChangeCallback;
    afterInit = true;
  }
}