import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game.dart';

main() {
  SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  init();
  runApp(StreamBuilder(stream: updater.stream, builder: (c, s) => app()));
}

app() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: home(),
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
    bottomNavigationBar: Container(
      color: colors[5],
      height: 56,
      child: Row(
        children: [Text(txt[0])]..addAll(players.map((p) => score(p))),
      ),
    ),
    body: LayoutBuilder(
      builder: (_, con) => Stack(
            children: [menu()]..addAll(players.map((p) => playerItem(p, con))),
          ),
    ),
  );
}

menu() {
  if (me != null) return Container();
  return Positioned.fill(
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          row([button(txt[1], create), Text("  "), button(txt[2], join)])
        ],
      ),
    ),
  );
}

circle(size, color, tag) => Icon(tag ? Icons.radio_button_checked : Icons.lens,
    size: size / 1, color: color);

playerItem(Player p, BoxConstraints con) {
  return Positioned(
    left: con.maxWidth * p.x / 143 - 16,
    top: con.maxHeight * p.y / 255 - 16,
    child: circle(p.score == 0 ? 0 : 32, colors[p.id], p.isTag),
  );
}

score(Player p) =>
    row([circle(16, colors[p.id], p.isTag), Text(" ${p.score}      ")]);

button(String title, VoidCallback onTap) {
  return FlatButton(onPressed: onTap, color: colors[0], child: Text(title));
}

row(List<Widget> children) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: children);
