all: tests

################################################################################
# Call all test targets in each core
################################################################################
tests:
	$(MAKE) -C hdl/cores/lif

clean:
	$(MAKE) -C hdl/cores/lif clean
