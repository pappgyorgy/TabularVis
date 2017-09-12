import 'dart:html';

import 'package:polymer_elements/paper_slider.dart';

class SliderValue{
  num value = 0.0;
  num immValue = 0.0;
  num maxValue = 0.0;
  num minValue = 0.0;
  Function valueChangeCallback;
  PaperSlider htmlElement;

  SliderValue(this.value, this.immValue, this.minValue, this.maxValue, [this.valueChangeCallback = null]){
    if(this.valueChangeCallback == null){
      //this.valueChangeCallback = (double value){print("$value");};
    }
  }

  PaperSlider _getEventTarget(Event event){
    if(htmlElement == null){
      htmlElement = event.target as PaperSlider;
    }
    return htmlElement;

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
    if(this.htmlElement == null) return;
    this.htmlElement.disabled = value;
  }

  void valueChange(Event event){
    PaperSlider element = _getEventTarget(event);
    this.value = element.value as num;
    this.valueChangeCallback(this.value);
  }

  void immValueChange(Event event){
    PaperSlider element = _getEventTarget(event);
    this.immValue = element.immediateValue;
    this.valueChangeCallback(this.immValue);
  }

}