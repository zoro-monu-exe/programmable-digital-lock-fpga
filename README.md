# Programmable 4-Bit FPGA Digital Lock

**Folder:** `programmable-digital-lock`

An educational Verilog design for a programmable 4-bit combination lock,
including a target-specific wrapper for the Sipeed Tang Nano 1K FPGA. It
demonstrates synchronous RTL, a finite-state machine (FSM), input
synchronization, pushbutton debouncing, and self-checking simulation. It is
not a real security product.

> **Authorship:** This is a fresh, AI-assisted implementation—not source copied
> from the GitHub example discussed earlier. You should still understand it,
> make and test your own substantial change, and follow your institution's
> rules on AI disclosure before presenting it as your work. No README can
> guarantee what a reviewer will think; your understanding and evidence matter.

## What it does

1. Reset puts the design into **setup** mode.
2. Select a 4-bit value on the switches and press **Set** to save it.
3. In the **locked** state, select a value and press **Enter**.
4. A matching value enters **open**; a wrong value sets the error indicator.
5. Three wrong submissions in a row enter **lockout**. Reset is required to
   leave lockout, and reset also clears the saved code.
6. While open, press **Relock** to lock again, or press **Set** with a new
   switch value to change the code and relock.

The code is four binary bits, so it has just 16 possible values (`0000` to
`1111`). `1010` is the binary value ten; this is **not** a four-decimal-digit
keypad lock.

## State machine

| Current state | Event | Next state | Effect |
|---|---|---|---|
| Setup | Set | Locked | Save switch value as code |
| Locked | Enter, matching code | Open | Clear failed-attempt count and error |
| Locked | Enter, wrong code; attempts 1 or 2 | Locked | Latch wrong-code indicator |
| Locked | Enter, third wrong code | Lockout | Latch error; ignore normal inputs |
| Open | Relock | Locked | Keep current code; clear error |
| Open | Set | Locked | Replace code with switch value |
| Lockout | Any normal button | Lockout | Remain locked out |
| Any state | Reset asserted | Setup | Clear code, error, and attempt count |

`locked` is high only in the normal Locked state; `lockout` is a separate
output. `code_programmed` is high in Locked, Open, and Lockout. The
`wrong_code` indicator is sticky: it stays high until a successful entry,
relock, code change, or reset clears it.

## Design structure

```text
Board clock
  ├─ 2-flop synchronizers for four switches ───────────────┐
  ├─ synchronizer + debounce + one-shot pulse: Set ────────┤
  ├─ synchronizer + debounce + one-shot pulse: Enter ─────┤── Lock FSM
  └─ synchronizer + debounce + one-shot pulse: Relock ────┘
                                                            ├─ unlocked
                                                            ├─ locked
                                                            ├─ wrong_code
                                                            ├─ lockout
                                                            └─ code_programmed
```

| File | Purpose |
|---|---|
| `rtl/digital_lock_core.v` | FSM, saved code, attempt counter, status outputs |
| `rtl/button_debounce.v` | Two-flop button synchronizer, stable-level filter, one-cycle press pulse |
| `rtl/digital_lock_top.v` | FPGA top module; synchronizes code switches and instantiates the three button filters |
| `rtl/tang_nano_1k_top.v` | Tang Nano 1K wrapper; active-low I/O and RGB status colors |
| `sim/tb_digital_lock_core.v` | Checks setup, failures, lockout, correct entry, relock, and code change |
| `sim/tb_button_debounce.v` | Checks that a held press gives one pulse and a later press gives another |
| `sim/tb_digital_lock_top.v` | End-to-end simulation through switch sync, button filters, and the FSM |
| `sim/tb_tang_nano_1k_top.v` | Checks the board wrapper and active-low RGB status |
| `programmable_digital_lock.gprj` | Gowin project for the Tang Nano 1K |
| `constraints/tang_nano_1k.cst` | Tang Nano 1K package pin and I/O constraints |
| `LICENSE` | MIT License |
| `docs/FPGA_BLUEPRINT.md` | Logical I/O plan and FPGA bring-up steps |
| `docs/RESUME_GUIDE.md` | Suggested original extensions and honest resume wording |
| `constraints/README.md` | Explains why pin constraints need the exact board |

### Main inputs and outputs

| Signal | Direction | Meaning |
|---|---|---|
| `clk` | Input | Board clock |
| `rst` | Input | Synchronous, active-high reset |
| `code_switches[3:0]` | Input | Value to set or submit |
| `set_code_button` | Input | Set initial code; while open, set a replacement |
| `submit_button` | Input | Compare switches against saved code while locked |
| `relock_button` | Input | Relock while open |
| `code_programmed` | Output | A code has been set since reset |
| `unlocked` | Output | Lock is in Open state |
| `locked` | Output | Lock is in normal Locked state |
| `wrong_code` | Output | Sticky wrong-submission indicator |
| `lockout` | Output | Three wrong submissions reached |

The generic top-level button filters default to `FILTER_CYCLES=500000`, about
5 ms with a 100 MHz clock. The Tang Nano 1K wrapper uses `135000` cycles,
about 5 ms at its 27 MHz oscillator. In general choose approximately
`FILTER_CYCLES = clock_frequency_hz * debounce_seconds`. The project assumes
switches are set and allowed to settle before pressing a button; they are
synchronized but not debounced.

## Run and inspect the simulations

Requirements: Icarus Verilog (`iverilog` and `vvp`). From this folder:

```sh
make sim
```

Expected output includes:

```text
PASS: all digital-lock checks passed
PASS: button debounce checks passed
PASS: end-to-end top-level checks passed
PASS: Tang Nano 1K wrapper checks passed
```

The tests write VCD files under `build/`; open them with GTKWave to inspect the
clock, inputs, state-derived outputs, errors, lockout, and LED colors. The
simulations cover the logic and board wrapper, but not Gowin place-and-route,
the physical pin soldering, or actual hardware.

For the full local checks, install Icarus Verilog, Verilator, and a Yosys build
that includes `synth_gowin`, then run:

```sh
make verify
```

This runs all simulations, Verilator lint, generic Yosys synthesis/check, and
Gowin-family cell mapping/check with Yosys `synth_gowin`. That mapping is not a
Gowin EDA compile, place-and-route, bitstream, or board timing report. The
captured test output is in [OUTPUT_VERIFICATION.md](OUTPUT_VERIFICATION.md)
and `verification/`; `make synth-gowin` refreshes its detailed mapping log.

## FPGA prototype blueprint

The selected target is **Sipeed Tang Nano 1K**, with Gowin GW1NZ-LV1 FPGA
(`GW1NZ-LV1QN48C6/I5`). Use `tang_nano_1k_top` as the hardware top. The
project includes `programmable_digital_lock.gprj` and
`constraints/tang_nano_1k.cst`.

| Top-level board signal | Tang Nano 1K connection |
|---|---|
| `xtal_27m` | On-board 27 MHz oscillator, package pin 47 |
| `sys_rst_n` | On-board KEY_A reset, active low, package pin 13 |
| `code_sw_n[3:0]` | Four external switches, pins 24, 23, 22, 18 |
| `set_button_n` | External pushbutton, pin 17 |
| `submit_button_n` | External pushbutton, pin 16 |
| `relock_button_n` | External pushbutton, pin 15 |
| `led_r_n`, `led_b_n`, `led_g_n` | On-board active-low RGB LED, pins 9, 10, 11 |

Connect each external switch/button between its signal and board GND; the
constraints enable internal pull-ups. The board uses 3.3 V I/O—never apply 5 V
to these pins. The RGB LED colors are setup yellow, locked red, unlocked green,
wrong-code blue, and lockout magenta.

The [Robu listing](https://robu.in/product/sipeed-tang-nano-1k-core-board-based-on-gowin/)
showed the Tang Nano 1K at ₹799 when checked on 2026-11-22. Price, stock,
shipping, and included headers can change; confirm the checkout total. The
four switches, three buttons, breadboard, and jumper wires are additional
items and may take the total above ₹1,000.

For board bring-up, install Gowin EDA and the Sipeed-recommended programmer,
open `programmable_digital_lock.gprj`, select `tang_nano_1k_top`, run Gowin
synthesis and place-and-route, inspect the pin report, and then program the
board over USB-JTAG. See [docs/FPGA_BLUEPRINT.md](docs/FPGA_BLUEPRINT.md) for
the pin plan and steps. A custom PCB is not part of this project.

For a first physical demo, use only switches, pushbuttons, and LEDs. FPGA pins
cannot power a solenoid or door strike. Any actuator would need a correctly
designed driver, protection components, and a separate rated supply; this
project does not provide that circuit.

## Advantages

- Small enough to understand as a second-year digital-design project.
- Shows a useful FSM rather than only a combinational password comparator.
- Supports initial code programming and code changes after unlocking.
- Demonstrates synchronizing asynchronous inputs and debouncing buttons.
- Includes lockout behavior and self-checking simulations.
- Uses portable Verilog and no vendor-specific IP in the RTL.
- Includes a board wrapper and pin constraints for the selected Tang Nano 1K.

## Limitations and security caveats

- **Only 16 codes:** a 4-bit value is trivial to guess and is not secure.
- **Volatile code:** the password is held in flip-flops. Reset or power loss
  erases it and returns the device to setup.
- **Reset bypasses lockout:** reset clears the failed-attempt count and permits
  choosing a new code. This is intentional for an educational prototype, not
  suitable for securing property.
- **No persistent storage or cryptography:** there is no nonvolatile memory,
  protected key storage, encryption, or tamper resistance.
- **No timeout:** the open state stays open until Relock, Set, or reset.
- **Switches are synchronized, not debounced:** keep them stable before
  pressing Set/Enter. A keypad interface would need its own scanning and
  debounce logic.
- **Reset conditioning is board-dependent:** `rst` is synchronous and
  active-high in this RTL. A board's reset may be active-low or asynchronous;
  adapt it using the board documentation.
- **Lockout has no timed recovery:** it stays active until reset.
- **No keypad, actuator, or custom PCB** is included. Physical switches and
  buttons must be wired to the documented pins.
- **No physical validation, Gowin bitstream, or target-specific timing/resource
  report** exists. Generic simulation/lint is not proof of working on the board.
- The testbench covers the complete RTL wrapper behavior but cannot validate
  pin soldering, board revision, programmer setup, or electrical hardware.

These are good extension opportunities: add a cooldown instead of reset-only
recovery, timed auto-relock, a keypad, a longer sequence, persistent code
storage, or board-specific display/constraints. Do not call these features
implemented until you build and test them.

## Common project-defense questions

**What does “4-bit programmable” mean?**

The four switch bits represent a binary code. The Set event stores that value
in a 4-bit register. It can be changed only while the lock is open.

**Why use an FSM?**

The behavior depends on which phase the lock is in—Setup, Locked, Open, or
Lockout. A state register makes legal transitions and output behavior explicit.

**Why are the status outputs Moore-style?**

`locked`, `unlocked`, `lockout`, and `code_programmed` are decoded from the
registered state. `wrong_code` is a separate sticky register so the error
remains visible after the one-cycle submit event.

**How does the three-try limit work?**

`failed_attempts` starts at zero. The first and second wrong submissions
increment it. When it is already two on the next wrong submission, the FSM
enters Lockout. A correct submission clears it.

**Why debounce buttons?**

Mechanical contacts can produce multiple rapid transitions for one press.
The synchronizer reduces metastability risk; the filter waits for the sampled
level to stay changed for the configured number of clock cycles. A stable
press produces one clock-wide pulse.

**How long is the default debounce interval?**

At 100 MHz, 500,000 cycles is 5 ms (`500000 / 100000000`). At another clock
frequency, change `FILTER_CYCLES`.

**Why use one clock instead of making button clocks?**

Buttons are treated as data and converted into one-cycle enables. Keeping all
state changes on `clk` avoids unsafe, irregular gated clocks.

**What happens if reset is pressed?**

On a rising clock edge while `rst` is high, the design clears the saved code,
attempt count, and error indicator, and returns to Setup.

**How was it verified?**

`make verify` runs four Icarus simulations, Verilator lint, generic Yosys
synthesis/check, and Gowin-family cell mapping/check. VCD files are generated
for waveform inspection. See [OUTPUT_VERIFICATION.md](OUTPUT_VERIFICATION.md)
for the captured results and the hardware tests that remain outstanding.

**Is this a secure real-world lock?**

No. The code space is tiny, reset allows reprogramming, storage is volatile,
and no physical actuator interface or tamper protection exists. It is a
digital-design demonstration only.

## Resume and originality

Do not claim PCB design, hardware testing, FPGA resource usage, or timing
results unless you actually completed and recorded that work. To make the
project genuinely yours, first run and understand the tests, then implement a
meaningful extension and add a test for it. Keep your real source history and
evidence; do not fabricate commits, measurements, or authorship.

An honest starting description (simulation only) is in
[`docs/RESUME_GUIDE.md`](docs/RESUME_GUIDE.md). Update it to describe the parts
you personally changed and verified, and disclose AI assistance as required by
your school or employer.
