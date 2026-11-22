# Tang Nano 1K FPGA Blueprint

This is the wiring and FPGA configuration plan for the **Sipeed Tang Nano 1K**,
not a custom FPGA chip or PCB design. The target uses the Gowin
`GW1NZ-LV1QN48C6/I5`; the hardware wrapper and pin constraints are
`rtl/tang_nano_1k_top.v` and `constraints/tang_nano_1k.cst`.

## Architecture

```text
27 MHz oscillator ──────────────────────────────────────────────────┐
                                                                    v
KEY_A reset ────────> reset polarity adapter ──┐            ┌───────────────┐
4 switches ─────────> active-low adapter ──────┼───────────>│ Digital-lock  │
3 buttons ──────────> active-low adapter ──────┘            │ FSM + code    │
                  (synchronizer/debounce)                     │ register      │
                                                              └───────┬───────┘
                                                                      v
                                                         On-board RGB LED
                                                  setup/locked/open/error/lockout
```

`tang_nano_1k_top` adapts the physical board's active-low controls and
active-low RGB LED to the generic `digital_lock_top` logic. The switch bus uses
two flip-flop synchronizers. Each button uses a synchronizer, a stable-time
filter, and a one-clock press pulse. Switches are not debounced: set them and
let them settle before pressing a button.

## Board and budget

The [Robu listing](https://robu.in/product/sipeed-tang-nano-1k-core-board-based-on-gowin/)
showed a Tang Nano 1K for **₹799** when checked on 2026-11-22. That is the
board price only. Availability, price, shipping, and included headers can
change; verify the checkout total before buying. The small project also needs:

- Four-position DIP switch (or four individual switches)
- Three momentary pushbuttons
- Breadboard or other insulated mounting, jumper wires, and a USB-C data cable
- Soldered header pins if the particular board listing does not include them

The board's RGB LED is built in, so no external indicator LEDs are required.
External switch/button inputs use the FPGA's configured internal pull-ups.
These small accessories and shipping may put the complete prototype over
₹1,000 even if the board itself is below it.

## Physical pin and wiring plan

Pins are package-pin numbers from the Sipeed pin map. The `.cst` file assigns
the pins below and sets `LVCMOS33` with pull-ups for the external controls.

| Board top-level signal | Package pin | Physical connection |
|---|---:|---|
| `xtal_27m` | 47 | On-board 27 MHz oscillator |
| `sys_rst_n` | 13 | On-board KEY_A reset, active low |
| `code_sw_n[0]` | 24 | DIP switch bit 0 to GND |
| `code_sw_n[1]` | 23 | DIP switch bit 1 to GND |
| `code_sw_n[2]` | 22 | DIP switch bit 2 to GND |
| `code_sw_n[3]` | 18 | DIP switch bit 3 to GND |
| `set_button_n` | 17 | Momentary button to GND |
| `submit_button_n` | 16 | Momentary button to GND |
| `relock_button_n` | 15 | Momentary button to GND |
| `led_r_n` | 9 | On-board RGB red channel |
| `led_b_n` | 10 | On-board RGB blue channel |
| `led_g_n` | 11 | On-board RGB green channel |

Use the board GND pin as the common ground for all external switches and
buttons. With pull-ups enabled, open switches/buttons read high and a closed
switch/button reads low. The board wrapper inverts those active-low signals;
switch ON therefore represents logic `1`. Do not connect any input to 5 V:
the FPGA bank is 3.3 V.

### Status colors

The onboard RGB LED is active low and shows:

| Color | Meaning |
|---|---|
| Yellow | Setup; no code has been set since reset |
| Red | Normal locked state |
| Green | Unlocked |
| Blue | Wrong-code indication |
| Magenta | Lockout after the third wrong entry |

The wrong-code indicator is sticky, so blue stays on until success, relock,
code change, reset, or lockout.

## Build and program

1. Install Gowin EDA and the programmer recommended by Sipeed for Tang Nano 1K.
2. Open `programmable_digital_lock.gprj`.
3. Confirm the device is `GW1NZ-LV1QN48C6/I5`, select `tang_nano_1k_top` as
   the top module, and confirm `constraints/tang_nano_1k.cst` is active.
4. The board wrapper sets `FILTER_CYCLES=135000`, which is about 5 ms at
   27 MHz.
5. Run Gowin synthesis and place-and-route. Inspect the warnings and pin
   assignment report; resolve any tool or board-revision differences before
   generating a bitstream.
6. Connect only the low-voltage switches/buttons. Program via the board's
   onboard USB-JTAG connection.
7. Press KEY_A to reset, set a code on the DIP switch, and test the flow in
   the README.

The source project includes a Gowin `.gprj` and `.cst`, but this environment
does not include the proprietary Gowin tools or a physical Tang Nano 1K. Thus,
the exact vendor-tool bitstream and physical operation remain unverified. Run
the local `make verify` checks before using the board.

## Safety and scope

This is a low-voltage LED/switch prototype, not a practical door lock. There is
no solenoid/relay driver, power stage, custom PCB, or isolation design. Never
connect an actuator directly to an FPGA pin. A future actuator demonstration
would require an appropriately rated driver, protection circuitry, and a
separate supply.

## References

- [Sipeed Tang Nano 1K hardware documentation and pin map](https://github.com/sipeed/sipeed_wiki/blob/main/docs/hardware/en/tang/Tang-Nano-1K/Nano-1k.md)
- [Official Sipeed Tang Nano 1K examples](https://github.com/sipeed/TangNano-1K-examples)
- [Robu product listing](https://robu.in/product/sipeed-tang-nano-1k-core-board-based-on-gowin/)
