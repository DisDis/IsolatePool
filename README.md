IsolatePool
===========

Dart Isolate pool implementation. Send and recived json object.

##Sample
###Main app
//test1.dart

    import 'dart:async';
    import "dart:convert";
    import 'package:isolate_pool/isolate_pool.dart';
    
    void recived(IsolateMessage msg){
      print('main << ${msg.source.id} : '+ JSON.encode(msg.message));
    }

    void main(){
      var proxy = new IsolatePool();
      
      proxy.runIsolate(Uri.parse("./test2.dart"), ["foo"])
        .then((child){
          child.stream.listen(recived);
          child.send({"field1":"main-msg-${child.id}"});
        });
      
      proxy.runIsolate(Uri.parse("./test2.dart"), ["bar"])
        .then((child){
          child.stream.listen(recived);
          child.send({"field2":"main-msg-${child.id}"});
        });
      new Timer(new Duration(seconds:5), (){
        print("end main");
        proxy.close();
      });
    }

###Worker app
//test2.dart
    
    import 'dart:isolate';
    import "dart:convert";
    import 'package:isolate_pool/isolate_pool.dart';
    
    void main(List<String> args, SendPort replyTo) {
      var mirror = new IsolateWorker.isolateInit(replyTo);
      print("start isolate ${mirror.hashCode}, arg: ${args[0]}");
      mirror.stream.listen((IsolateMessage msg){
        print('[${mirror.hashCode}] << main :'+ JSON.encode(msg.message));
        msg.source.send({"field3": "iso-msg-${mirror.hashCode}"});
      });
      mirror.send({"test1":"isolate-${mirror.hashCode}"});
    }
