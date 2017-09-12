part of IsolateManager;

class Communication{

  static const WORK = 1;
  static const LOGGING = 2;
  static const GET_STATUS = 3;
  static const RESULT = 4;
  static const HANDSHAKE = 5;

  ///Receive information from the Isolate
  ReceivePort _receive;

  ///Send information to the Isolate
  SendPort _send;

  Completer<bool> isChannelReady = new Completer<bool>();

  Completer<dynamic> _firstResponse = new Completer<dynamic>();
  bool _isFirstResponse = true;

  List<Function> listeners = new List<Function>();

  Communication([SendPort sendPort]){
    this._receive = new ReceivePort();
    this._receive.listen((dynamic message){
      if(this._isFirstResponse){
        this._firstResponse.complete(message);
        this._isFirstResponse = false;
      }else{
        this.listeners.forEach((Function f){
          Function.apply(f, <dynamic>[message]);
        });
      }
    });
    this._send = sendPort;
  }

  ReceivePort get receive => _receive;

  SendPort get send => _send;

  set send(SendPort value) {
    _send = value;
  }

  Future sendTo(int command, [dynamic message = ""])async{
    if(await this.isChannelReady.future){
      send.send(<String, dynamic>{"command": command, "data": message});
    }
  }

  void onMessage(Function listen){
    this.listeners.add(listen);
  }

  Future<dynamic> getFirstResponseFromIsolate(){
    return this._firstResponse.future;
  }

  Future<bool> waitForHandshake() async{
    //print("waitForHandshake");
    if(this._send == null){
      dynamic firstMessage = await this.getFirstResponseFromIsolate();
      //print(firstMessage);
      Completer<bool> cp = new Completer();
      if(firstMessage != null && firstMessage["command"] == Communication.HANDSHAKE){
        this._send = firstMessage["data"] as SendPort;
        send.send({"command": Communication.HANDSHAKE, "data": this._send is SendPort});
        this.isChannelReady.complete(true);
        return new Future.value(true);
      }else{
        this.isChannelReady.complete(false);
        return new Future.value(false);
      }
    }else{
      send.send({"command": Communication.HANDSHAKE, "data": this._receive.sendPort});
      dynamic firstMessage = await this.getFirstResponseFromIsolate();
      //print(firstMessage);
      if(firstMessage["command"] == Communication.HANDSHAKE){
        bool result = firstMessage["data"] as bool;
        this.isChannelReady.complete(result);
        return new Future.value(result);
      }else{
        this.isChannelReady.complete(false);
        return new Future.value(false);
      }
    }
  }
}