import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi/wifi.dart';
import 'package:sensors/sensors.dart';
import 'res.dart';

final updater = StreamController<Null>.broadcast();

void main() {
  runApp(App());
  Wifi.ip.then((ip) => print(ip));
  accelerometerEvents.listen((AccelerometerEvent event) {
    data[1].zombie = true;
    data[1].live = true;
    data[1].x = (data[1].x - event.x / 200).clamp(0.0, 1.0);
    data[1].y = (data[1].y + event.y / 200).clamp(0.0, 1.0);
    updater.add(null);
  });
}

class DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    data.forEach((id, d) {
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
  scoreItem(Data data) {
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
    data.values.forEach((d) => scores.add(scoreItem(d)));

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
