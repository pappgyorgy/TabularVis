part of dataProcessing;

/// Abstract class to handle all kind of input data
abstract class InputData{

   // The diagrams ID of the diagram which this matrix belongs
   String diagramDataID = "defaultID";

   /// Get a hierarchy data structure from the input data
   ///
   /// The given [ID] will be the unique identification of the diagram
   VisualObject getVisualizationObjectHierarchy([bool newlyGenerated = true]);

   /// Get data structure for sorting the segments
   SortDataSearchAlgorithm getInformationForConnectionSort();

   /// Get a matrix to show the data on the UI
   List<List> getDataForUI();

   /// Fill the input data with random values
   ///
   /// Only optional settings [randomZeroes] : is zero a valid value
   /// [max] and [min] is the boundaries of the random value generation
   void fillWithRandomData([bool randomZeroes = false, dynamic max = 99, dynamic min = 1]);

   /// clear the input value with the optionally given [clearValue] default = 0
   void clearData([dynamic clearValue = 0]);

   InputData copy();
}