import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:wifi_ip/wifi_ip.dart';
import 'package:sensors/sensors.dart';

// State

class Player {
  var b = [0, 0, 0, 5];
  get x => b[0];
  get y => b[1];
  get tag => b[2];
  get score => b[3];
  InternetAddress ip = InternetAddress.loopbackIPv4;
}

int xMax = 143;
int yMax = 255;
int myID;
Player lastTag;
String message;
List<Player> players = [];

Player player(int id) {
  for (var i = players.length; i <= id; i++) players.add(Player());
  return players[id];
}
// I/O

String server;
RawDatagramSocket udp;

initServer() async {
  udp = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 54321);
  udp.writeEventsEnabled = false;
  udp.listen(onData);
}

onData(_) {
  var dg = udp.receive(), bin = dg.data, ip = dg.address;

  print("${ip.address} $bin");
  if (bin[0] == 0 && myID != null) {
    // join request: 0
    var id = players.indexWhere((p) => p.ip == ip);
    if (id == -1) id = players.length;
    udp.send([1, id], ip, 54321);
    if (id < 6) player(id).ip = ip;
  } else if (bin[0] == 1) {
    // join response: 1, id
    myID = bin[1];
    udp.send([2, myID, 127, 127], ip, 54321);
  } else if (bin[0] == 2) {
    // delta: 2, id, dx, dy
    process(bin[1], bin[2] - 127, bin[3] - 127);
  } else if (bin[0] == 3) {
    // position: 3, x, y, tag, score
    for (var i = 1, id = (i - 1) ~/ 4; i < bin.length; i += 4)
      player(id).b = bin.sublist(i);
  }

  update();
}

initSensors() async {
  accelerometerEvents.listen((e) async {
    if (myID == null) return;
    var x = e.x.toInt(), y = e.y.toInt();
    if (x == 0 && y == 0) return;
    udp.send([2, myID, x + 127, y + 127], await serverIP, 54321);
  });
}

// Widget updations

var updater = StreamController<Null>.broadcast();
update() => updater.add(null);

// Game logic

reset() async {
  message = "";
  myID = null;
  players.clear();
  update();
}

create() async {
  var myIP = (await WifiIp.getWifiIp).ip;
  if (myIP != "0.0.0.0") {
    message = "Device need to have a hotspot to create a game.";
    update();
    return;
  }
  myID = 0;
  player(0).b[2] = 1;
  update();
}

get serverIP async => InternetAddress("192.168.43.209");

join() async => udp.send([0], await serverIP, 54321);

dist(Player a, Player b) => sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));

process(int id, int dx, int dy) {
  // print("process $id, $dx, $dy");
  if (player(id).score == 0) return;

  player(id).b[0] = (player(id).x - dx).clamp(0, xMax);
  player(id).b[1] = (player(id).y + dy).clamp(0, yMax);

  var tag = players.firstWhere((p) => p.tag == 1);

  for (var i = 0; i < players.length; i++) {
    var p = player(i);
    if (p != lastTag && p != tag && p.score > 0 && dist(tag, p) < 15) {
      p.b[3]--;
      // lastTag = tag;

      if (p.score != 0) {
        tag.b[2] = 0;
        p.b[2] = 1;
      }
      break;
    }
  }

  List<int> data = [3];
  players.forEach((p) => data.addAll(p.b));

  players.forEach((p) => udp.send(data, p.ip, 54321));
  update();
}
