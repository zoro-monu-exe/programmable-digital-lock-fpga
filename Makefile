.PHONY: sim lint synth synth-gowin verify clean

sim:
	mkdir -p build
	iverilog -g2012 -Wall -s tb_digital_lock_core -o build/tb_digital_lock \
		rtl/digital_lock_core.v sim/tb_digital_lock_core.v
	vvp build/tb_digital_lock
	iverilog -g2012 -Wall -s tb_button_debounce -o build/tb_button_debounce \
		rtl/button_debounce.v sim/tb_button_debounce.v
	vvp build/tb_button_debounce
	iverilog -g2012 -Wall -s tb_digital_lock_top -o build/tb_digital_lock_top \
		rtl/button_debounce.v rtl/digital_lock_core.v rtl/digital_lock_top.v \
		sim/tb_digital_lock_top.v
	vvp build/tb_digital_lock_top
	iverilog -g2012 -Wall -s tb_tang_nano_1k_top -o build/tb_tang_nano_1k_top \
		rtl/button_debounce.v rtl/digital_lock_core.v rtl/digital_lock_top.v \
		rtl/tang_nano_1k_top.v sim/tb_tang_nano_1k_top.v
	vvp build/tb_tang_nano_1k_top

lint:
	verilator --lint-only -Wall --top-module tang_nano_1k_top \
		rtl/button_debounce.v rtl/digital_lock_core.v rtl/digital_lock_top.v \
		rtl/tang_nano_1k_top.v

synth:
	yosys -Q -q -p 'read_verilog rtl/button_debounce.v rtl/digital_lock_core.v rtl/digital_lock_top.v rtl/tang_nano_1k_top.v; hierarchy -top tang_nano_1k_top; synth -top tang_nano_1k_top; check'

synth-gowin:
	mkdir -p verification
	yosys -Q -p 'read_verilog rtl/button_debounce.v rtl/digital_lock_core.v rtl/digital_lock_top.v rtl/tang_nano_1k_top.v; synth_gowin -top tang_nano_1k_top; check -assert; stat' > verification/gowin-yosys.log
	sed -i -E 's/[[:blank:]]+$$//' verification/gowin-yosys.log
	grep -E 'Found and reported 0 problems|=== tang_nano_1k_top ===' verification/gowin-yosys.log

verify: sim lint synth synth-gowin

clean:
	rm -rf build
