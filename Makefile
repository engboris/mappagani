CAMLC=ocamlopt
LIBS=graphics.cmxa
EXEC=mappagani.exe

all: $(EXEC)

$(EXEC): voronoi.cmx sat_solver.cmx color_solver.cmx style.cmx graphics_plus.cmx examples.cmx display.cmx mappagani.cmx
		$(CAMLC) $(LIBS) -o $@ $^

%.cmx: %.mli %.ml
	$(CAMLC) -c $^

%.cmx: %.ml
	$(CAMLC) -c $^

.PHONY: clean mrproper

clean:
		rm -rf *.cmi
		rm -rf *.cmx
		rm -rf *.cmx
		rm -rf *.o

mrproper: clean
		rm -rf $(EXEC)