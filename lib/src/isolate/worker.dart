part of IsolateManager;

enum WorkerStatus{
  INITIALIZED,
  WORKING,
  WORK_DONE,
  ERROR
}

class Worker{
  String path;
  Communication channel;
  Isolate _isolate;
  Uri isolateUri;
  Map<String, dynamic> message;
  List<String> args;
  WorkerStatus status = WorkerStatus.INITIALIZED;

  Worker(this.path, Function listener, Completer isolateReady, [List<String> this.args, Map<String, dynamic> this.message]){
    channel = new Communication();

    this.isolateUri = new Uri(path: this.path);
    if(this.args == null) this.args = new List<String>();
    if(this.message == null) this.message = new Map<String, dynamic>();

    this.message["sendPort"] = this.channel.receive.sendPort;
    this.message["status"] = this.status.index;

    Isolate.spawnUri(this.isolateUri, args, message).then((Isolate result){
      this._isolate = result;
      isolateReady.complete(this);
    });

    channel.waitForHandshake().then((bool success){
      if(success){
        this.channel.onMessage(this.listReceivedMessages);
        this.channel.onMessage(listener);
        //this.channel.sendTo(Communication.LOGGING, "Worker: Handshake was succedfull");
      }else{
        new StateError("Channel handshake was unsuccesfull");
      }
    });
  }

  dynamic getResult() async{
    this.channel.sendTo(Communication.WORK);
    Completer<dynamic> completer = new Completer<dynamic>();
    this.channel.onMessage((Map<String, dynamic> message){
      if(message["command"] == Communication.RESULT){
        completer.complete(message["data"]);
      }
    });
    return await completer.future;
  }

  void listReceivedMessages(dynamic message){
    print(message);
  }

  void kill(){
    this._isolate.kill();
  }
}