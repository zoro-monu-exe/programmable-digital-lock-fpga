# Output Verification

This file records the checks that were actually run for this project. The
captured console output is published in `verification/make-verify.log`, the
Gowin-family mapping report is in `verification/gowin-yosys.log`, and simulation
waveforms are in `verification/waveforms/`.

## Simulation and synthesis

Run `make verify` from the project root. It runs:

- Icarus Verilog tests for the lock core, debounce logic, generic top, and
  Tang Nano 1K wrapper.
- Verilator lint.
- Generic Yosys synthesis and design checks.
- Gowin-family cell mapping with Yosys `synth_gowin`, followed by
  `check -assert`.

**Result: PASS** for the above software checks on 2026-11-22 using Icarus
Verilog 13.0, Verilator 5.052, and Yosys 0.66. The Gowin-family mapping
produced a 290-cell netlist and reported zero design-check problems. This is
not a vendor Gowin EDA build or place-and-route result.
The published Yosys log has trailing whitespace trimmed; tool messages and
design results are preserved.

To reproduce and save the console output:

```sh
make verify > verification/make-verify.log 2>&1 && cat verification/make-verify.log
```

The command above also refreshes `verification/gowin-yosys.log`. The published
VCD files are the actual waveforms emitted by the core, generic-top, and board
wrapper testbenches.

## Board budget

The Robu product listing was observed at ₹799 on 2026-11-22, but a live
automated recheck was blocked by the seller site. Current stock and checkout
price are therefore unconfirmed. Shipping and the external switches, buttons,
breadboard, and jumper wires can put the complete prototype above ₹1,000.
Confirm the current total before purchasing.

## Physical hardware

**Result: NOT RUN.** No Tang Nano 1K was connected to the environment during
verification. Gowin EDA and a board programmer were also unavailable. Therefore
there is no actual hardware-run output, bitstream, pin report, or claim of
successful operation on a physical board in this repository.

Before calling the prototype hardware-tested, use the actual board to compile
and place-and-route `tang_nano_1k_top`, inspect the generated pin/timing reports,
program it, and record observed reset, setup, correct-code, wrong-code,
lockout, and relock behavior. Do not replace this NOT RUN status with PASS
until those steps have been performed and their real output is saved here.

## Provenance

This report documents tool results, not authorship. The project README
discloses that the implementation is AI-assisted. Reviewers should be given
the exact source, commands, and limitations; no test log proves who wrote the
design.
