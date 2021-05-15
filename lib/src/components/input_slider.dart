import 'dart:html';
import 'dart:async';
import 'package:angular/core.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'package:angular_components/material_input/material_number_accessor.dart';

@Component(
  selector: 'input-slider',
  templateUrl: 'template/input_slider.html',
  directives: const <dynamic>[
    materialDirectives, materialNumberInputDirectives, coreDirectives
  ],
  providers: const <dynamic>[materialProviders],
  styleUrls: const ['template/scss/common.css', 'template/scss/input_slider.css'],
)
class InputSlider implements OnDestroy{
  @Input()
  num value = 0.0;

  StreamController<num> _valueChange = new StreamController<num>();

  @Output()
  Stream<num> get inputValueChange => _valueChange.stream;

  @Input()
  bool centered = false;
  @Input()
  String inputButtonLayout = "horizontal";
  @Input()
  num maxValue = double.infinity;
  @Input()
  num minValue = double.negativeInfinity;
  @Input()
  num increaseValue = 1.0;
  @Input()
  String label = "";
  @Input()
  bool floatingLabel = true;
  @Input()
  bool inputElementDisabled = false;
  @Input()
  bool raisedButton = false;
  @Input()
  String inputType = "number";

  String stringValue = "";

  String errorMsg = "";

  InputSlider(){
    this.stringValue = this.value.toString();
  }

  void checkError(String newValue){
    try {
      if(newValue.isEmpty) return;
      this.value = num.parse(newValue);
      if(!checkMinValue()){
        if(!checkMaxValue()){
          errorMsg = "";
        }
      }
      if(errorMsg.isEmpty){
        this.valueChange();
      }
    }catch(error){
      errorMsg = "Not valid number";
    }
  }

  bool checkMinValue(){
    bool retVal = minValue > this.value;
    if(retVal){
      errorMsg = "Enter a number $minValue or greater";
    }
    return retVal;
  }

  bool checkMaxValue(){
    bool retVal = maxValue < this.value;
    if(retVal){
      errorMsg = "Enter a number $maxValue or smaller";
    }
    return retVal;
  }

  bool preCheckMaxInc(){
    return this.value + increaseValue > this.maxValue;
  }

  void incValue(Event event){
    if(!preCheckMaxInc()){
      this.value += increaseValue;
      this.valueChange();
    }
  }

  bool preCheckMinDec(){
    return this.value - increaseValue < this.minValue;
  }

  void decValue(Event event){
    if(!preCheckMinDec()){
      this.value -= increaseValue;
      this.valueChange();
    }
  }

  double get maxValueDouble{
    return this.maxValue.toDouble();
  }

  double get minValueDouble{
    return this.minValue.toDouble();
  }

  double get valueDouble{
    return this.value.toDouble();
  }

  void disabled(bool value){
    this.inputElementDisabled = value;
  }

  void valueChange(){
    this._valueChange.add(value);
  }

  @override
  void ngOnDestroy() {
    this._valueChange.close();
  }

}