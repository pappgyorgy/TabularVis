library IsolateManager;

import 'dart:async';
import 'dart:isolate';

part 'worker.dart';
part 'communication.dart';

enum IsolateTypes{
  DATA_PROCESS,
  DIAGRAM_MANAGER,
  GEOMETRY
}

class IsolateManager{
  Map<int, Worker> _workers = {};
  int numberOfWorkers = 0;

  IsolateManager();

  Future<Worker> getWorker(Function listener, [IsolateTypes type = IsolateTypes.GEOMETRY, bool newWorker = false]){
    if(newWorker || numberOfWorkers < 1){
      Completer<Worker> isolateReady = new Completer<Worker>();

      new Worker(getPathByType(type), listener, isolateReady);

      return isolateReady.future;
    }else{
      return new Future.value(this._workers[type]);
    }
  }

  Worker findAvailableWorker(){
    for(var i = 0; i < this.numberOfWorkers; i++){
      if(this._workers[i].status == WorkerStatus.WORK_DONE){
        return this._workers[i];
      }
    }
    return this._workers[0];
  }

  String getPathByType(IsolateTypes type){
    switch(type){
      case IsolateTypes.DATA_PROCESS:
        return "/beziersimpleconnectviewer/lib/src/data/data_matrix.dart";
      case IsolateTypes.DIAGRAM_MANAGER:
        return "/dart_web_worker/web/test.dart";
      case IsolateTypes.GEOMETRY:
        return "/dart_web_worker/web/test.dart";
      default:
        throw new StateError("This Isolate type $type is not exists");
    }
    
  }

}