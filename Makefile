all: tests

NPROC = $$((`nproc`-1))

################################################################################
# Testbench setup
################################################################################
VERILATOR := verilator
ifdef VERILATOR_ROOT
VERILATOR := $(VERILATOR_ROOT)/bin/verilator
endif

VERILOG_DEFINE_FILES = ${UVM_ROOT}/src/uvm.sv ./hdl/tbench_top.sv ./hdl/design.sv
VERILOG_INCLUDE_DIRS = hdl ${UVM_ROOT}/src

################################################################################
# Call all test targets in each core
################################################################################
