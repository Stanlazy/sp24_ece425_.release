SHELL=/bin/bash -o pipefail
.SHELLFLAGS += -e

NET_SRC := $(shell find $(PWD)/../ihnl -name "netlist")
HVL_SRC := $(PWD)/mos.sv $(PWD)/tb.sv
SRCS    := $(NET_SRC) $(HVL_SRC)

export VCS_ARCH_OVERRIDE=linux
VCS_FLAGS= -full64 -lca -sverilog +lint=all,noNS -timescale=1ns/1ns -debug_acc+all -kdb -fsdb -suppress=LCA_FEATURES_ENABLED

sim/tb: $(SRCS)
	mkdir -p sim
	sed -i -E 's/cds_globals.vss_/1'"'"'b0/g' $(NET_SRC)
	sed -i -E 's/cds_globals.vdd_/1'"'"'b1/g' $(NET_SRC)
	cd sim && vcs $(SRCS) $(VCS_FLAGS) -l compile.log -top tb -o tb

.PHONY: run
run: sim/tb
	cd sim && ./tb -l simulation.log

.PHONY: verdi
verdi:
	mkdir -p verdi
	cd verdi && $(VERDI_HOME)/bin/verdi -ssf $(PWD)/sim/dump.fsdb

.PHONY: clean
clean:
	rm -rf sim verdi
