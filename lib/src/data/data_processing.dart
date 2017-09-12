library dataProcessing;

import 'package:angular2/core.dart';
import '../math/math.dart' show RangeMath, MathFunc, ColorRange, NumberRange, RangeCloseType;
import 'package:three/three.dart' show Color;
import '../geometry/geometry.dart' show ShapeType;
import 'dart:convert';
import 'dart:math';
import 'dart:core';
import 'package:logging/logging.dart';

//Diagram
part 'data_matrix.dart';
part 'input_data.dart';
part 'object_vis.dart';
part 'label.dart';
part 'conn_manager.dart';
part 'connection_vis.dart';
part 'config_conn.dart';
part 'config_sub_conn.dart';
part 'letter_provider.dart';

//Interfce
part 'interface/vis_object.dart';
part 'interface/vis_connection.dart';
part 'interface/conn_config.dart';
part 'interface/sub_conn_config.dart';
part 'interface/label.dart';

//Sort
part 'sort/sort_data_search_algorithm.dart';
part 'sort/sort_data_geometry.dart';
part 'sort/state.dart';
part 'sort/sortConnection.dart';
part 'sort/diagram_cross_state.dart';
part 'sort/diagramState.dart';
part 'sort/diagramStateFull.dart';
part 'sort/diagram_geom_state.dart';
part 'sort/sort_info_data.dart';
part 'sort/diagramStateFullWithoutCopy.dart';

/// Helps to handle the input data
/// Gives an input data from the give raw input
@Injectable()
class DataProcessing{

  /// The input data for the visualization
  Map<String, InputData> _inputData;

  /// Simple constructor
  ///
  /// initialize the input data
  DataProcessing(){
    _inputData = new Map<String, InputData>();
  }

  /// Create a new input data with the given [id] and [data]
  InputData addMatrix(String id, List<List<List<dynamic>>> data){
    this._inputData[id] = new DataMatrix.fromMatrix(id, data);
    return this._inputData[id];
  }

  /// Set a new input data with the given [id] and [data]
  void setMatrix(String id, InputData data){
    this._inputData[id] = data;
  }

  /// Gives back the input data which has the same [id]
  /// If [getNewRandom] is provided and true then it will give us a new input data
  /// which was created based on [opt]
  InputData getMatrix(String id, [bool getNewRandom = false, bool getEmpty = false, List<int> opt = const [0,7,0,7,1,0,1,99]]){
    if(getNewRandom){
      this._inputData[id] = new DataMatrix.randomGenerated(id,
          opt[0], opt[1], opt[2], opt[3], opt[4], (opt[5] < 1 ? false : true), opt[6], opt[7]);
      return this._inputData[id];
    }else if(getEmpty){
      this._inputData[id] = new DataMatrix(id, opt[0], opt[2], opt[4]);
      return this._inputData[id];
    }else{
      return this._inputData[id];
    }

  }

  VisualObject getInputDataVisualObject(String ID){
    if(this._inputData[ID] == null){
      throw new StateError("There is no matrix with the given ID: $ID");
    }

    return this._inputData[ID].getVisualizationObjectHierarchy();
  }

}