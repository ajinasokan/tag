import 'dart:io';
import 'dart:async';

Map<String, StreamController<String>> lobbies = {};
Map<String, int> playerCount = {};

void main() async {
  var server = await HttpServer.bind(InternetAddress.anyIPv4, 54321);
  server.listen((HttpRequest request) async {
    lobbies[request.uri.path] ??= StreamController.broadcast();
    playerCount[request.uri.path] ??= 0;
    if (playerCount[request.uri.path] >= 5) {
      request.response.close();
      return;
    }

    WebSocket websocket = await WebSocketTransformer.upgrade(request);
    playerCount[request.uri.path]++;

    var subscription =
        lobbies[request.uri.path].stream.listen((data) => websocket.add(data));

    var cleanup = () {
      subscription.cancel();
      websocket.close();
      playerCount[request.uri.path]--;
    };

    websocket.listen(
      (message) => lobbies[request.uri.path].add(message),
      onDone: cleanup,
      onError: cleanup,
    );
  });
}
