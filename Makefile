all: tests

################################################################################
# Call all test targets in each core
################################################################################
tests:
	$(MAKE) -C hdl/cores/mem
	$(MAKE) -C hdl/cores/lif

.PHONY: clean
clean:
	$(MAKE) -C hdl/cores/mem clean
	$(MAKE) -C hdl/cores/lif clean
