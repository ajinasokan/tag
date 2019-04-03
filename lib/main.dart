import 'package:flutter/material.dart';
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
    players.forEach((id, d) {
      if (!d.live) return;
      var p = Paint()..color = d.color;
      var o = Offset(size.width * d.x, size.height * d.y);
      canvas.drawCircle(o, 16, p);
      p.color = Colors.black;
      if (d.zombie) canvas.drawCircle(o, 8, p);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class App extends StatelessWidget {
  scoreItem(Player data) {
    return Row(
      children: <Widget>[
        Container(
          height: 16,
          width: 16,
          decoration: BoxDecoration(
            color: data.color,
            shape: BoxShape.circle,
          ),
        ),
        Text(" " + data.score.toString(), style: smallText)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var scores = <Widget>[Text("Score", style: smallText)];
    players.values.forEach((d) => scores.add(scoreItem(d)));

    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Container(
        color: Color(0xff1E2127),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16),
              child: Text("Tag!", style: bigText),
            ),
            Expanded(
              child: StreamBuilder<Object>(
                  stream: updater.stream,
                  builder: (context, snapshot) {
                    return CustomPaint(
                      painter: DotPainter(),
                      child: Container(color: Colors.white12),
                    );
                  }),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: scores,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
