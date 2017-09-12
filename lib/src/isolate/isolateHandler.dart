import 'dart:isolate';
import 'dart:math';
import 'dart:async';

import 'isolate_manager.dart';
export 'isolate_manager.dart';

enum JobTypes{
  VisObjHierarchy,
  CreateShape
}

class Job{

  static Map<JobTypes, Job> jobPool = new Map<JobTypes, Job>();
  static void addNewJob(JobTypes jobType, Function jobToDo){
    if(jobPool.containsKey(jobType)){
      jobPool[jobType]._entryPoint = jobToDo;
      jobPool[jobType]._result = null;
    }else{
      jobPool[jobType] = new Job(jobToDo);
    }
  }

  Function _entryPoint;
  dynamic _result;

  dynamic get result{
    return this._result;
  }

  Job(this._entryPoint);

  dynamic run(List<dynamic> positionalArguments){
    _result = Function.apply(_entryPoint, positionalArguments);
    return _result;
  }
}

Communication channel;

Future<bool> isolateMain(List<dynamic> args, Map<String, dynamic> message) {

  Completer<bool> cp = new Completer();

  if(message["sendPort"] != null && message["sendPort"] is SendPort){
    channel = new Communication(message["sendPort"] as SendPort);
  }else{
    cp.complete(false);
    throw new StateError("First message has to contains a sendPort");
  }

  channel.waitForHandshake().then((bool success){
    if(success){
      channel.onMessage((dynamic message){
        print(message);
      });
      channel.sendTo(Communication.LOGGING, "Isolate: Handshake was successfull");
      cp.complete(true);
    }else{
      cp.complete(false);
      throw new StateError("Handshake was unsuccesfull");
    }
  });

  return cp.future;
}