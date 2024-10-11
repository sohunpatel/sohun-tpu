tb_lif:
	$(MAKE) -C rtl/tb/lif

test: tb_lif

.PHONY: clean
clean:
	$(MAKE) -C rtl/tb/lif clean
