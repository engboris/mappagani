CAMLC=ocamlc
LIBS=graphics.cma
EXEC=mappagani.exe

all: $(EXEC)

$(EXEC): voronoi.cmo sat_solver.cmo color_solver.cmo style.cmo graphics_plus.cmo examples.cmo mappagani.cmo
		$(CAMLC) $(LIBS) -o $@ $^

%.cmo: %.mli %.ml
	$(CAMLC) -c $^

%.cmo: %.ml
	$(CAMLC) -c $^

.PHONY: clean mrproper

clean:
		rm -rf *.cmi
		rm -rf *.cmo

mrproper: clean
		rm -rf $(EXEC)
