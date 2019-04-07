import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:wifi_access/wifi_access.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

var colors, str, updater = StreamController<int>.broadcast(), server;
get update => updater.add(0);

get now => DateTime.now().millisecondsSinceEpoch;
get rnd => Random().nextInt(255);

class Dot {
  int id;
  var b = <int>[rnd, rnd, 5];
  get isTag => id == tag;
  get x => b[0];
  get y => b[1];
  get score => b[2];
  InternetAddress ip = InternetAddress.loopbackIPv4;
}

int port = 54321, xMax = 143, yMax = 255;
int me;
int winner = 6, lastTag = 0, tag = 0, lastTagTime = 0;
String title = str[5], message = str[3];
List<Dot> dots = [];

Dot dot(int id) {
  for (var i = dots.length; i <= id; i++) dots.add(Dot());
  return dots[id]..id = id;
}

RawDatagramSocket udp;

Future init() async {
  var res = json.decode(await rootBundle.loadString("assets/res.json"));
  str = res["txt"];
  colors = res["colors"].map((c) => Color(c)).toList();

  udp = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 54321);
  udp.writeEventsEnabled = false;
  udp.listen(onData);

  accelerometerEvents.listen((e) {
    if (me == null || (e.x.abs() < 1 && e.y.abs() < 1)) return;
    report(e.x.toInt(), e.y.toInt());
  });
}

onData(_) {
  var dg = udp.receive(), b = dg.data, ip = dg.address;

  if (b[0] == 0 && me != null) {
    var id = dots.indexWhere((p) => p.ip == ip);
    if (id == -1) id = dots.length;
    enter(id, ip);
    if (id < 6) dot(id).ip = ip;
  } else if (b[0] == 1) {
    me = b[1];
    report(0, 0);
  } else if (b[0] == 2 && me != null) {
    process(b[1], b[2] - 127, b[3] - 127);
  } else if (b[0] == 3) {
    tag = b[1];
    winner = b[2];
    for (var i = 3, id = 0; i < b.length; i += 3, id++)
      dot(id).b = b.sublist(i, i + 3);

    title = tag == me ? str[6] : str[5];
    if (dot(me).score == 0) title = str[8];
    if (winner == me) title = str[7];
  }

  update;
}

reset() async {
  me = null;
  winner = 6;
  lastTag = 0;
  lastTagTime = 0;
  tag = 0;
  title = str[5];
  message = str[3];
  dots = [];
  update;
}

start() async {
  var myIP = (await WifiAccess.dhcp).ip;
  if (myIP == "0.0.0.0") {
    me = 0;
    server = InternetAddress("127.0.0.1");
    report(0, 0);
  } else {
    server = InternetAddress((await WifiAccess.dhcp).gateway);
    udp.send([0], server, port);
  }
  update;
}

enter(id, ip) => udp.send([1, id], ip, port);
report(dx, dy) => udp.send([2, me, dx + 127, dy + 127], server, port);

dist(Dot a, Dot b) => sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
process(int id, int dx, int dy) {
  var t = dot(id);
  t.b[0] = (t.x - dx).clamp(0, xMax);
  t.b[1] = (t.y + dy).clamp(0, yMax);

  for (var i = 0; i < dots.length; i++) {
    var p = dot(i);
    if (i != tag && p.score > 0 && dist(dot(tag), p) < 15) {
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

  int zeros = dots.where((d) => d.score == 0).length;
  int alive = dots.indexWhere((d) => d.score != 0);
  if (zeros == dots.length - 1 && zeros > 0) winner = alive;

  List<int> data = [3, tag, winner]..addAll(dots.expand((d) => d.b));
  dots.forEach((d) => udp.send(data, d.ip, port));
  update;
}
