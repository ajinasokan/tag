import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'resources.dart';
import 'logic.dart';

void main() {
  runApp(App());
  initSensors();
  initServer();
}

class DotPainter extends CustomPainter {
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
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

scoreItem(Player data) {
  return Row(
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
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      child: Text(title, style: smallText),
    ),
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

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MaterialApp(
      theme: ThemeData.dark(),
      home: Container(
        color: Color(0xff1E2127),
        child: StreamBuilder(
            stream: updater.stream,
            builder: (c, s) {
              return Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("Tag!", style: bigText),
                  ),
                  Expanded(
                    child: CustomPaint(
                      painter: DotPainter(),
                      child: Container(
                        color: Colors.white12,
                        child: myID == null ? startMenu() : Container(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text("Score", style: smallText)]
                        ..addAll(players.map((p) => scoreItem(p))),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}
