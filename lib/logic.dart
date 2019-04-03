import 'dart:io';
import 'dart:async';
import 'package:wifi/wifi.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter/material.dart';

var colors = [
  Colors.blue,
  Colors.red,
  Colors.purple,
  Colors.yellow,
  Colors.teal
];

// State

class Player {
  Color color;
  int score = 0;
  int x = 0, y = 0;
  bool zombie = false, live = false;
  InternetAddress address;
  Player(this.color, this.score);
}

int myID;
int lastTagged;
Map<int, Player> players = {
  1: Player(Colors.blue, 5),
  2: Player(Colors.red, 5),
  3: Player(Colors.purple, 5),
  4: Player(Colors.yellow, 5),
  5: Player(Colors.teal, 5),
};

// I/O

RawDatagramSocket udp;

initServer() async {
  udp = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 54321);
  udp.writeEventsEnabled = false;
  udp.listen(onData);
}

onData(_) {
  var dg = udp.receive();
  var data = dg.data;
  var addr = dg.address;
  print("${addr.address} $data");
  if (data[0] == 0) {
    // join request
    var id = players.values.length + 1;
    udp.send([1, id], addr, 54321);
    if (id < 6) {
      players[id].live = true;
      players[id].address = addr;
    }
  } else if (data[0] == 1) {
    // join response 1, id
    myID = data[1];
  } else if (data[0] == 2) {
    // position update 2, id, x, y
    updatePosition(data[1], data[2], data[3]);
  }
}

initSensors() async {
  accelerometerEvents.listen((e) {
    if (myID == null) return;
    updatePosition(
      myID,
      (players[myID].x - e.x * 10).clamp(0, 255),
      (players[myID].y + e.y * 10).clamp(0, 255),
    );
  });
}

// Widget updations

final updater = StreamController<Null>.broadcast();

// Game logic

createGame() async {
  var myIP = await Wifi.ip;
  if (!myIP.endsWith(".1")) {
    // show error
    return;
  }
  myID = 1;
}

get serverIP async => (await Wifi.ip).split(".").sublist(0, 2).join(".") + ".1";

joinGame() async {
  udp.send([0], InternetAddress(serverIP), 54321);
}

updatePosition(int id, int x, int y) async {
  players[id].x = x;
  players[id].y = y;
  // send to everyone else
  players.forEach((pID, p) {
    if (id != myID && id != pID) udp.send([2, id, x, y], p.address, 54321);
  });
}
