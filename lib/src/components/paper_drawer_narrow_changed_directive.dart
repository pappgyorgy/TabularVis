import 'dart:async';
import 'package:angular2/core.dart';
import 'package:polymer/polymer.dart';

@Directive(selector: 'paper-drawer-panel[narrow-changed]')
class PaperDrawerPanelNarrowChangedDirective {
  @Output() StreamController selectedChange = new StreamController<dynamic>();

  @HostListener('narrow-changed', const ['\$event'])
  void onChange(dynamic e) =>
      selectedChange.add(convertToDart(e).currentTarget.selected);
}