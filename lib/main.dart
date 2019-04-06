import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'resources.dart';
import 'logic.dart';

void main() {
  SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  reset();
  initSensors();
  initServer();
  runApp(app());
}

scoreItem(Player data) {
  return Row(
    children: <Widget>[
      Icon(Icons.lens, size: 16),
      Text(" " + data.score.toString(), style: smallText)
    ],
  );
}

playerItem(Player d, BoxConstraints con) {
  return Positioned(
    left: con.maxWidth * d.x / xMax - 16,
    top: con.maxHeight * d.y / yMax - 16,
    child: Icon(Icons.lens, size: 32),
  );
}

button(String title, VoidCallback onTap) {
  return FlatButton(onPressed: onTap, child: Text(title, style: smallText));
}

startMenu() {
  if (myID != null) return Container();
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        message != null ? Text(message, style: smallText) : Container(),
        button("Host game", create),
        button("Join game", join),
      ],
    ),
  );
}

home() {
  return Scaffold(
    appBar: AppBar(title: Text("Tag!"), elevation: 0, centerTitle: true),
    bottomNavigationBar: Container(
      color: Colors.black,
      padding: EdgeInsets.all(16),
      child: Row(
        children: [Text("Score   ")]..addAll(players.map((p) => scoreItem(p))),
      ),
    ),
    body: LayoutBuilder(builder: (_, con) {
      return Stack(
        children: [Positioned.fill(child: startMenu())]
          ..addAll(players.map((p) => playerItem(p, con))),
      );
    }),
  );
}

app() {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: StreamBuilder(
      stream: updater.stream,
      builder: (c, s) => home(),
    ),
  );
}
