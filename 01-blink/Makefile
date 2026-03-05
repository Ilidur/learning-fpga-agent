PROJ = top
DEVICE = GW1NR-LV9QN88PC6/I5
FAMILY = GW1N-9C

all: $(PROJ).fs

# Synthesis: Verilog -> JSON netlist
$(PROJ).json: $(PROJ).v
	yosys -p "read_verilog $(PROJ).v; synth_gowin -top $(PROJ) -json $@"

# Place & Route: JSON netlist -> routed JSON
$(PROJ)_pnr.json: $(PROJ).json pins.cst
	nextpnr-himbaechel --json $< \
		--write $@ \
		--device $(DEVICE) \
		--vopt family=$(FAMILY) \
		--vopt cst=pins.cst

# Bitstream: routed JSON -> .fs bitstream
$(PROJ).fs: $(PROJ)_pnr.json
	gowin_pack -d $(FAMILY) -o $@ $<

# Flash to board
flash: $(PROJ).fs
	openFPGALoader -b tangnano9k $<

# Simulation with Verilator
sim: $(PROJ).v sim_main.cpp
	verilator --cc --exe --build -j 0 $(PROJ).v sim_main.cpp
	./obj_dir/V$(PROJ)

clean:
	rm -rf $(PROJ).json $(PROJ)_pnr.json $(PROJ).fs obj_dir

.PHONY: all flash sim clean
