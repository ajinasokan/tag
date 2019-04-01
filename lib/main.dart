import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi/wifi.dart';
import 'package:sensors/sensors.dart';

void main() {
  runApp(App());
  Wifi.ip.then((ip) => print(ip));
  // accelerometerEvents.listen((AccelerometerEvent event) => print(event));
}

var bigText = TextStyle(
  color: Colors.white,
  fontSize: 24,
  fontWeight: FontWeight.w500,
  decoration: TextDecoration.none,
);

var smallText = bigText.copyWith(fontSize: 16);

class Data {
  Color color;
  int score;
  Data(this.color, this.score);
}

class App extends StatelessWidget {
  final Map<int, Data> data = {
    1: Data(Colors.blue, 10),
    2: Data(Colors.red, 4),
    3: Data(Colors.purple, 2),
    4: Data(Colors.yellow, 8),
    5: Data(Colors.teal, 11),
  };

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
              child: CustomPaint(
                child: Container(color: Colors.white12),
              ),
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
