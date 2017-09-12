part of dataProcessing;

abstract class SortInfoData{
  VisualObject rootElement;

  void clean();

  bool isConnected(VisualObject A, VisualObject B);

  SortDataSearchAlgorithm copy();
}