import 'dart:async';
import 'package:angular2/core.dart';
import 'package:polymer/polymer.dart';

import 'package:polymer_elements/paper_input.dart';

@Directive(selector: 'paper-input[value]')
class PaperInputValueChangedDirective {
  StreamController _valueChange = new StreamController<dynamic>();

  @Output()
  Stream get valueChange => _valueChange.stream;

  @HostListener('value-changed', const ['\$event'])
  void onChange(dynamic e) =>
      _valueChange.add((e.target as PaperInput).value);
}