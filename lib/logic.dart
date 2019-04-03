import 'dart:io';
import 'dart:async';
import 'package:wifi/wifi.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter/material.dart';

// State

class Player {
  Color color;
  int score = 0;
  double x = 0, y = 0;
  bool zombie = false, live = false;
  String address;
  Player(this.color, this.score);
}

String serverIP;
int playerID;
int lastTagged;
Map<int, Player> players;

// I/O

RawDatagramSocket udp;

initServer() async {
  udp = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 54321);
  udp.writeEventsEnabled = false;
  udp.listen((_) {
    var dg = udp.receive();
    dg.data.forEach((x) => print(x));
  });
  // server.send([0], new InternetAddress('172.16.32.73'), 54321);
}

initSensors() async {
  accelerometerEvents.listen((e) {
    if (playerID == null) return;
    updatePosition(
      playerID,
      (players[playerID].x - e.x / 200).clamp(0.0, 1.0),
      (players[playerID].y + e.y / 200).clamp(0.0, 1.0),
    );
  });
}

// Widget updations

final updater = StreamController<Null>.broadcast();

// Game logic

createGame() async {
  var ip = await Wifi.ip;
  if (!ip.endsWith(".1")) {
    // show error
    return;
  }
  serverIP = null;
  playerID = 1;
  players = {
    1: Player(Colors.blue, 5),
    // 2: Player(Colors.red, 4),
    // 3: Player(Colors.purple, 2),
    // 4: Player(Colors.yellow, 8),
    // 5: Player(Colors.teal, 11),
  };
}

joinGame() async {
  serverIP = (await Wifi.ip).split(".").sublist(0, 2).join(".") + ".1";
}

updatePosition(int id, double x, double y) async {
  players[id].x = x;
  players[id].y = y;
  updater.add(null);
}
