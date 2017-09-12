part of dataProcessing;

/// This class manage and store all the connections
///
/// Actions you can take: remove, add, check existence, update
class ConnectionManager{

  static VisConnection createNewConnection(VisualObject elementOne, VisualObject elementTwo,
      String diagramID){
    var newConn = new ConnectionVis(elementOne, elementTwo, "connection: ${elementOne.id}/${elementTwo.id}");
    elementOne.connection = elementTwo.connection =
      ConnectionManager.listOfConnection[diagramID][newConn.nameOfConn] = newConn;
    return newConn;
  }

  /// This double Map store all connections for all diagram
  static Map<String,Map<String,VisConnection>> listOfConnection = new Map<String, Map<String, VisConnection>>();

  /// Remove the connections which is not in the visual object hierarchy
  static void removeDeletedConnections(VisualObject objectHierarchy, List<Label> rowLabel, List<Label> colLabel) {
    List<VisConnection> connectionToRemove = new List<VisConnection>();

    List<String> allLabelID = new List<String>();
    rowLabel.forEach((Label l) => allLabelID.add(l.id));
    colLabel.forEach((Label l) => allLabelID.add(l.id));

    for(VisConnection connection in
        ConnectionManager.listOfConnection[objectHierarchy.id].values){
      if(!connection.isConnectionNeeded(objectHierarchy, allLabelID)){
        connectionToRemove.add(connection);
      }
    }
    connectionToRemove.forEach((VisConnection connection){
      ConnectionManager.listOfConnection[objectHierarchy.id]
          .remove(connection.nameOfConn);
    });
  }

  /// Check is there a connection between the two segment
  static bool isConnectionsExistBetweenTheseSegments(VisualObject objectHierarchy, Label rowLabel, Label colLabel){
    var connection = getConnection(objectHierarchy, rowLabel, colLabel);
    return connection == null ? false : true;
  }

  /// Get the connection of two segments represented by label
  static VisConnection getConnection(VisualObject objectHierarchy, Label rowLabel, Label colLabel) {
    var searchedConnID = "connection: ${rowLabel.id}/${colLabel.id}";

    return ConnectionManager.listOfConnection[objectHierarchy.id][searchedConnID];
  }

  /// update the colors of the connections
  static void updateConnectionsColors(VisualObject objectHierarchy){
    for(VisConnection connection in
    ConnectionManager.listOfConnection[objectHierarchy.id].values){
      connection.updateColors();
    }
  }

  /// Remove connection if it is exists in visual object hierarchy
  static void removeConnectionIfExists(VisualObject objectHierarchy, Label rowLabel, Label colLabel){
    if(isConnectionsExistBetweenTheseSegments(objectHierarchy, rowLabel, colLabel)){
      var connection = getConnection(objectHierarchy, rowLabel, colLabel);
      try {
        connection.segmentOne.parent.removeChild(
            connection.segmentOne.id);
        connection.segmentTwo.parent.removeChild(
            connection.segmentTwo.id);
      }catch(error){

      }
      ConnectionManager.listOfConnection[objectHierarchy.id].remove(connection.nameOfConn);
    }
  }

  /// Change and update the color of the segments in the given diagram [diagramID]
  static void changAndUpdateSegmentColorPool(String diagramID, bool isRandom){
    for(VisConnection connection in
    ConnectionManager.listOfConnection[diagramID].values){
      connection.modifyMainSegmentsColorFromList(isRandom);
    }
  }
}