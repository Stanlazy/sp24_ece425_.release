SHELL=/bin/bash -o pipefail
.SHELLFLAGS += -e

HDL_SRCS := $(shell find $(PWD)/../hdl -name '*.sv')
HVL_SRCS := $(shell find $(PWD)/../hvl -name '*.sv' -o -name '*.v')
SRCS := $(HDL_SRCS) $(HVL_SRCS)

export VCS_ARCH_OVERRIDE=linux
VCS_FLAGS= -full64 -lca -sverilog +lint=all,noNS -timescale=1ns/1ns -debug_acc+all -kdb -fsdb -suppress=LCA_FEATURES_ENABLED

sim/top_tb: $(SRCS)
	mkdir -p sim
	cd sim && vcs $(SRCS) $(VCS_FLAGS) -msg_config=../vcs_warn.config -l top_tb_compile.log -top top_tb -o top_tb

.PHONY: run_top_tb
run_top_tb: sim/top_tb $(PROG)
	../bin/generate_memory_file.sh $(PROG)
	rm -f sim/dump.fsdb
	cd sim && ./top_tb -l top_tb_sim.log

.PHONY: verdi
verdi:
	mkdir -p verdi
	cd verdi && $(VERDI_HOME)/bin/verdi -ssf $(PWD)/sim/dump.fsdb

.PHONY: clean
clean:
	rm -rf bin sim verdi
