part of dataProcessing;

/// Support class for Visualization Object
///
/// Identify the Visualization Object with [id]
/// Store the information from the input data like [name], [tablePos] and
/// also information for sorting the connections [index]
/// and handle the multiple name occurrence with [mainLabel]
abstract class Label implements Comparable<Label>{

  static Map<String, Map<int, Label>> groupLabels = new Map<String, Map<int, Label>>();

  /// Store all the ID of the generated Visualization object
  static List<String> listOfIDs = new List<String>();

  static bool mergeByGroup = false;

  /// Check is the given labels [one] and [two] are siblings or not
  static bool createLabelSibling(Label one, Label two){
    var retVal = false;
    if(one.name.compareTo(two.name) == 0){
      if(!mergeByGroup) {
        retVal = true;
        if (!two.isPartialLabel) {
          two.mainLabel = one;
          two.groupNumber = one.groupNumber;
          if (!one.isPartialLabel) {
            one.mainLabel = one;
          }
        }
      }else{
        if(one.groupNumber == two.groupNumber){
          retVal = true;
          if (!two.isPartialLabel) {
            two.mainLabel = one;
            two.groupNumber = one.groupNumber;
            if (!one.isPartialLabel) {
              one.mainLabel = one;
            }
          }
        }
      }
    }
    return retVal;
  }

  /// Increases all labels indices in the list [listOfLabels] with [value]
  static void increaseLabelsIndices(List<Label> listOfLabels, int value){
    listOfLabels.forEach((Label l){
      l.index += value;
    });
  }

  /// reindex all labels in the list [listOfLabels] within
  /// [changeStart] and [changeEnd] with [value]
  static void reindexLabels(List<Label> listOfLabels, int changeStart,
      int changeEnd, int changeTableStart, int changeTableEnd, int value, bool isRow){
    if(value < 0){
      listOfLabels.forEach((Label l){
        List<Label> visitedGroupLabels = new List<Label>();
        if(!visitedGroupLabels.contains(l.groupLabel) && l.groupLabel.index > changeStart && l.groupLabel.index <= changeEnd){
          l.groupLabel.index += value;
          visitedGroupLabels.add(l.groupLabel);
        }

        if(l.tablePos > changeTableStart && l.tablePos <= changeTableEnd && l.isRow == isRow){
          l.tablePos += value;
        }
      });
    }else{
      listOfLabels.forEach((Label l){
        List<Label> visitedGroupLabels = new List<Label>();
        if(!visitedGroupLabels.contains(l.groupLabel) && l.groupLabel.index >= changeStart && l.groupLabel.index <= changeEnd){
          l.groupLabel.index += value;
          visitedGroupLabels.add(l.groupLabel);
        }

        if(l.tablePos >= changeTableStart && l.tablePos <= changeTableEnd && l.isRow == isRow){
          l.tablePos += value;
        }
      });
    }
  }

  static Map<String, int> getGroupLabelsIndices(String ID){
    var retVal = new Map<String, int>();

    List<Label> helperList = groupLabels[ID].values.toList()..sort((Label a, Label b){
      return a.index - b.index;
    });

    for(Label groupLabel in helperList){
      retVal[groupLabel.name] = groupLabel.index;
    }
    return retVal;
  }

  /// Get the name of the segment
  String get name;
  /// Set the name of the segment
  set name(String value);

  Label get groupLabel;

  /// The label which has the same name
  Label get mainLabel;
  /// Set label which has the same name
  set mainLabel(Label value);

  /// Is this label a unique label or does it has other parts
  /// If mainLabel is null then it is unique otherwise not
  bool get isPartialLabel;

  /// Gets new label from this label
  Label get generateNewLabel;

  /// Resets the value of the numberOfGeneratedLabels
  void resetLabelGenerationCounter();

  /// Get the unique identification of the segment
  String get id;
  /// Set the unique identification of the segment
  set id(String value);

  /// Get the position of the segment in the parent
  int get index;
  /// Set the position of the segment in the parent
  set index(int value);

  /// Get the position of the segment is in the row or in the column
  bool get isRow;
  /// Set the position of the segment is in the row or in the column
  set isRow(bool value);

  /// Gets the label's group number
  int get groupNumber;
  /// Sets the label's group number
  set groupNumber(int value);

  @Deprecated("Replaced by tablePos")
  int get tableCol;

  @Deprecated("Replaced by tablePos")
  set tableCol(int value);

  @Deprecated("Replaced by tablePos")
  int get tableRow;

  @Deprecated("Replaced by tablePos")
  set tableRow(int value);

  ///Get the segment position in the table
  int get tablePos;
  ///Set the segment position in the table
  set tablePos(int value);

  /// Check is this label [other] has the same name as my sibling
  bool isMyPart(Label other);

  /// Check is this label equals with the given [other] label
  @override
  bool operator ==(Object other);

  /// Simple hashCode implementation for equals
  @override
  int get hashCode;

  /// Create a map from the label
  Map toJson();

  /// Hard copy the label object
  Label copy();

  bool uniqueScale;
}