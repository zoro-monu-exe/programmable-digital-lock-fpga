# Make this project genuinely yours

The starter design is AI-assisted and is not evidence that you personally
implemented or tested the design. Before putting it on a resume:

1. Explain every state and signal in `digital_lock_core.v` without relying on
   this document.
2. Run `make sim` yourself and inspect the VCD in GTKWave.
3. Make and test at least one meaningful change. Ideas:
   - Add a timed relock after a configurable number of clock cycles.
   - Add a cooldown timer after lockout rather than requiring reset.
   - Add a seven-segment display for the current state or attempt count.
   - Expand from a 4-bit code to a multi-digit sequence.
4. If you buy or borrow a Tang Nano 1K, use the included wrapper and
   constraints, program it, record what you actually observed, and include a
   photo or short demo video. Do not claim physical validation before doing it.
5. Keep simulation, synthesis, and physical-hardware results distinct. Do not
   claim board testing, PCB design, or timing/resource results unless you
   actually performed and recorded them.
6. Follow your institution's rules for disclosing AI assistance.

## Honest resume wording after simulation only

> Built an AI-assisted Verilog FPGA learning project for a programmable 4-bit
> digital lock targeting the Sipeed Tang Nano 1K. Implemented setup/change-code,
> unlock/relock, debounce, and three-attempt lockout behavior; verified the
> core and board wrapper in Icarus Verilog and ran generic RTL lint/synthesis
> checks. Physical FPGA testing was not performed.

Replace this wording with your own description after making and testing your
own changes. Add Gowin or physical-board results only after collecting them.
