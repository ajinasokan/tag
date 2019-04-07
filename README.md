# Tag!

This is a digital version of the classic tag game. It is available only for Android at the moment. Because I don't have an iOS devices to work on. This is a WiFi multiplayer game and require a minimum of 4 players to effectiveness. There is a limit of 5 players in a game as well. 

One person can create a WiFi hotspot and start the game. Others can join this hotspot and click on Start to join. Move your phone to move the dot that represents you. Your color will match the header. Host will be the player that is tagged in the beginning. When tagged player touches other player, the other player becomes the 'it'. Tagging back will not work because there is a freeze time of 2 seconds. 

Every time you get tagged you will lose 1 point. The person with most number of points at the end wins the game.

# How it works

Game creates a UDP server for each player. Allocating a player as host or a participant is based on the IP address. If player creates hotspot then its IP is `0.0.0.0` . Otherwise player will have proper IP and it will connect to the host using its gateway IP. 

Host acts as the game controller. Every player has accelerometer setup and all movements are reported to host and host decides the next state of the game.

Throughout the game the following packets are communicated between players:

To join a game: `[0]`

After successful join: `[1, player id]`

If join was unsuccessful id will be 6

If there is a movement: `[2, player id, dx, dy]`

Since array is of bytes dx and dy will have 127 added to it to transfer -ve values.

If there is a state change in game:

`[3, tag id, winner id, player1 x, player1 y, player1 score, player2 x....]`

# Under 5KB

- All temporary variables, loop variables etc. are one characters.
- Single line variable declarations
- Types are removed from wherever Dart's implicit type checks kicks in
- Functional widget declarations everywhere
- StreamController is used for re rendering the screen
- Strings and colors are stored in a JSON