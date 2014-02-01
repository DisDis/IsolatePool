part of isolate_pool;

class IsolateMessage{
  final Map<String, dynamic> message;
  final IsolateWorker source;
  IsolateMessage(this.source,this.message);
}
