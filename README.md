# init

make udp server
init sensors
show create game, join game, description

# create game

-   get wifi ip
-   if not wifi hotspot show err
-   set mode as server
-   show game screen, with joined players count, default scores
-   show restart button

# join game

-   get wifi ip
-   get server ip
-   connect with server

# comms

-   join request = 0
-   join response = 1, 2 (index of player in array 1 - 5, 6 means full)
-   position update = 2, x, y (0 to 1 double values)

```
server                      client
                    <-      0
1, 5                ->
                    <-      2, 5, 0.545, 0.232
2, 3, 0.234, 0.576  ->
```
