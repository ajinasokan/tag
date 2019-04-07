import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game.dart';

main() {
  SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  init().then((_) => runApp(app()));
}

app() {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: StreamBuilder(stream: updater.stream, builder: (_, s) => home()),
  );
}

home() {
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: me == null ? null : colors[me],
      actions: [IconButton(icon: Icon(Icons.refresh), onPressed: reset)],
    ),
    body: LayoutBuilder(builder: (_, c) {
      return Stack(children: [menu()]..addAll(dots.map((p) => item(p, c))));
    }),
    bottomNavigationBar: Container(
      color: colors[5],
      padding: EdgeInsets.all(16),
      child: row([Text(str[0])]..addAll(dots.map((p) => score(p)))),
    ),
  );
}

menu() {
  if (me != null) return Container();
  return Positioned.fill(
    child: Center(child: col([Text(message), button(str[1], start)])),
  );
}

circle(s, c, t) =>
    Icon(t ? Icons.radio_button_checked : Icons.lens, size: s / 1, color: c);

item(p, s) {
  return Positioned(
    left: s.maxWidth * p.x / 143 - 16,
    top: s.maxHeight * p.y / 255 - 16,
    child: circle(p.score == 0 ? 0 : 32, colors[p.id], p.isTag),
  );
}

score(d) => row([circle(16, colors[d.id], d.isTag), Text(" ${d.score}    ")]);
button(t, e) => FlatButton(onPressed: e, color: colors[0], child: Text(t));
row(List<Widget> c) => Wrap(children: c);
col(List<Widget> c) => Wrap(children: c, direction: Axis.vertical);
