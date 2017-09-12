import 'dart:async';
import 'package:angular2/core.dart';
import 'package:polymer/polymer.dart';

@Directive(selector: 'paper-tabs[selected]')
class PaperTabsSelectedDirective {
  @Output() StreamController selectedChange = new StreamController<dynamic>();

  @HostListener('iron-select', const ['\$event'])
  void onChange(dynamic e) =>
      selectedChange.add(convertToDart(e).currentTarget.selected);
}