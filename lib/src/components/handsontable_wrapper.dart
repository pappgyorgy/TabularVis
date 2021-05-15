@JS()
library handsontable;

import 'package:js/js.dart';
import 'package:angular/angular.dart';

@Injectable()
@JS()
class DataTable{
  external void createTable(String containerElementID, Function valueChanged, Function selectionChanged);
  external List get matrixData;
  external set matrixData(List newValue);
  external factory DataTable();
  external void refreshTable();
  external void changeMatrixData(dynamic source, int row, int col);
  /*external static List get data;
  external void addRow();
  external void removeRow();
  external void addCol();
  external void removeCol();
  external void setData(List data);*/
}