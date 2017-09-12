part of dataProcessing;

/// Implementation of [Label] abstract class
/// Support class for Visualization Object
///
/// Identify the Visualization Object with [id]
/// Store the information from the input data like [name], [tablePos] and
/// also information for sorting the connections [index]
/// and handle the multiple name occurrence with [mainLabel]
class LabelObj implements Label{

  ///The name of the segment
  String _name;
  ///The position of the segment in the parent
  int _index;
  ///The position of the segment is in the row or in the column
  bool _isRow = false;
  ///The unique identification of the segment
  String _id = "";
  ///The position of the segment in the table
  int _tablePos = -1;

  int _numberOfGeneratedLabel = 0;

  ///The label which has the same name
  Label _mainLabel = null;

  ///The label's group number
  int _groupNum = 1;

  ///Get the segment position in the table
  int get tablePos => _tablePos;

  ///Set the segment position in the table
  set tablePos(int value) {
    _tablePos = value;
  }

  String _diagramID = "defualtID";

  @Deprecated("Replaced by tablePos")
  int _tableRow = 0;

  @Deprecated("Replaced by tablePos")
  int _tableCol = 0;

  /// Simple constructor
  ///
  /// Contains the [_name], [_index], [_isRow] and some optional variable
  /// like [_tableCol] and [_tableRow] which are deprecated
  LabelObj(this._name, this._index, this._isRow, this._diagramID,
      [this._tableCol = -1, this._tableRow = -1]){
    this._id = MathFunc.generateUniqueID(Label.listOfIDs);
  }

  /// Deprecated constructor
  ///
  /// Contains the [_name], [_index], [offset] and some optional variable
  /// like [_tableCol] and [_tableRow] which are deprecated
  @Deprecated("Because of No uasge")
  LabelObj.fromRaw(this._name, this._index, int offset,
      [this._tableCol = -1, this._tableRow = -1]){
    this._id = MathFunc.generateUniqueID(Label.listOfIDs);
  }

  /// Create label with predefined ID
  ///
  /// Contains the [_name], [_id], [_index], [_isRow] and some optional variable
  /// like [_tableCol] and [_tableRow] which are deprecated
  LabelObj.ID(this._name, this._id, this._index, this._isRow, this._diagramID,
      [this._tableCol = -1, this._tableRow = -1]);

  /// Create label from JSON data
  LabelObj.fromJson(String jsonData){
    dynamic decode = JSON.decode(jsonData);
    this._name = decode["Name"] as String;
    this._index = decode["Index"] as int;
    this._isRow = decode["IsRow"] as bool;
    this._id = decode["Id"] as String;
  }

  /// Create label from Map
  LabelObj.fromMap(Map data){
    this._name = data["Name"] as String;
    this._index = data["Index"] as int;
    this._isRow = JSON.decode(data["IsRow"] as String) as bool;
    this._id = data["Id"] as String;
  }

  /// Get the name of the segment
  @override
  String get name => _name;

  /// Set the name of the segment
  @override
  set name(String value) => _name = value;

  /// Get the position of the segment in the parent
  @override
  get index => this._index;

  /// Set the position of the segment in the parent
  @override
  set index(int value) => _index = value;

  /// Get the position of the segment is in the row or in the column
  bool get isRow => _isRow;

  /// Set the position of the segment is in the row or in the column
  set isRow(bool value) => _isRow = value;

  /// Gets the label's group number
  @override
  int get groupNumber {
    return this._groupNum;
  }

  @override
  Label get groupLabel{
    Label retVal = Label.groupLabels[this._diagramID][this._groupNum];

    if(retVal == null){
      Label.groupLabels[this._diagramID][this._groupNum] = new LabelObj(
          "Group${this._groupNum}",
          Label.groupLabels[this._diagramID].length + 1, true, this._diagramID);
      retVal = Label.groupLabels[this._diagramID][this._groupNum];
      retVal.tablePos = retVal.index;
      retVal.groupNumber = -1;
    }

    return retVal;
  }

  /// Sets the label's group number
  @override
  set groupNumber(int value) {
    this._groupNum = value;
  }

  /// Gets new label from this label
  Label get generateNewLabel{
    var mLabel = this.mainLabel;
    var newID = this.id + MathFunc.generateUniqueID(VisualObject.listOfIDs);
    var newName = mLabel.name + (++this._numberOfGeneratedLabel).toString();
    var newLabel = new LabelObj.ID(newName,newID,this._numberOfGeneratedLabel,
        mLabel.isRow, this._diagramID);
    newLabel.tablePos = mLabel.tablePos;
    return newLabel;
  }

  /// Return with the main label
  Label get mainLabel{
    return this._mainLabel == null ? this : this._mainLabel;
  }

  set mainLabel(Label label){
    this._mainLabel = label;
  }

  /// Is this label a unique label or does it has other parts
  /// If mainLabel is null then it is unique [false] otherwise not [true]
  bool get isPartialLabel{
    if(this._mainLabel == null){
      return false;
    }else{
      if(this._mainLabel == this){
        return false;
      }else{
        return true;
      }
    }
  }

  /// Get the unique identification of the segment
  @override
  String get id{
    return this.isPartialLabel ? (this._mainLabel as LabelObj)._id : this._id;
    /*var labelOwnID = this.isPartialLabel ? (this._mainLabel as LabelObj)._id : this._id;
    var groupLabel = this.isPartialLabel ? (this._mainLabel as LabelObj).groupLabel : this.groupLabel;
    return "${groupLabel.id}_${labelOwnID}";*/
    /*if(this.mainLabel == null){
      return this._id;
    }else if(this.isRow){
      if(this.mainLabel.isRow){
        if(this.tablePos <= this.mainLabel.tablePos){
          return this._id;
        }else{
          return (this.mainLabel as LabelObj)._id;
        }
      }else{
        return this._id;
      }
    }else{
      if(this.mainLabel.isRow){
        return (this.mainLabel as LabelObj)._id;
      }else{
        if(this.tablePos <= this.mainLabel.tablePos){
          return this._id;
        }else{
          return (this.mainLabel as LabelObj)._id;
        }
      }
    }*/
  }

  /// Set the unique identification of the segment
  @override
  set id(String value) => (this.mainLabel as LabelObj)._id = value;

  @Deprecated("Replaced by tablePos")
  int get tableCol => _tableCol;

  @Deprecated("Replaced by tablePos")
  set tableCol(int value) {
    _tableCol = value;
  }

  @Deprecated("Replaced by tablePos")
  int get tableRow => _tableRow;

  @Deprecated("Replaced by tablePos")
  set tableRow(int value) {
    _tableRow = value;
  }

  /// Check is this label [other] has the same name as my part
  bool isMyPart(Label other){
    if(!this.isPartialLabel){
      return false;
    }
    return this.mainLabel.name == other.name;
  }

  /// String representation of the label
  @override
  String toString() {
    return "Name: ${this._name} ||\n ID: ${this._id} || \n Index: ${this._index} ||\n TablePos: ${this.tablePos}";
  }

  void resetLabelGenerationCounter(){
    this._numberOfGeneratedLabel = 0;
  }

  /// Create a map from the label
  Map toJson() {
    Map map = new Map<String, dynamic>();
    map["Name"] = this._name;
    map["Index"] = this._index;
    map["IsRow"] = this._isRow.toString();
    map["Id"] = this._id;
    return map;
  }

  /// Compare to two label based on their [index]
  @override
  int compareTo(Label other) {
    return this.index.compareTo(other.index);
  }

  /// Hard copy the label object
  @override
  Label copy() {
    return new LabelObj.ID(this.name, this.id, this.index, this.isRow, this._diagramID);

  }

  @override
  int get hashCode {
    return _id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is LabelObj &&
        this._id == other._id;
  }


}