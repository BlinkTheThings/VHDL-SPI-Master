FILES=spi_master.vhdl spi_master_tb.vhdl
TOP=spi_master_tb

SIMDIR=simulation

all: analyze

analyze: $(SIMDIR)/work-obj93.cf

$(SIMDIR)/work-obj93.cf: $(FILES)
	@mkdir -p $(SIMDIR)
	ghdl -a --workdir=$(SIMDIR) $(FILES)

elaborate: analyze
	ghdl -e --workdir=$(SIMDIR) $(TOP)

$(SIMDIR)/$(TOP).vcd: elaborate
	ghdl -r --workdir=$(SIMDIR) $(TOP) --vcd=$(SIMDIR)/$(TOP).vcd

wave: $(SIMDIR)/$(TOP).vcd

view: wave
	@gtkwave $(SIMDIR)/$(TOP).vcd > /dev/null 2>&1 &

watch: wave
	@echo "Watching for changes..."
	@while inotifywait -qq -e close_write $(FILES); do make wave; done
    
.PHONY: clean
clean:
	@rm -rf $(SIMDIR)
