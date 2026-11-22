# Board constraints

`tang_nano_1k.cst` maps the project to the **Sipeed Tang Nano 1K**
(`GW1NZ-LV1QN48C6/I5`). It is not valid for other FPGA boards.

The pins were selected using the official Sipeed pin map and example constraints.
Before programming, verify the board revision and follow its manual. The four
code switches and three buttons are external; the onboard RGB LED provides the
status indication.

For another board, make a separate constraints file from that board's official
pinout and change the board wrapper as needed. Do not reuse this file.
