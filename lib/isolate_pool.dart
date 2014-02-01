library isolate_pool;
import 'dart:isolate';
import 'dart:async';
import "dart:convert";
part 'isolate_message.dart';
part 'isolate_worker.dart';

class IsolatePool{
  final Map<int,IsolateWorker> isolates = new Map();
  int _id = 0;
  Future<IsolateWorker> runIsolate(Uri uri, List<String> args){
    final id = _id++;
    var child = new IsolateWorker(id);
    isolates[id] = child; 
    var completer = new Completer<IsolateWorker>();
    Future<Isolate> remote = Isolate.spawnUri(uri, args, child.sendPort)
        .then((Isolate iso){
          child.isolate = iso;
          completer.complete(child);
        });
    return completer.future;
  }
  
  void close(){
    isolates.forEach((k,v){
      v.close();
    });
    isolates.clear();
  }
}
