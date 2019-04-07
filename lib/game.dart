import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:wifi_ip/wifi_ip.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter/material.dart';

var colors = [
  Colors.blue,
  Colors.red,
  Colors.purple,
  Colors.yellow,
  Colors.teal,
  Colors.grey[900]
];

var txt = [
  "      Scores      ",
  "Host game",
  "Join game",
  "How to play:\n\n👉 Try not to get tagged\n👉 No tag-backs for 2 seconds\n👉 Play with 4 or 5 players\n\n",
  "Create a hotspot to host a game\n\n",
  "Tag!",
  "You are it!",
  "You won!",
  "You lost!",
];

// setState

var updater = StreamController<int>.broadcast();
update() => updater.add(0);

// State

get now => DateTime.now().millisecondsSinceEpoch;
get random => Random().nextInt(255);

class Player {
  int id;
  var b = <int>[random, random, 5];
  get isTag => id == tag;
  get x => b[0];
  get y => b[1];
  get score => b[2];
  InternetAddress ip = InternetAddress.loopbackIPv4;
}

int port = 54321;
int xMax = 143;
int yMax = 255;
int me;
int winner = 6;
int lastTag = 0;
int lastTagTime = 0;
int tag = 0;
String title = txt[5];
String message = txt[3];
List<Player> players = [];

Player player(int id) {
  for (var i = players.length; i <= id; i++) players.add(Player());
  return players[id]..id = id;
}

// I/O

String server;
RawDatagramSocket udp;

init() async {
  udp = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 54321);
  udp.writeEventsEnabled = false;
  udp.listen(onData);

  accelerometerEvents.listen((e) {
    if (me == null || (e.x.abs() < 1 && e.y.abs() < 1)) return;
    report(e.x.toInt(), e.y.toInt());
  });
}

onData(_) {
  var dg = udp.receive(), bin = dg.data, ip = dg.address;

//  print("${ip.address} $bin");
  if (bin[0] == 0 && me != null) {
    // join request: 0
    var id = players.indexWhere((p) => p.ip == ip);
    if (id == -1) id = players.length;
    enter(id, ip);
    if (id < 6) player(id).ip = ip;
  } else if (bin[0] == 1) {
    // join response: 1, id
    me = bin[1];
    report(0, 0);
  } else if (bin[0] == 2) {
    // delta: 2, id, dx, dy
    process(bin[1], bin[2] - 127, bin[3] - 127);
  } else if (bin[0] == 3) {
    // position: 3, tag, winner, x, y, score
    tag = bin[1];
    winner = bin[2];
    for (var i = 3, id = 0; i < bin.length; i += 3, id++)
      player(id).b = bin.sublist(i, i + 3);

    title = tag == me ? txt[6] : txt[5];
    if (player(me).score == 0) title = txt[8];
    if (winner == me) title = txt[7];
  }

  update();
}

// Game logic

reset() {
  me = null;
  winner = 6;
  lastTag = 0;
  lastTagTime = 0;
  tag = 0;
  title = txt[5];
  message = txt[3];
  players = [];
  update();
}

get serverIP => InternetAddress("192.168.43.74");

create() async {
  var myIP = (await WifiIp.getWifiIp).ip;
  if (myIP != "0.0.0.0") {
    message = txt[3] + txt[4];
    update();
    return;
  }
  me = 0;
  report(0, 0);
  update();
}

join() => udp.send([0], serverIP, port);

enter(id, ip) => udp.send([1, id], ip, port);
report(dx, dy) => udp.send([2, me, dx + 127, dy + 127], serverIP, port);

dist(Player a, Player b) => sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
process(int id, int dx, int dy) {
  var p = player(id);
  p.b[0] = (p.x - dx).clamp(0, xMax);
  p.b[1] = (p.y + dy).clamp(0, yMax);

  for (var i = 0; i < players.length; i++) {
    var p = player(i);
    if (i != tag && p.score > 0 && dist(player(tag), p) < 15) {
      if (i == lastTag && now - lastTagTime < 2000) continue;

      p.b[2]--;
      if (p.score != 0) {
        lastTagTime = now;
        lastTag = tag;
        tag = i;
      }
      break;
    }
  }

  int zeros = players.where((p) => p.score == 0).length;
  int alive = players.indexWhere((p) => p.score != 0);
  if (zeros == players.length - 1 && zeros > 0) winner = alive;

  List<int> data = [3, tag, winner]..addAll(players.expand((p) => p.b));
  players.forEach((p) => udp.send(data, p.ip, port));
  update();
}
