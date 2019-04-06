import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'resources.dart';
import 'logic.dart';

void main() {
  runApp(App());
  reset();
  initSensors();
  initServer();
}

class Dots extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    players.forEach((d) {
      if (d.score <= 0) return;
      var p = Paint()..color = Colors.white;
      var o = Offset(size.width * d.x / xMax, size.height * d.y / yMax);
      canvas.drawCircle(o, 16, p);
      p.color = Colors.black;
      if (d.tag == 1) canvas.drawCircle(o, 8, p);
    });
  }

  @override
  bool shouldRepaint(_) => true;
}

scoreItem(Player data) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Container(
        height: 16,
        width: 16,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
      Text(" " + data.score.toString(), style: smallText)
    ],
  );
}

button(String title, VoidCallback onTap) {
  return FlatButton(
    onPressed: onTap,
    child: Text(title, style: smallText),
  );
}

startMenu() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
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
      child: Wrap(
        direction: Axis.horizontal,
        spacing: 32,
        runSpacing: 8,
        children: [Text("Score")]..addAll(players.map((p) => scoreItem(p))),
      ),
    ),
    body: CustomPaint(
      painter: Dots(),
      child: myID == null ? startMenu() : Container(),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      theme: ThemeData.dark(),
      home: StreamBuilder(
        stream: updater.stream,
        builder: (c, s) => home(),
      ),
    );
  }
}
