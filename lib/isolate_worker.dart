part of isolate_pool;

class IsolateWorker{
  final int id;
  final RawReceivePort _response = new RawReceivePort();
  final List<String> defferMsg = new List();
  SendPort _sendPort = null;
  Isolate _isolate;
  Isolate get isolate =>_isolate;
  
  StreamController<IsolateMessage> _streamController =new StreamController.broadcast();
  
  Stream<IsolateMessage> get stream => _streamController.stream;
  
  void set isolate(Isolate newValue){
    _isolate = newValue;
  }
  
  SendPort get sendPort{
    return _response.sendPort;
  }
  
  
  void _handlerMsg(msg){
    //print("[$id]<<'$msg'");
    try{
      Map<String, dynamic> msgObj = JSON.decode(msg);
      _streamController.add(new IsolateMessage(this,msgObj));
    }catch(e){
      print(e.toString());
    }
  }
  
  void _sendStr(String str){
    //print("[$id]>>'$str'");
    _sendPort.send(str);
  }
  
  void send(Map<String, dynamic> cmd){
    var str = JSON.encode(cmd);
    if (_sendPort == null){
      defferMsg.add(str);
    } else {
      _sendStr(str);
    }
  }
  void _sendDefferMsgs(){
    defferMsg.forEach((item){
      _sendStr(item);
    });
    defferMsg.clear();
  }
  
  IsolateWorker.isolateInit(SendPort sendPort):this.id=-1{
    _response.handler = _handlerMsg;
    _sendPort = sendPort;
    _sendPort.send(_response.sendPort);
  }
  
  IsolateWorker(this.id){
    _response.handler = (msg){
      if (msg is SendPort){
        _sendPort = msg;
        _response.handler = _handlerMsg;
        _sendDefferMsgs();
      }
    };
  }
  
  void close(){
    _response.close();
  }
}